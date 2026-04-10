import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import '../../data/datasources/detection_service.dart';
import '../../domain/entities/scanner_state.dart';
import 'package:moneysensev2/core/l10n/app_localizations.dart';
import 'package:moneysensev2/core/services/tts_service.dart';
import 'package:moneysensev2/features/settings/presentation/providers/settings_provider.dart';


export '../../data/datasources/camera_service.dart';


final cameraOpenProvider = StateProvider<bool>((ref) => false);


final scannerStateProvider =
    NotifierProvider<ScannerNotifier, ScannerState>(ScannerNotifier.new);

class ScannerNotifier extends Notifier<ScannerState> {
  @override
  ScannerState build() {
    DetectionService.instance.init();
    return ScannerState.idle;
  }

  // Consecutive matching frames required before committing result.
  // Changed to 1 for instant identification when a bill is detected.
  static const int _requiredFrames = 1;

  int              _consecutiveFrames = 0;
  DetectionResult? _candidate;
  ScannerState?    _lastState;
  bool             _manualCapturePending = false;

  // ── State transitions ─────────────────────────────────────────────────────

  /// Opens camera AND immediately starts scanning.
  /// Called by _toggleCamera in HomeShell when play is tapped.
  void openCamera() {
    _consecutiveFrames = 0;
    _candidate = null;
    state = ScannerState.scanning; // go straight to scanning
  }

  void closeCamera() {
    _consecutiveFrames = 0;
    _candidate = null;
    _lastState = null;
    state = ScannerState.idle;
  }

  /// Called when navigating away to another screen to freeze the scanner gracefully.
  void suspendScanner() {
    if (state != ScannerState.idle) {
      _lastState = state;
      state = ScannerState.paused;
    }
  }

  /// Called when returning to the camera from another screen.
  void restoreScanner() {
    if (_lastState != null) {
      if (_lastState == ScannerState.scanning || _lastState == ScannerState.processing) {
         _consecutiveFrames = 0;
         _candidate = null;
         state = ScannerState.scanning;
      } else {
         state = _lastState!;
      }
      _lastState = null;
    } else {
      openCamera();
    }
  }

  void pausePreview() {
    if (state == ScannerState.scanning ||
        state == ScannerState.processing ||
        state == ScannerState.previewing) {
      state = ScannerState.paused;
    }
  }

  void resumePreview() {
    if (state == ScannerState.paused) {
      _consecutiveFrames = 0;
      _candidate = null;
      state = ScannerState.scanning; // resume straight to scanning
    }
  }

  // Keep these for compatibility with existing call sites
  void startScanning() {
    if (state == ScannerState.previewing || state == ScannerState.paused) {
      _consecutiveFrames = 0;
      _candidate = null;
      state = ScannerState.scanning;
    }
  }

  void startProcessing() => state = ScannerState.processing;
  void showResult()       => state = ScannerState.result;

  void reset() {
    _consecutiveFrames = 0;
    _candidate = null;
    _manualCapturePending = false;
    ref.read(detectionResultProvider.notifier).state = null;
    // Go back to scanning immediately after dismissing a result
    state = ScannerState.scanning;
  }

  /// Manually triggers an instant identification of the very next detected frame.
  /// Bypasses the stability queue.
  void manualIdentify() {
    if (state == ScannerState.scanning || state == ScannerState.processing) {
      _manualCapturePending = true;
      
      // Feedback
      final settings = ref.read(appSettingsProvider);
      final l10n = AppLocalizations.of(settings.isTagalog);
      ref.read(ttsServiceProvider).enqueue(
        TtsMessage.ambient(l10n.resultManualCapturing, id: 'scanner.manual_capture'),
        enabled: settings.ttsEnabled,
        currentVerbosity: settings.ttsVerbosity,
      );
      
      // Reset confidence filter briefly to catch the next frame
      _consecutiveFrames = 0;
    }
  }

  // ── Real-time detection ───────────────────────────────────────────────────

  Future<void> processFrame(CameraImage frame) async {
    if (state != ScannerState.scanning && state != ScannerState.processing) {
      return;
    }
    if (!DetectionService.instance.isReady) return;

    // Rate limiting is handled inside DetectionService
    final result = await DetectionService.instance.processFrame(frame);

    if (state != ScannerState.scanning && state != ScannerState.processing) {
      return;
    }

    if (result == null) {
      _consecutiveFrames = 0;
      _candidate = null;
      if (state == ScannerState.processing) state = ScannerState.scanning;
      return;
    }

    final isSame = _candidate?.denomination == result.denomination;
    if (isSame) {
      _consecutiveFrames++;
      if (result.confidence > (_candidate?.confidence ?? 0)) {
        _candidate = result;
      }
    } else {
      _consecutiveFrames = 1;
      _candidate = result;
      if (state == ScannerState.scanning) state = ScannerState.processing;
    }

    final shouldCommit = _manualCapturePending || (_consecutiveFrames >= _requiredFrames);

    if (shouldCommit) {
      _manualCapturePending = false;
      // High-res capture for all types
      final copyY = Uint8List.fromList(frame.planes[0].bytes);
      final copyU = Uint8List.fromList(frame.planes[1].bytes);
      final copyV = Uint8List.fromList(frame.planes[2].bytes);
      
      final args = {
        'y': copyY, 'u': copyU, 'v': copyV,
        'w': frame.width, 'h': frame.height,
        'yRS': frame.planes[0].bytesPerRow,
        'uRS': frame.planes[1].bytesPerRow,
        'uPS': frame.planes[1].bytesPerPixel ?? 1,
        'vRS': frame.planes[2].bytesPerRow,
        'vPS': frame.planes[2].bytesPerPixel ?? 1,
      };

      _captureFrame(args, _candidate!);
      state = ScannerState.result;
    }
  }

  Future<void> _captureFrame(Map<String, dynamic> args, DetectionResult base) async {
    final jpeg = await compute(_yuvToJpegTask, args);
    final finalResult = DetectionResult(
      denomination:  base.denomination,
      type:          base.type,
      confidence:    base.confidence,
      boundingBox:    base.boundingBox,
      capturedImage: jpeg,
    );
    // Update the result provider once the high-res frame is ready
    ref.read(detectionResultProvider.notifier).state = finalResult;
  }
}

/// BACKGROUND TASK: Converts YUV420 CameraImage data to JPEG Uint8List
Uint8List _yuvToJpegTask(Map<String, dynamic> args) {
  final Uint8List yB = args['y'];
  final Uint8List uB = args['u'];
  final Uint8List vB = args['v'];
  final int w = args['w'];
  final int h = args['h'];
  final int yRS = args['yRS'];
  final int uRS = args['uRS'];
  final int uPS = args['uPS'];
  final int vRS = args['vRS'];
  final int vPS = args['vPS'];

  final image = img.Image(width: w, height: h);
  
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final yIdx = y * yRS + x;
      final uvR = y >> 1;
      final uvC = x >> 1;
      final uIdx = uvR * uRS + uvC * uPS;
      final vIdx = uvR * vRS + uvC * vPS;

      final Y = yB[yIdx];
      final U = uB[uIdx] - 128;
      final V = vB[vIdx] - 128;

      final r = (Y + 1.402 * V).clamp(0, 255).toInt();
      final g = (Y - 0.344136 * U - 0.714136 * V).clamp(0, 255).toInt();
      final b = (Y + 1.772 * U).clamp(0, 255).toInt();

      image.setPixelRgb(x, y, r, g, b);
    }
  }
  
  return Uint8List.fromList(img.encodeJpg(image));
}


final detectionResultProvider = StateProvider<DetectionResult?>((ref) => null);
