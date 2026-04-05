// ═══════════════════════════════════════════════════════════════════════════
// ADD TO: lib/features/scanner/presentation/screens/scanner_screen.dart
// ═══════════════════════════════════════════════════════════════════════════
//
// 1. Add import at the top:
//    import 'result_screen.dart';
//
// 2. In the build() method of _ScannerScreenState, add this block at the
//    very start of build(), BEFORE the return statement:
//
//    final scannerState = ref.watch(scannerStateProvider);
//    // (this line likely already exists — don't duplicate it)
//
//    if (scannerState == ScannerState.result) {
//      final result = ref.watch(detectionResultProvider);
//      if (result != null) {
//        return ResultScreen(result: result);
//      }
//    }
//
// 3. In the camera image stream callback (_onFrame in CameraControllerNotifier
//    or wherever startImageStream is called), pipe frames to detection:
//
//    void _onFrame(CameraImage image) {
//      ref.read(scannerStateProvider.notifier).processFrame(image);
//    }
//
//    If camera_service.dart manages the stream, add the same call there,
//    passing the notifier reference through the constructor or via a callback.

// ── scanner_provider.dart also exports cameraControllerProvider ──────────
// The existing scanner_provider.dart has:
//   export '../data/datasources/camera_service.dart';
//
// camera_service.dart must define cameraControllerProvider.
// The new scanner_provider.dart (in scanner_provider/ folder) keeps this export.
// Merge the new processFrame() method and _consecutiveFrames logic into
// your existing ScannerNotifier class — do NOT replace the whole file,
// just add the new methods to the existing class.
