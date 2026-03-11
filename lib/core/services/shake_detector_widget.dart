import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../features/settings/presentation/providers/settings_provider.dart';
import 'earcon_service.dart';
import 'shake_service.dart';

/// Drives [ShakeService] from the widget tree.
///
/// On a confirmed shake:
///   1. A short haptic pulse (mediumImpact) fires immediately.
///   2. If the device supports the vibration package a 60 ms motor buzz
///      follows: gives a tactile "thud" distinct from normal HapticFeedback.
///   3. The navigator pops the top route (or executes [onShake] if provided).
///
/// Lifecycle:
///   shakeToGoBack OFF  → accelerometer is fully stopped (zero CPU overhead).
///   App backgrounded   → accelerometer stopped.
///   App foregrounded   → accelerometer restarted if setting is ON.
///   inactive (nav-bar) → do nothing (mirrors camera policy).
class ShakeDetectorWidget extends ConsumerStatefulWidget {
  const ShakeDetectorWidget({
    super.key,
    required this.child,
    this.onShake,
  });

  final Widget child;

  /// Override the default pop behaviour.  Receives the standard go-back
  /// logic if null.
  final VoidCallback? onShake;

  @override
  ConsumerState<ShakeDetectorWidget> createState() =>
      _ShakeDetectorWidgetState();
}

class _ShakeDetectorWidgetState extends ConsumerState<ShakeDetectorWidget>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(shakeServiceProvider).stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        ref.read(shakeServiceProvider).stop();
        break;
      case AppLifecycleState.resumed:
        _sync();
        break;
      case AppLifecycleState.inactive:
        break; // nav-bar swipe: not a real background event
    }
  }

  // ── Settings sync ──────────────────────────────────────────────────────────

  void _sync() {
    final enabled = ref.read(appSettingsProvider).shakeToGoBack;
    final svc    = ref.read(shakeServiceProvider);
    if (enabled && !svc.isRunning) {
      svc.start(_handleShake);
    } else if (!enabled && svc.isRunning) {
      svc.stop();
    }
  }

  // ── Shake handler ──────────────────────────────────────────────────────────

  Future<void> _handleShake() async {
    // 1. Immediate haptic click (works on all devices)
    HapticFeedback.mediumImpact();

    // 2. Motor vibration: short, distinct "thud" that confirms the gesture.
    //    60 ms is long enough to feel intentional but short enough not to
    //    startle.  We check hasVibrator so nothing explodes on devices/emulators
    //    that lack the motor.
    try {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(duration: 60, amplitude: 200);
      }
    } catch (_) {
      // Vibration plugin not available on this device: silently ignore.
    }

    // 3. Navigate
    EarconService.instance.play(EarconEvent.navBack);
    if (widget.onShake != null) {
      widget.onShake!();
      return;
    }
    if (mounted) {
      Navigator.of(context, rootNavigator: false).maybePop();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(
        appSettingsProvider.select((s) => s.shakeToGoBack));
    final svc = ref.read(shakeServiceProvider);

    if (enabled && !svc.isRunning) {
      svc.start(_handleShake);
    } else if (!enabled && svc.isRunning) {
      svc.stop();
    }

    return widget.child;
  }
}
