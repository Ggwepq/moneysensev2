import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Available cameras (initialised once at app start)
// ---------------------------------------------------------------------------

/// All cameras found on the device. Populated in [main] before runApp.
final availableCamerasProvider = Provider<List<CameraDescription>>((ref) {
  throw UnimplementedError('availableCamerasProvider must be overridden in ProviderScope');
});

// ---------------------------------------------------------------------------
// Camera Controller Provider
// ---------------------------------------------------------------------------

/// Exposes the active [CameraController] (or null if camera is closed).
///
/// This is an [AsyncNotifierProvider] so the UI can react to the
/// initialisation future with loading / error states.
final cameraControllerProvider =
    AsyncNotifierProvider<CameraControllerNotifier, CameraController?>(
  CameraControllerNotifier.new,
);

class CameraControllerNotifier extends AsyncNotifier<CameraController?> {
  CameraController? _controller;

  @override
  Future<CameraController?> build() async {
    // Dispose of any existing controller when the notifier is rebuilt.
    ref.onDispose(_disposeController);
    return null; // start with camera closed
  }

  // ── Public API ─────────────────────────────────────────────────────────

  /// Opens the camera with the given [useFrontCamera] / [flashMode] settings.
  Future<void> openCamera({
    required bool useFrontCamera,
    required bool useFlash,
  }) async {
    await _disposeController();

    final cameras = ref.read(availableCamerasProvider);
    if (cameras.isEmpty) return;

    final description = _pickCamera(cameras, useFrontCamera);

    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = controller;

    // Signal loading
    state = const AsyncValue.loading();

    try {
      await controller.initialize();
      await _applyFlash(controller, useFlash);
      state = AsyncValue.data(controller);
    } catch (e, st) {
      _controller = null;
      state = AsyncValue.error(e, st);
    }
  }

  /// Closes the camera and releases resources.
  Future<void> closeCamera() async {
    await _disposeController();
    state = const AsyncValue.data(null);
  }

  /// Switches flash on or off without reinitialising the camera.
  Future<void> setFlash(bool enabled) async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    await _applyFlash(c, enabled);
    // Notify listeners so UI reflects the change
    state = AsyncValue.data(c);
  }

  /// Reinitialises the camera with a different lens direction.
  Future<void> switchCamera({
    required bool useFrontCamera,
    required bool useFlash,
  }) async {
    await openCamera(useFrontCamera: useFrontCamera, useFlash: useFlash);
  }

  // ── Internals ──────────────────────────────────────────────────────────

  Future<void> _disposeController() async {
    final c = _controller;
    _controller = null;
    if (c != null && c.value.isInitialized) {
      await c.dispose();
    }
  }

  CameraDescription _pickCamera(
    List<CameraDescription> cameras,
    bool useFront,
  ) {
    final direction =
        useFront ? CameraLensDirection.front : CameraLensDirection.back;
    return cameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => cameras.first,
    );
  }

  Future<void> _applyFlash(CameraController c, bool enabled) async {
    try {
      await c.setFlashMode(
        enabled ? FlashMode.torch : FlashMode.off,
      );
    } catch (_) {
      // Some emulators / devices don't support torch; ignore silently.
    }
  }
}
