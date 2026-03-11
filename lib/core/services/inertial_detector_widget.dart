import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../features/scanner/presentation/screens/scanner_screen.dart'
    show routeObserverProvider;
import '../../features/settings/presentation/providers/settings_provider.dart';
import 'earcon_service.dart';
import 'inertial_service.dart';

// Connects InertialService to the navigator and the app lifecycle.
// Uses RouteAware to pause tilt navigation when another screen is on top.

class InertialDetectorWidget extends ConsumerStatefulWidget {
  const InertialDetectorWidget({
    super.key,
    required this.child,
    required this.onTiltLeft,
    required this.onTiltRight,
  });

  final Widget child;
  final VoidCallback onTiltLeft;
  final VoidCallback onTiltRight;

  @override
  ConsumerState<InertialDetectorWidget> createState() =>
      _InertialDetectorWidgetState();
}

class _InertialDetectorWidgetState
    extends ConsumerState<InertialDetectorWidget>
    with WidgetsBindingObserver, RouteAware {

  bool _isActive   = true;   // false while another route is on top
  bool _inCooldown = false;  // true briefly after returning from a sub-screen
  Timer? _cooldownTimer;

  RouteObserver<ModalRoute<void>>? _routeObserver;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes so we can pause/resume the sensor
    final observer = ref.read(routeObserverProvider);
    if (_routeObserver != observer) {
      _routeObserver?.unsubscribe(this);
      _routeObserver = observer;
      final route = ModalRoute.of(context);
      if (route != null) observer.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _routeObserver?.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    ref.read(inertialServiceProvider).stop();
    super.dispose();
  }

  // ── RouteAware ────────────────────────────────────────────────────────────

  /// Another route was pushed on top of us: pause the sensor.
  @override
  void didPushNext() {
    _isActive = false;
    ref.read(inertialServiceProvider).pause();
  }

  /// We're back on top: resume the sensor with a short cooldown so the
  /// return-tilt doesn't immediately trigger a second navigation.
  @override
  void didPopNext() {
    _isActive   = true;
    _inCooldown = true;
    ref.read(inertialServiceProvider).resume();

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _inCooldown = false);
    });
  }

  // ── App lifecycle ──────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        ref.read(inertialServiceProvider).stop();
        break;
      case AppLifecycleState.resumed:
        _sync();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  // ── Sensor sync ───────────────────────────────────────────────────────────

  void _sync() {
    final enabled = ref.read(appSettingsProvider).inertialNavigation;
    final svc     = ref.read(inertialServiceProvider);
    if (enabled && !svc.isRunning) {
      svc.start(onTiltLeft: _handleLeft, onTiltRight: _handleRight);
    } else if (!enabled && svc.isRunning) {
      svc.stop();
    }
  }

  // ── Tilt handlers ──────────────────────────────────────────────────────────
  //
  // Guard with _isActive and _inCooldown so callbacks that fire while we are
  // transitioning back from a sub-screen are silently ignored.

  void _handleLeft() {
    if (!_isActive || _inCooldown || !mounted) return;
    EarconService.instance.play(EarconEvent.navForward);
    widget.onTiltLeft();
    _vibrate();
  }

  void _handleRight() {
    if (!_isActive || _inCooldown || !mounted) return;
    EarconService.instance.play(EarconEvent.navForward);
    widget.onTiltRight();
    _vibrate();
  }

  void _vibrate() {
    HapticFeedback.lightImpact();
    // Vibration.hasVibrator is async: run it detached so it never blocks nav
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(duration: 40, amplitude: 160);
    }).catchError((_) {});
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // React to setting changes mid-session
    final enabled = ref.watch(
        appSettingsProvider.select((s) => s.inertialNavigation));
    final svc = ref.read(inertialServiceProvider);

    if (enabled && !svc.isRunning) {
      svc.start(onTiltLeft: _handleLeft, onTiltRight: _handleRight);
    } else if (!enabled && svc.isRunning) {
      svc.stop();
    }

    return widget.child;
  }
}
