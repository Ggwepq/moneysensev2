import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/detection_service.dart';
import '../../domain/entities/scanner_state.dart';


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
    state = ScannerState.idle;
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
    ref.read(detectionResultProvider.notifier).state = null;
    // Go back to scanning immediately after dismissing a result
    state = ScannerState.scanning;
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

    if (_consecutiveFrames >= _requiredFrames) {
      ref.read(detectionResultProvider.notifier).state = _candidate;
      state = ScannerState.result;
    }
  }
}


final detectionResultProvider = StateProvider<DetectionResult?>((ref) => null);
