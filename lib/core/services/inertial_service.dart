import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

// Detects phone tilt using the raw accelerometer, not the gyroscope.
// The X axis dominates when the phone tilts left or right. The phone must hold
// the tilt for 1 second before the callback fires, and a flat-guard rejects
// navigation when the phone is lying on a surface.
//

enum _TiltOrientation { portrait, landscapeLeft, landscapeRight }

/// Detects intentional left/right tilt by checking whether the phone is
/// held in landscape orientation for at least [_holdDuration] seconds.
class InertialService {
  // ── Tuning ────────────────────────────────────────────────────────────────
  /// |z| above this → phone is face-up/face-down on a table → ignore.
  static const double _flatThreshold   = 8.0;  // m/s²

  /// |x| must exceed |y| by this margin to count as landscape.
  static const double _dominanceMargin = 5.0;  // m/s²

  /// How long the landscape orientation must be held before firing.
  static const int    _holdDurationMs  = 1000; // 1 second

  /// Minimum gap between consecutive callback fires.
  static const int    _cooldownMs      = 1500; // 1.5 seconds

  // ── State ─────────────────────────────────────────────────────────────────
  StreamSubscription<AccelerometerEvent>? _sub;
  VoidCallback? _onTiltLeft;
  VoidCallback? _onTiltRight;

  _TiltOrientation _currentOrientation = _TiltOrientation.portrait;
  Timer?  _holdTimer;
  int     _lastFireMs = 0;
  bool    _running    = false;

  // For tutorial live display
  double _rawX = 0, _rawZ = 0;

  // ── Public API ─────────────────────────────────────────────────────────────

  bool get isRunning => _running;

  /// Begin listening.  Subsequent calls while running are no-ops.
  void start({
    required VoidCallback onTiltLeft,
    required VoidCallback onTiltRight,
  }) {
    if (_running) return;
    _running      = true;
    _onTiltLeft   = onTiltLeft;
    _onTiltRight  = onTiltRight;
    _currentOrientation = _TiltOrientation.portrait;

    _sub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 50), // 20 Hz is enough
    ).listen(
      _tick,
      onError: (_) {},
      cancelOnError: false,
    );
  }

  /// Pause the stream without resetting state (used when navigating away).
  void pause() => _sub?.pause();

  /// Resume the stream (used when returning to the home screen).
  void resume() => _sub?.resume();

  /// Stop listening entirely and reset all state.
  void stop() {
    _holdTimer?.cancel();
    _holdTimer  = null;
    _sub?.cancel();
    _sub        = null;
    _onTiltLeft = null;
    _onTiltRight = null;
    _currentOrientation = _TiltOrientation.portrait;
    _running    = false;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _tick(AccelerometerEvent e) {
    _rawX = e.x;
    _rawZ = e.z;

    _TiltOrientation newOrientation;

    // 1. Flat-phone guard
    if (e.z.abs() > _flatThreshold) {
      newOrientation = _TiltOrientation.portrait;
    } else {
      final absX = e.x.abs();
      final absY = e.y.abs();

      // 2. Landscape if X-axis clearly dominates
      if (absX > absY + _dominanceMargin) {
        // x > 0 means right edge is down = phone tilted left
        // x < 0 means left edge is down  = phone tilted right
        newOrientation = e.x > 0
            ? _TiltOrientation.landscapeLeft
            : _TiltOrientation.landscapeRight;
      } else {
        newOrientation = _TiltOrientation.portrait;
      }
    }

    // 3. Only act if orientation changed
    if (newOrientation == _currentOrientation) return;
    _currentOrientation = newOrientation;

    // Cancel any pending hold timer when orientation changes
    _holdTimer?.cancel();
    _holdTimer = null;

    // Back to portrait → no navigation
    if (newOrientation == _TiltOrientation.portrait) return;

    // 4. Start hold-confirmation timer
    _holdTimer = Timer(Duration(milliseconds: _holdDurationMs), () {
      // Verify still in the same orientation and not in cooldown
      if (_currentOrientation != newOrientation) return;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastFireMs < _cooldownMs) return;
      _lastFireMs = now;

      if (newOrientation == _TiltOrientation.landscapeLeft) {
        _onTiltLeft?.call();
      } else {
        _onTiltRight?.call();
      }
    });
  }

  // ── Tutorial live display helpers ─────────────────────────────────────────

  /// Raw accelerometer X (left/right tilt gravity component).
  double get rawX => _rawX;

  /// Raw accelerometer Z (flat detection).
  double get rawZ => _rawZ;

  /// Whether the phone is currently considered flat.
  bool get isFlat => _rawZ.abs() > _flatThreshold;

  /// Current detected orientation.
  // ignore: library_private_types_in_public_api
  _TiltOrientation get orientation => _currentOrientation;
}


/// Singleton [InertialService] scoped to the app lifetime.
final inertialServiceProvider = Provider<InertialService>((ref) {
  final svc = InertialService();
  ref.onDispose(svc.stop);
  return svc;
});
