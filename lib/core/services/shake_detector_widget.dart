import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../features/settings/presentation/providers/settings_provider.dart';
import 'shake_service.dart';

/// Wraps the widget tree and drives [ShakeService] based on the user's
/// "Shake to Go Back" preference.
///
/// Placement: wrap [MaterialApp] (or the root [HomeShell]) so the navigator
/// key is accessible.  Provide [navigatorKey] so the widget can call
/// [NavigatorState.maybePop] from outside the widget tree.
///
/// Behaviour:
///   • shakeToGoBack = OFF → service is stopped.  Zero CPU overhead.
///   • shakeToGoBack = ON  → service runs; a confirmed shake calls
///     [Navigator.of(context).maybePop()], which pops the top route if
///     one exists (no-op on the home screen).
///   • App backgrounded    → service is stopped (WidgetsBindingObserver).
///   • App foregrounded    → service is restarted if setting is still ON.
///
/// Future extensibility: expose the [onShake] callback so callers can do
/// anything on shake (e.g. force-scan, dismiss a dialog).
class ShakeDetectorWidget extends ConsumerStatefulWidget {
  const ShakeDetectorWidget({super.key, required this.child, this.onShake});

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
        break; // nav-bar swipe — not a real background event
    }
  }

  // ── Settings sync ──────────────────────────────────────────────────────────

  void _sync() {
    final enabled = ref.read(appSettingsProvider).shakeToGoBack;
    final svc = ref.read(shakeServiceProvider);
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

    // 2. Motor vibration — short, distinct "thud" that confirms the gesture.
    //    60 ms is long enough to feel intentional but short enough not to
    //    startle.  We check hasVibrator so nothing explodes on devices/emulators
    //    that lack the motor.
    try {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(duration: 60, amplitude: 200);
      }
    } catch (_) {
      // Vibration plugin not available on this device — silently ignore.
    }

    // 3. Navigate
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
      appSettingsProvider.select((s) => s.shakeToGoBack),
    );
    final svc = ref.read(shakeServiceProvider);

    if (enabled && !svc.isRunning) {
      svc.start(_handleShake);
    } else if (!enabled && svc.isRunning) {
      svc.stop();
    }

    return widget.child;
  }
}
