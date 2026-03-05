import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/scanner_state.dart';
import '../providers/scanner_provider.dart';
import '../widgets/camera_viewfinder.dart';

/// Main scanner / home screen.
///
/// Owns the camera lifecycle via [WidgetsBindingObserver]:
///   • App backgrounded  → controller suspended (intent preserved)
///   • App foregrounded  → camera re-opened automatically if intent is true
///   • Navigate to other screen → camera stays open (intent preserved)
///   • User taps play/stop button → intent toggled + camera opened/closed
///
/// Gesture map (gesturalNavigation must be enabled in settings):
///   Swipe RIGHT  →  Settings   (settings lives "left" of home in nav stack)
///   Swipe LEFT   →  Help/Tutorial
///   Swipe UP     →  Toggle flash
///   Double-tap   →  Pause / resume preview
///
/// Swipe guard: cross-axis / main-axis ratio must be < 0.6 to avoid
/// accidental triggers from diagonal drags.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, required this.onNavigate});

  /// 0 = settings, 2 = tutorial/help.
  final ValueChanged<int> onNavigate;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  // Minimum velocity (logical px/s) for a flick to register as a swipe
  static const double _minSwipeVelocity = 300.0;
  // Max ratio of off-axis to on-axis velocity — keeps gestures clean
  static const double _maxCrossRatio = 0.55;

  Offset? _panStart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── App lifecycle ─────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final isOpen = ref.read(cameraOpenProvider);
    if (!isOpen) return;

    final camNotifier = ref.read(cameraControllerProvider.notifier);
    final scanNotifier = ref.read(scannerStateProvider.notifier);
    final settings = ref.read(appSettingsProvider);

    switch (lifecycle) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        camNotifier.closeCamera();
        break;
      case AppLifecycleState.resumed:
        // Re-open automatically — the open intent is still true
        camNotifier
            .openCamera(
              useFrontCamera: settings.useFrontCamera,
              useFlash: settings.useFlashlight,
            )
            .then((_) => scanNotifier.openCamera());
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
        statusLabel = 'Paused';
        break;
      case ScannerState.scanning:
        statusLabel = l10n.scanning;
        break;
      case ScannerState.processing:
        statusLabel = l10n.processing;
        break;
      default:
        statusLabel = null;
    }

    return GestureDetector(
      onPanStart: settings.gesturalNavigation
          ? (d) => _panStart = d.localPosition
          : null,
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
    if (!cameraOpen) {
      return _IdlePlaceholder(l10n: l10n, isDark: isDark);
    }

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
            if (scannerState == ScannerState.paused) const _PausedOverlay(),
          ],
        );
      },
    );
  }

  // ── Gesture handlers ──────────────────────────────────────────────────────

  void _onPanEnd(DragEndDetails details) {
    _panStart = null;
    final v = details.velocity.pixelsPerSecond;
    final ax = v.dx.abs();
    final ay = v.dy.abs();

    if (ax < _minSwipeVelocity && ay < _minSwipeVelocity) return;

    if (ax >= ay) {
      // Horizontal swipe — reject if too diagonal
      if (ay / ax > _maxCrossRatio) return;
      if (v.dx > 0) {
        widget.onNavigate(0); // → right = Settings
      } else {
        widget.onNavigate(2); // ← left  = Help
      }
    } else {
      // Vertical swipe — reject if too diagonal
      if (ax / ay > _maxCrossRatio) return;
      if (v.dy < 0) {
        _toggleFlash(); // ↑ up = toggle flash
      }
      // ↓ down reserved
    }
  }

  void _onDoubleTap() {
    final notifier = ref.read(scannerStateProvider.notifier);
    final current = ref.read(scannerStateProvider);
    if (current == ScannerState.previewing) {
      notifier.pausePreview();
    } else if (current == ScannerState.paused) {
      notifier.resumePreview();
    }
  }

  void _toggleFlash() {
    final settings = ref.read(appSettingsProvider);
    final next = !settings.useFlashlight;
    ref.read(appSettingsProvider.notifier).toggleFlashlight(next);
    ref.read(cameraControllerProvider.notifier).setFlash(next);
  }
}

// ── Inner widgets ─────────────────────────────────────────────────────────────

class _IdlePlaceholder extends StatelessWidget {
  const _IdlePlaceholder({required this.l10n, required this.isDark});
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.currency_exchange_rounded,
            size: 56,
            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tapToScan,
            style: TextStyle(
              color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.accentBlue,
        strokeWidth: 3,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.isDark});
  final String error;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
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
}

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
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
              'Paused',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Double-tap to resume',
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
}
