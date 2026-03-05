import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Available cameras — seeded in main.dart via ProviderScope.overrides
// ---------------------------------------------------------------------------

final availableCamerasProvider = Provider<List<CameraDescription>>((ref) {
  throw UnimplementedError(
    'availableCamerasProvider must be overridden in ProviderScope',
  );
});

// ---------------------------------------------------------------------------
// Camera Controller Provider
// ---------------------------------------------------------------------------

final cameraControllerProvider =
    AsyncNotifierProvider<CameraControllerNotifier, CameraController?>(
      CameraControllerNotifier.new,
    );

class CameraControllerNotifier extends AsyncNotifier<CameraController?> {
  CameraController? _controller;

  @override
  Future<CameraController?> build() async {
    ref.onDispose(_disposeController);
    return null;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

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

  Future<void> closeCamera() async {
    await _disposeController();
    state = const AsyncValue.data(null);
  }

  /// Suspends the controller (app backgrounded / route obscured).
  /// Does NOT clear the open intent — [cameraOpenProvider] stays true.
  Future<void> suspendCamera() async {
    await _disposeController();
    state = const AsyncValue.data(null);
  }

  /// Resumes after a suspension. Opens the camera with the given settings.
  Future<void> resumeCamera({
    required bool useFrontCamera,
    required bool useFlash,
  }) async {
    await openCamera(useFrontCamera: useFrontCamera, useFlash: useFlash);
  }

  Future<void> setFlash(bool enabled) async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    await _applyFlash(c, enabled);
    state = AsyncValue.data(c);
  }

  Future<void> switchCamera({
    required bool useFrontCamera,
    required bool useFlash,
  }) async {
    await openCamera(useFrontCamera: useFrontCamera, useFlash: useFlash);
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  Future<void> _disposeController() async {
    final c = _controller;
    _controller = null;
    if (c != null && c.value.isInitialized) await c.dispose();
  }

  CameraDescription _pickCamera(
    List<CameraDescription> cameras,
    bool useFront,
  ) {
    final dir = useFront ? CameraLensDirection.front : CameraLensDirection.back;
    return cameras.firstWhere(
      (c) => c.lensDirection == dir,
      orElse: () => cameras.first,
    );
  }

  Future<void> _applyFlash(CameraController c, bool enabled) async {
    try {
      await c.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
    } catch (_) {
      // Device / emulator doesn't support torch — ignore silently.
    }
  }
}
