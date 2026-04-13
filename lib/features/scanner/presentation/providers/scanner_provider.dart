import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import '../../data/datasources/detection_service.dart';
import '../../domain/entities/scanner_state.dart';
import 'package:moneysensev2/core/l10n/app_localizations.dart';
import 'package:moneysensev2/core/services/tts_service.dart';
import 'package:moneysensev2/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneysensev2/features/settings/domain/entities/app_settings.dart';
import '../../data/datasources/authenticity_service.dart';
import 'package:moneysensev2/core/services/earcon_service.dart';


export '../../data/datasources/camera_service.dart';


final cameraOpenProvider = StateProvider<bool>((ref) => false);


final scannerStateProvider =
    NotifierProvider<ScannerNotifier, ScannerState>(ScannerNotifier.new);

final verificationResultProvider =
    StateProvider<VerificationResult?>((ref) => null);

final retryTriggerProvider = StateProvider<int>((ref) => 0);

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
  
  DateTime?        _centeredStartTime;
  DateTime?        _phaseStartTime;
  String?          _lastHint;
  int              _lastGuidanceMs = 0;
  bool             _pendingFreshCapture = false;
  int              _lostFrames = 0;

  static const int _guidanceIntervalMs = 1200; // Increased to avoid TTS debounce
  static const int _requiredStabilityMs = 400; // Must be centered for 400ms
  static const int _maxCenteringMs = 30000;     // Reset after 30s
  static const int _maxLostFrames = 3;         // Reset after ~3s of no detections

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
    ref.read(verificationResultProvider.notifier).state = null;
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
    // LOCK: Only process frames if we are actively scanning or centering.
    if (state != ScannerState.scanning && state != ScannerState.centering) {
      if (state == ScannerState.processing && _pendingFreshCapture) {
         debugPrint('[Scanner] 📸 Fresh frame arrival. Capturing now.');
         _onFreshFrameAvailable(frame);
      }
      return;
    }
    
    if (!DetectionService.instance.isReady) return;
    
    // 🚀 High-Latency Optimization:
    // If the service is already busy with an inference, DROP this frame 
    // immediately without impacting lostFrames or stability timers.
    if (DetectionService.instance.isProcessing) return;

    final result = await DetectionService.instance.processFrame(frame);

    // Re-check state after async gap
    if (state != ScannerState.scanning && state != ScannerState.centering) return;

    if (result == null) {
      if (state == ScannerState.centering) {
        _lostFrames++;
        if (_lostFrames >= _maxLostFrames) {
          debugPrint('[Scanner] ⚠️ Lost bill too long during centering. Going back to scanning.');
          EarconService.instance.play(EarconEvent.scanFail);
          state = ScannerState.scanning;
          _candidate = null;
        } else {
          // Stay in centering for now, just wait for next frame
          debugPrint('[Scanner] ⚠️ Flickering null result... lost frames: $_lostFrames/$_maxLostFrames');
        }
      } else {
        _consecutiveFrames = 0;
        _candidate = null;
      }
      return;
    }

    _lostFrames = 0; 

    final isSame = _candidate?.denomination == result.denomination;
    if (isSame) {
      _consecutiveFrames++;
      if (result.confidence > (_candidate?.confidence ?? 0)) {
        _candidate = result;
      }
    } else {
      _consecutiveFrames = 1;
      _candidate = result;
    }

    // ── Transition: Scanning -> Centering ────────────────────────────────────
    if (state == ScannerState.scanning) {
      final shouldStartFocus = _manualCapturePending || (_consecutiveFrames >= _requiredFrames);
      if (shouldStartFocus) {
        debugPrint('[Scanner] 🎯 Bill Detected: ${result.denomination}. Entering centering phase...');
        state = ScannerState.centering;
        _manualCapturePending = false;
        
        _phaseStartTime = DateTime.now();
        _centeredStartTime = null;
        _lastHint = null;

        // 🌟 IMMEDIATE guidance call for the triggering frame
        _provideCenteringGuidance(result);
      }
      return;
    }

    // ── Phase: Centering ──────────────────────────────────────────────────
    if (state == ScannerState.centering) {
      _provideCenteringGuidance(result);
      
      final now = DateTime.now();
      final elapsed = now.difference(_phaseStartTime!).inMilliseconds;
      
      // Reset timeout: Abort after 30s
      if (elapsed >= _maxCenteringMs) {
        debugPrint('[Scanner] ⚠️ Centering timeout reached without alignment. Resetting.');
        EarconService.instance.play(EarconEvent.scanFail);
        state = ScannerState.scanning;
        return;
      }

      // Check if centered stability reached
      if (_centeredStartTime != null) {
        final centeredDuration = now.difference(_centeredStartTime!).inMilliseconds;
        if (centeredDuration >= _requiredStabilityMs) {
          debugPrint('[Scanner] ✅ Centering stability reached ($centeredDuration ms). Moving to PROCESSING.');
          _pendingFreshCapture = true;
          state = ScannerState.processing;
        }
      }
    }
  }

  void _provideCenteringGuidance(DetectionResult res) {
    if (res.boundingBox == null) return;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastGuidanceMs < _guidanceIntervalMs) return;
    _lastGuidanceMs = now;

    final rect = res.boundingBox!;
    final cx = rect.left + rect.width / 2;
    final cy = rect.top + rect.height / 2;

    final settings = ref.read(appSettingsProvider);
    final l10n = AppLocalizations.of(settings.isTagalog);
    
    final isLeft = cx < 0.15;
    final isRight = cx > 0.85;
    final isTop = cy < 0.35;
    final isBottom = cy > 0.65;

    String hint;
    if (isLeft && isTop)      hint = l10n.guidanceMoveRightDown;
    else if (isLeft && isBottom) hint = l10n.guidanceMoveRightUp;
    else if (isRight && isTop)   hint = l10n.guidanceMoveLeftDown;
    else if (isRight && isBottom) hint = l10n.guidanceMoveLeftUp;
    else if (isLeft)   hint = l10n.guidanceMoveRight;
    else if (isRight)  hint = l10n.guidanceMoveLeft;
    else if (isTop)    hint = l10n.guidanceMoveDown;
    else if (isBottom) hint = l10n.guidanceMoveUp;
    else               hint = l10n.guidanceCentered;

    // Handle stability tracking
    if (hint == l10n.guidanceCentered) {
      if (_centeredStartTime == null) {
        _centeredStartTime = DateTime.now();
        EarconService.instance.play(EarconEvent.centered);
      }
    } else {
      _centeredStartTime = null;
    }

    if (hint == _lastHint) {
      // Don't repeat identical guidance logs/TTS too frequently.
      // Basic throttling via _lastGuidanceMs already exists, but we can be smarter.
    }
    _lastHint = hint;

    debugPrint('[Centering] 📍 cx: ${cx.toStringAsFixed(2)}, cy: ${cy.toStringAsFixed(2)} -> Hint: $hint');

    ref.read(ttsServiceProvider).enqueue(
      TtsMessage(
        text: hint,
        priority: TtsPriority.navigation,
        requiredVerbosity: TtsVerbosity.minimal,
        id: 'scanner.guidance',
      ),
      enabled: settings.ttsEnabled,
      currentVerbosity: settings.ttsVerbosity,
    );
  }

  void _onFreshFrameAvailable(CameraImage frame) {
    _pendingFreshCapture = false;
    
    // High-res clone
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
  }

  Future<void> _captureFrame(Map<String, dynamic> args, DetectionResult base) async {
    debugPrint('[ScannerProvider] 📸 Captured frame. Starting high-res OCR check...');
    
    // 1. JPEG Conversion
    final jpeg = await compute(_yuvToJpegTask, args);
    
    // 2. OCR Correction 
    // Run OCR identification immediately to catch things like "REPRODUCTION" or Tagalog words
    final ocrDenom = await AuthenticityService.instance.getDenominationFromOCR(jpeg);

    if (ocrDenom != null && ocrDenom != base.denomination) {
       debugPrint('[ScannerProvider] 🎯 OCR Corrected denomination: $ocrDenom (was ${base.denomination})');
    }

    final finalResult = DetectionResult(
      denomination:  ocrDenom ?? base.denomination,
      type:          base.type,
      confidence:    ocrDenom != null ? 0.99 : base.confidence,
      boundingBox:    base.boundingBox,
      capturedImage: jpeg,
    );

    if (state != ScannerState.processing) return; // Guard against reset during delay

    // 4. Update Providers & Transition
    ref.read(detectionResultProvider.notifier).state = finalResult;
    ref.read(verificationResultProvider.notifier).state = null; // Reset verification
    
    state = ScannerState.result;
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
