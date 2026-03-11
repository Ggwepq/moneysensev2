import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/earcon_service.dart';
import '../../../../core/services/speech_scripts.dart';
import '../../../../core/services/tts_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/scanner_state.dart';
import '../providers/scanner_provider.dart';
import '../widgets/camera_viewfinder.dart';


final routeObserverProvider = Provider<RouteObserver<ModalRoute<void>>>(
  (ref) => RouteObserver<ModalRoute<void>>(),
);


class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver, RouteAware {
  static const double _minVelocity   = 300.0;
  static const double _maxCrossRatio = 0.55;

  // ── Idle timer ─────────────────────────────────────────────────────────────
  // Fires when the camera has been open with no result for a while.
  // First hint at 8 s, repeats every 12 s, resets on any result.
  static const Duration _idleFirst  = Duration(seconds: 8);
  static const Duration _idleRepeat = Duration(seconds: 12);
  Timer? _idleTimer;

  // ── State tracking ─────────────────────────────────────────────────────────
  bool _routeObscured   = false;

  // ── Helpers ─────────────────────────────────────────────────────────────────

  TtsService get _tts => ref.read(ttsServiceProvider);

  void _enqueue(TtsMessage msg) {
    final s = ref.read(appSettingsProvider);
    _tts.enqueue(msg,
        enabled: s.ttsEnabled, currentVerbosity: s.ttsVerbosity);
  }

  AppLocalizations get _l10n =>
      AppLocalizations.of(ref.read(appSettingsProvider).isTagalog);

  // ── Idle loop ──────────────────────────────────────────────────────────────

  void _startIdleTimer() {
    _cancelIdleTimer();
    _idleTimer = Timer(_idleFirst, _onIdle);
  }

  void _cancelIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  void _onIdle() {
    _enqueue(ScannerSpeech.idleHint(_l10n));
    // Repeat at longer interval
    _idleTimer = Timer(_idleRepeat, _onIdle);
  }

  void _resetIdleTimer() {
    final cameraOpen = ref.read(cameraOpenProvider);
    if (cameraOpen) {
      _startIdleTimer();
    } else {
      _cancelIdleTimer();
    }
  }

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
    final route    = ModalRoute.of(context);
    if (route != null) observer.subscribe(this, route);
  }

  @override
  void dispose() {
    _cancelIdleTimer();
    WidgetsBinding.instance.removeObserver(this);
    ref.read(routeObserverProvider).unsubscribe(this);
    super.dispose();
  }

  // ── RouteAware ─────────────────────────────────────────────────────────────

  @override
  void didPushNext() {
    _routeObscured = true;
    _cancelIdleTimer();
    _suspend();
  }

  @override
  void didPopNext() {
    _routeObscured = false;
    _resume();
    _enqueue(NavSpeech.returnedHome(_l10n));
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
            useFrontCamera: s.useFrontCamera, useFlash: s.useFlashlight)
        .then((_) {
      ref.read(scannerStateProvider.notifier).openCamera();
      _startIdleTimer();
    });
  }

  // ── AppLifecycleState ──────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    switch (lifecycle) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _cancelIdleTimer();
        if (ref.read(cameraOpenProvider)) _suspend();
        break;
      case AppLifecycleState.resumed:
        if (ref.read(cameraOpenProvider) && !_routeObscured) _resume();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings     = ref.watch(appSettingsProvider);
    final scannerState = ref.watch(scannerStateProvider);
    final cameraOpen   = ref.watch(cameraOpenProvider);
    final cameraAsync  = ref.watch(cameraControllerProvider);
    final l10n         = AppLocalizations.of(settings.isTagalog);
    final isDark       = Theme.of(context).brightness == Brightness.dark;

    // ── React to scanner state changes (TTS + idle timer) ─────────────────
    // Using ref.listen here keeps side-effects out of build()
    ref.listen<ScannerState>(scannerStateProvider, (prev, next) {
      _onScannerStateChanged(prev ?? ScannerState.idle, next);
    });

    // ── React to camera open/close (TTS + idle timer) ──────────────────────
    ref.listen<bool>(cameraOpenProvider, (prev, next) {
      _onCameraOpenChanged(prev ?? false, next);
    });

    // ── React to errors from cameraControllerProvider ─────────────────────
    ref.listen<AsyncValue<CameraController?>>(cameraControllerProvider,
        (_, next) {
      if (next is AsyncError) {
        _enqueue(ScannerSpeech.cameraError(l10n));
      }
    });

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

    return Semantics(
      label: _viewfinderSemanticLabel(scannerState, cameraOpen, l10n),
      child: GestureDetector(
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
                cameraOpen:   cameraOpen,
                cameraAsync:  cameraAsync,
                scannerState: scannerState,
                l10n: l10n,
                isDark: isDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _viewfinderSemanticLabel(
      ScannerState state, bool cameraOpen, AppLocalizations l10n) {
    if (!cameraOpen) return l10n.scannerSemanticIdle;
    return switch (state) {
      ScannerState.previewing  => l10n.scannerSemanticReady,
      ScannerState.scanning    => l10n.scannerSemanticScanning,
      ScannerState.processing  => l10n.scannerSemanticProcessing,
      ScannerState.paused      => l10n.scannerSemanticPaused,
      ScannerState.result      => l10n.scannerSemanticResult,
      ScannerState.idle        => l10n.scannerSemanticIdle,
    };
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
            if (scannerState == ScannerState.paused)
              _PausedOverlay(l10n: l10n),
          ],
        );
      },
    );
  }

  // ── State-change side-effects (TTS + idle) ─────────────────────────────────

  void _onCameraOpenChanged(bool prev, bool next) {
    if (next == prev) return;
    if (next) {
      EarconService.instance.play(EarconEvent.cameraOpen);
      _enqueue(ScannerSpeech.cameraOpened(_l10n));
      _startIdleTimer();
    } else {
      EarconService.instance.play(EarconEvent.cameraClose);
      _enqueue(ScannerSpeech.cameraClosed(_l10n));
      _cancelIdleTimer();
    }
  }

  void _onScannerStateChanged(ScannerState prev, ScannerState next) {
    if (next == prev) return;

    switch (next) {
      case ScannerState.scanning:
        EarconService.instance.play(EarconEvent.scanStart);
        _enqueue(ScannerSpeech.scanStarted(_l10n));
        _cancelIdleTimer(); // no idle hint while actively scanning

      case ScannerState.processing:
        _enqueue(ScannerSpeech.processing(_l10n));

      case ScannerState.result:
        EarconService.instance.play(EarconEvent.scanSuccess);
        // Result speech is handled by the result caller with denominationResult().
        // Reset idle so the user gets a hint if they keep the camera open.
        _resetIdleTimer();

      case ScannerState.previewing:
        // Returned from scan/result: fire fail earcon only if scan gave no result.
        if (prev == ScannerState.scanning || prev == ScannerState.processing) {
          EarconService.instance.play(EarconEvent.scanFail);
        }
        if (prev == ScannerState.paused) {
          _enqueue(ScannerSpeech.previewResumed(_l10n));
        }
        _startIdleTimer();

      case ScannerState.paused:
        _enqueue(ScannerSpeech.previewFrozen(_l10n));
        _cancelIdleTimer();

      case ScannerState.idle:
        _cancelIdleTimer();
    }

  }

  // ── Gesture handlers ───────────────────────────────────────────────────────

  void _onPanEnd(DragEndDetails d) {
    final v  = d.velocity.pixelsPerSecond;
    final ax = v.dx.abs();
    final ay = v.dy.abs();
    if (ax < _minVelocity && ay < _minVelocity) return;

    if (ax >= ay) {
      if (ay / ax > _maxCrossRatio) return;
      v.dx > 0 ? widget.onNavigate(0) : widget.onNavigate(2);
    } else {
      if (ax / ay > _maxCrossRatio) return;
      if (v.dy < 0) _toggleFlash();
    }
  }

  void _onDoubleTap() {
    final n = ref.read(scannerStateProvider.notifier);
    final s = ref.read(scannerStateProvider);
    if (s == ScannerState.previewing) {
      HapticFeedback.mediumImpact();
      n.startScanning();
    } else if (s == ScannerState.paused) {
      HapticFeedback.lightImpact();
      n.resumePreview();
    }
  }

  void _toggleFlash() {
    final settings = ref.read(appSettingsProvider);
    final next     = !settings.useFlashlight;
    ref.read(appSettingsProvider.notifier).toggleFlashlight(next);
    ref.read(cameraControllerProvider.notifier).setFlash(next);
    _enqueue(ScannerSpeech.flashToggled(_l10n, next));
  }
}


class _IdlePlaceholder extends StatelessWidget {
  const _IdlePlaceholder({required this.l10n, required this.isDark});
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.currency_exchange_rounded,
                size: 56,
                color: isDark
                    ? const Color(0xFF4A5568)
                    : const Color(0xFFB0B8C4)),
            const SizedBox(height: 16),
            Text(l10n.tapToScan,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF8A9BB0)
                      : const Color(0xFF7A8899),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(
            color: AppColors.accentBlue, strokeWidth: 3),
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
              const Icon(Icons.no_photography_outlined,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Camera unavailable',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.lightOnSurface,
                  )),
              const SizedBox(height: 6),
              Text(error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                  )),
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
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pause_circle_outline_rounded,
                  size: 72, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(height: 12),
              Text(l10n.paused,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(l10n.doubleTapToResume,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55), fontSize: 13)),
            ],
          ),
        ),
      );
}
