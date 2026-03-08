import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneysensev2/features/scanner/data/datasources/camera_service.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/scanner_state.dart';
import '../providers/scanner_provider.dart';
import '../widgets/camera_viewfinder.dart';

// ---------------------------------------------------------------------------
// RouteObserver — shared app-wide, registered on MaterialApp
// ---------------------------------------------------------------------------

/// Registered on [MaterialApp.navigatorObservers] in app.dart.
/// [ScannerScreen] subscribes to it so it can pause/resume the camera
/// when Settings or Tutorial are pushed on top.
final routeObserverProvider = Provider<RouteObserver<ModalRoute<void>>>(
  (ref) => RouteObserver<ModalRoute<void>>(),
);

// ---------------------------------------------------------------------------
// Scanner screen
// ---------------------------------------------------------------------------

/// Main scanner / home screen.
///
/// Camera lifecycle:
///   AppLifecycleState.inactive  → do NOTHING (nav-bar swipe, notification pull)
///   AppLifecycleState.paused    → suspendCamera (keep open-intent)
///   AppLifecycleState.hidden    → suspendCamera (keep open-intent)
///   AppLifecycleState.resumed   → resumeCamera if intent=true AND not obscured
///   RouteAware.didPushNext      → suspendCamera (Settings / Tutorial opened)
///   RouteAware.didPopNext       → resumeCamera  (returned to home)
///
/// Gesture map (requires gesturalNavigation enabled in settings):
///   Swipe RIGHT  →  Settings
///   Swipe LEFT   →  Help / Tutorial
///   Swipe UP     →  Toggle flash
///   Double-tap   →  Pause / resume preview freeze
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver, RouteAware {
  static const double _minVelocity = 300.0;
  static const double _maxCrossRatio = 0.55;

  // True while Settings / Tutorial is on top of the navigator stack.
  bool _routeObscured = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = ref.read(routeObserverProvider);
    final route = ModalRoute.of(context);
    if (route != null) observer.subscribe(this, route);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(routeObserverProvider).unsubscribe(this);
    super.dispose();
  }

  // ── RouteAware ─────────────────────────────────────────────────────────────

  @override
  void didPushNext() {
    // Settings / Tutorial pushed — suspend camera while away.
    _routeObscured = true;
    _suspend();
  }

  @override
  void didPopNext() {
    // Returned from Settings / Tutorial — resume if intent is still true.
    _routeObscured = false;
    _resume();
  }

  void _suspend() {
    if (!ref.read(cameraOpenProvider)) return;
    ref.read(cameraControllerProvider.notifier).suspendCamera();
  }

  void _resume() {
    if (!ref.read(cameraOpenProvider)) return;
    final s = ref.read(appSettingsProvider);
    ref
        .read(cameraControllerProvider.notifier)
        .resumeCamera(
          useFrontCamera: s.useFrontCamera,
          useFlash: s.useFlashlight,
        )
        .then((_) => ref.read(scannerStateProvider.notifier).openCamera());
  }

  // ── AppLifecycleState ──────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    switch (lifecycle) {
      // ── inactive: system UI drawn over app (nav-bar swipe-down, call HUD).
      // The camera stays alive — killing it here causes the flash-dies bug.
      case AppLifecycleState.inactive:
        break;

      // ── paused / hidden: app is genuinely in the background.
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (ref.read(cameraOpenProvider)) _suspend();
        break;

      // ── resumed: app back in the foreground.
      case AppLifecycleState.resumed:
        // Only re-open if the intent is true AND the home route is visible
        // (not covered by Settings / Tutorial).
        if (ref.read(cameraOpenProvider) && !_routeObscured) _resume();
        break;

      case AppLifecycleState.detached:
        break;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final scannerState = ref.watch(scannerStateProvider);
    final cameraOpen = ref.watch(cameraOpenProvider);
    final cameraAsync = ref.watch(cameraControllerProvider);
    final l10n = AppLocalizations.of(settings.isTagalog);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String? statusLabel;
    switch (scannerState) {
      case ScannerState.paused:
        statusLabel = l10n.paused;
        break;
      case ScannerState.scanning:
        statusLabel = l10n.scanning;
        break;
      case ScannerState.processing:
        statusLabel = l10n.processing;
        break;
      default:
        break;
    }

    return GestureDetector(
      onPanEnd: settings.gesturalNavigation ? _onPanEnd : null,
      onDoubleTap: cameraOpen ? _onDoubleTap : null,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: CameraViewfinder(
            scannerState: cameraOpen ? scannerState : ScannerState.idle,
            isDark: isDark,
            statusLabel: statusLabel,
            child: _buildContent(
              cameraOpen: cameraOpen,
              cameraAsync: cameraAsync,
              scannerState: scannerState,
              l10n: l10n,
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required bool cameraOpen,
    required AsyncValue<CameraController?> cameraAsync,
    required ScannerState scannerState,
    required AppLocalizations l10n,
    required bool isDark,
  }) {
    if (!cameraOpen) return _IdlePlaceholder(l10n: l10n, isDark: isDark);

    return cameraAsync.when(
      loading: () => const _LoadingView(),
      error: (e, _) => _ErrorView(error: e.toString(), isDark: isDark),
      data: (controller) {
        if (controller == null || !controller.value.isInitialized) {
          return _IdlePlaceholder(l10n: l10n, isDark: isDark);
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller),
            if (scannerState == ScannerState.paused) _PausedOverlay(l10n: l10n),
          ],
        );
      },
    );
  }

  // ── Gesture handlers ───────────────────────────────────────────────────────

  void _onPanEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond;
    final ax = v.dx.abs();
    final ay = v.dy.abs();
    if (ax < _minVelocity && ay < _minVelocity) return;

    if (ax >= ay) {
      if (ay / ax > _maxCrossRatio) return; // too diagonal
      v.dx > 0 ? widget.onNavigate(0) : widget.onNavigate(2);
    } else {
      if (ax / ay > _maxCrossRatio) return; // too diagonal
      if (v.dy < 0) _toggleFlash(); // swipe up = flash
    }
  }

  void _onDoubleTap() {
    final n = ref.read(scannerStateProvider.notifier);
    final s = ref.read(scannerStateProvider);
    if (s == ScannerState.previewing) {
      // Double-tap on live preview triggers a scan
      HapticFeedback.mediumImpact();
      n.startScanning();
    } else if (s == ScannerState.paused) {
      HapticFeedback.lightImpact();
      n.resumePreview();
    }
  }

  void _toggleFlash() {
    final settings = ref.read(appSettingsProvider);
    final next = !settings.useFlashlight;
    ref.read(appSettingsProvider.notifier).toggleFlashlight(next);
    ref.read(cameraControllerProvider.notifier).setFlash(next);
  }
}

// ── Inner widgets ──────────────────────────────────────────────────────────────

class _IdlePlaceholder extends StatelessWidget {
  const _IdlePlaceholder({required this.l10n, required this.isDark});
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.currency_exchange_rounded,
          size: 56,
          color: isDark ? const Color(0xFF4A5568) : const Color(0xFFB0B8C4),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.tapToScan,
          style: TextStyle(
            // Lightened: was 0xFF555555 / 0xFFAAAAAA — now clearly visible
            color: isDark ? const Color(0xFF8A9BB0) : const Color(0xFF7A8899),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(
      color: AppColors.accentBlue,
      strokeWidth: 3,
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.isDark});
  final String error;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.no_photography_outlined,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Camera unavailable',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDark
                  ? AppColors.darkOnSurface
                  : AppColors.lightOnSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.lightOnSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black.withOpacity(0.45),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pause_circle_outline_rounded,
            size: 72,
            color: Colors.white.withOpacity(0.85),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.paused,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.doubleTapToResume,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}
