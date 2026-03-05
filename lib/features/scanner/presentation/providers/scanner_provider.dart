import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scanner_state.dart';

// ---------------------------------------------------------------------------
// Re-export camera service so features only need to import this file
// ---------------------------------------------------------------------------

export '../../data/datasources/camera_service.dart';

// ---------------------------------------------------------------------------
// Camera open/closed intent (user preference, survives app resume)
// ---------------------------------------------------------------------------

/// Whether the user has requested the camera to be open.
/// This is the *intent* — the actual controller state is in
/// [cameraControllerProvider]. On app resume, if this is true the camera
/// will be re-initialised automatically.
final cameraOpenProvider = StateProvider<bool>((ref) => false);

// ---------------------------------------------------------------------------
// Scanner state machine
// ---------------------------------------------------------------------------

final scannerStateProvider = NotifierProvider<ScannerNotifier, ScannerState>(
  ScannerNotifier.new,
);

class ScannerNotifier extends Notifier<ScannerState> {
  @override
  ScannerState build() => ScannerState.idle;

  void openCamera() => state = ScannerState.previewing;
  void closeCamera() => state = ScannerState.idle;

  /// Pauses the live feed (e.g. double-tap) without closing the camera.
  void pausePreview() {
    if (state == ScannerState.previewing) {
      state = ScannerState.paused;
    }
  }

  /// Resumes from a paused state back to live preview.
  void resumePreview() {
    if (state == ScannerState.paused) {
      state = ScannerState.previewing;
    }
  }

  void startScanning() => state = ScannerState.scanning;
  void startProcessing() => state = ScannerState.processing;
  void showResult() => state = ScannerState.result;
  void reset() => state = ScannerState.previewing;
}

// ---------------------------------------------------------------------------
// Detection Result
// ---------------------------------------------------------------------------

final detectionResultProvider = StateProvider<DetectionResult?>((ref) => null);
