import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/earcon_service.dart';
import '../../../../core/services/speech_scripts.dart';
import '../../../../core/services/tts_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/scanner_state.dart';
import '../../../../core/services/voice/voice_command_service.dart';
import '../providers/scanner_provider.dart';
import '../widgets/camera_viewfinder.dart';
import 'result_screen.dart';


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

  static const Duration _idleFirst  = Duration(seconds: 8);
  static const Duration _idleRepeat = Duration(seconds: 12);
  Timer? _idleTimer;

  bool _routeObscured = false;
  CameraController? _streamBoundController;

  // ── Helpers ────────────────────────────────────────────────────────────────

  TtsService get _tts => ref.read(ttsServiceProvider);

  void _enqueue(TtsMessage msg) {
    final s = ref.read(appSettingsProvider);
    _tts.enqueue(msg,
        enabled: s.ttsEnabled, currentVerbosity: s.ttsVerbosity);
  }

  AppLocalizations get _l10n =>
      AppLocalizations.of(ref.read(appSettingsProvider).isTagalog);

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
    _idleTimer?.cancel();
    ref.read(routeObserverProvider).unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    _routeObscured = true;
    _cancelIdleTimer();
    if (ref.read(cameraOpenProvider)) _suspend();
  }

  @override
  void didPopNext() {
    _routeObscured = false;
    if (ref.read(cameraOpenProvider)) {
      _resume();
      _startIdleTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        if (ref.read(cameraOpenProvider)) _suspend();
        break;
      case AppLifecycleState.resumed:
        if (ref.read(cameraOpenProvider) && !_routeObscured) _resume();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _suspend() {
    _cancelIdleTimer();
    _streamBoundController = null;
    ref.read(cameraControllerProvider.notifier).suspendCamera();
    ref.read(scannerStateProvider.notifier).suspendScanner();
  }

  void _resume() {
    final s = ref.read(appSettingsProvider);
    ref.read(cameraControllerProvider.notifier).resumeCamera(
      useFrontCamera: s.useFrontCamera,
      useFlash:       s.useFlashlight,
    );
    ref.read(scannerStateProvider.notifier).restoreScanner();
  }

  // ── Image stream ───────────────────────────────────────────────────────────

  void _maybeBindImageStream(CameraController ctrl) {
    if (_streamBoundController == ctrl) return;
    if (!ctrl.value.isInitialized)      return;
    if (ctrl.value.isStreamingImages)   return;
    _streamBoundController = ctrl;
    ctrl.startImageStream(_onFrame).catchError((_) {
      _streamBoundController = null;
    });
  }

  bool _autoFlashEvaluated = false;
  int  _darkFrames         = 0;

  void _onFrame(CameraImage image) {
    // 1. Process Frame for detection
    ref.read(scannerStateProvider.notifier).processFrame(image);

    // 2. Evaluate auto-flash if we haven't already this session
    if (!_autoFlashEvaluated && image.planes.isNotEmpty) {
      final s = ref.read(appSettingsProvider);
      if (!s.useFlashlight && !s.useFrontCamera) {
        _evaluateAutoFlash(image);
      } else {
        _autoFlashEvaluated = true; // Skip checking if flash is already on or using front cam
      }
    }
  }

  void _evaluateAutoFlash(CameraImage image) {
    final yPlane = image.planes[0].bytes;
    int sum = 0;
    
    // Sample ~400 pixels effectively
    final step = (yPlane.length / 400).ceil().clamp(1, yPlane.length);
    int count = 0;
    for (int i = 0; i < yPlane.length; i += step) {
      sum += yPlane[i];
      count++;
    }
    
    final avg = sum / count;
    
    // Threshold for "too dark"
    if (avg < 40) {
      _darkFrames++;
      if (_darkFrames >= 5) {
        _autoFlashEvaluated = true;
        _darkFrames = 0;
        ref.read(appSettingsProvider.notifier).toggleFlashlight(true);
        ref.read(cameraControllerProvider.notifier).setFlash(true);
        _enqueue(ScannerSpeech.flashToggled(_l10n, true));
      }
    } else {
      _autoFlashEvaluated = true;
      _darkFrames = 0;
    }
  }

  // ── Idle timer ─────────────────────────────────────────────────────────────

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleFirst, _onIdleFired);
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleFirst, _onIdleFired);
  }

  void _cancelIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  void _onIdleFired() {
    final s = ref.read(scannerStateProvider);
    if (s == ScannerState.previewing || s == ScannerState.scanning) {
      _enqueue(ScannerSpeech.idleHint(_l10n));
    }
    _idleTimer = Timer(_idleRepeat, _onIdleFired);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final s            = ref.watch(appSettingsProvider);
    final l10n         = AppLocalizations.of(s.isTagalog);
    final scannerState = ref.watch(scannerStateProvider);
    final cameraOpen   = ref.watch(cameraOpenProvider);
    final ctrlAsync    = ref.watch(cameraControllerProvider);
    final controller   = ctrlAsync.valueOrNull;

    // Bind image stream as soon as controller is ready
    if (controller != null && cameraOpen &&
        scannerState != ScannerState.paused) {
      _maybeBindImageStream(controller);
    }

    // Result screen takes over
    if (scannerState == ScannerState.result) {
      final result = ref.watch(detectionResultProvider);
      if (result != null) return ResultScreen(result: result);
    }

    ref.listen<ScannerState>(scannerStateProvider, (prev, next) {
      _onScannerStateChanged(prev ?? ScannerState.idle, next);
    });
    ref.listen<bool>(cameraOpenProvider, (prev, next) {
      _onCameraOpenChanged(prev ?? false, next);
    });

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    final statusLabel = switch (scannerState) {
      ScannerState.scanning   => l10n.scannerStatusScanning,
      ScannerState.centering  => l10n.scannerStatusCentering,
      ScannerState.processing => l10n.scannerStatusProcessing,
      _                       => null,
    };

    // Paused: hide the camera feed — looks like the idle/startup state
    final isPaused = scannerState == ScannerState.paused;
    Widget? previewChild;
    if (cameraOpen && !isPaused &&
        controller != null && controller.value.isInitialized) {
      previewChild = CameraPreview(controller);
    } else if (isPaused) {
      previewChild = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.camera_rounded, size: 80, color: isDark ? Colors.white12 : Colors.black12),
             const SizedBox(height: 16),
             Text(
               'SCANNER STANDBY',
               style: TextStyle(
                 color: isDark ? Colors.white24 : Colors.black26,
                 fontSize: 20,
                 fontWeight: FontWeight.w800,
                 letterSpacing: 4.0,
               ),
             ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanEnd: _onPanEnd,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: GestureDetector(
                    onDoubleTap: cameraOpen ? _onDoubleTap : null,
                    child: Semantics(
                      label: _viewfinderSemanticLabel(
                          scannerState, cameraOpen, l10n),
                      excludeSemantics: true,
                      child: CameraViewfinder(
                        scannerState:
                            cameraOpen ? scannerState : ScannerState.idle,
                        isDark:      isDark,
                        statusLabel: statusLabel,
                        child:       previewChild,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _viewfinderSemanticLabel(
      ScannerState state, bool cameraOpen, AppLocalizations l10n) {
    if (!cameraOpen) return l10n.scannerSemanticIdle;
    return switch (state) {
      ScannerState.idle       => l10n.scannerSemanticIdle,
      ScannerState.previewing => l10n.scannerSemanticReady,
      ScannerState.paused     => l10n.scannerSemanticPaused,
      ScannerState.scanning   => l10n.scannerStatusScanning,
      ScannerState.centering  => l10n.scannerStatusCentering,
      ScannerState.processing => l10n.scannerStatusProcessing,
      ScannerState.result     => l10n.scannerStatusResult,
    };
  }

  // ── State-change side-effects ──────────────────────────────────────────────

  void _onCameraOpenChanged(bool prev, bool next) {
    if (next == prev) return;
    if (next) {
      _autoFlashEvaluated = false;
      _darkFrames = 0;
      EarconService.instance.play(EarconEvent.cameraOpen);
      _enqueue(ScannerSpeech.cameraOpened(_l10n));
      _startIdleTimer();
      _streamBoundController = null;
    } else {
      EarconService.instance.play(EarconEvent.cameraClose);
      _enqueue(ScannerSpeech.cameraClosed(_l10n));
      _cancelIdleTimer();
      _streamBoundController = null;
    }
  }

  void _onScannerStateChanged(ScannerState prev, ScannerState next) {
    if (next == prev) return;
    switch (next) {
      case ScannerState.scanning:
        EarconService.instance.play(EarconEvent.scanStart);
        _enqueue(ScannerSpeech.scanStarted(_l10n));
        _cancelIdleTimer();
      case ScannerState.centering:
        HapticFeedback.selectionClick();
        break;
      case ScannerState.processing:
        _enqueue(ScannerSpeech.processing(_l10n));
        break;
      case ScannerState.result:
        EarconService.instance.play(EarconEvent.scanSuccess);
        _resetIdleTimer();
      case ScannerState.previewing:
        if (prev == ScannerState.scanning ||
            prev == ScannerState.processing) {
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

  // ── Gestures ───────────────────────────────────────────────────────────────

  void _onPanEnd(DragEndDetails d) {
    final v  = d.velocity.pixelsPerSecond;
    final ax = v.dx.abs();
    final ay = v.dy.abs();
    if (ax < _minVelocity && ay < _minVelocity) return;
    if (ax >= ay) {
      if (ay / ax > _maxCrossRatio) return;
      if (v.dx > 0) widget.onNavigate(0);
      else          widget.onNavigate(2);
    } else {
      if (ax / ay > _maxCrossRatio) return;
      if (v.dy < 0) _toggleFlash();
      else          _toggleVoice();
    }
  }

  /// Double-tap toggles pause/resume only.
  /// Scanning starts automatically when the camera opens.
  void _onDoubleTap() {
    final n = ref.read(scannerStateProvider.notifier);
    final s = ref.read(scannerStateProvider);
    if (s == ScannerState.paused) {
      HapticFeedback.lightImpact();
      n.resumePreview();
    } else if (s == ScannerState.scanning ||
               s == ScannerState.processing ||
               s == ScannerState.previewing) {
      HapticFeedback.mediumImpact();
      n.pausePreview();
    }
  }

  void _toggleFlash() {
    final settings = ref.read(appSettingsProvider);
    final next     = !settings.useFlashlight;
    ref.read(appSettingsProvider.notifier).toggleFlashlight(next);
    ref.read(cameraControllerProvider.notifier).setFlash(next);
    EarconService.instance.play(EarconEvent.flashToggled);
    _enqueue(ScannerSpeech.flashToggled(_l10n, next));
  }

  void _toggleVoice() {
    final status = ref.read(voiceCommandStatusProvider);
    final service = ref.read(voiceCommandServiceProvider);
    
    if (status == VoiceStatus.idle || status == VoiceStatus.error) {
      HapticFeedback.mediumImpact();
      service.startActiveListening(withPrompt: true);
    } else {
      HapticFeedback.lightImpact();
      service.stopListening();
    }
  }
}
