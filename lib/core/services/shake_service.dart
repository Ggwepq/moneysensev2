import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

// ---------------------------------------------------------------------------
// Shake detection parameters
// ---------------------------------------------------------------------------
//
// HOW IT WORKS
// 1. Sample accelerometer at ~50 Hz.
// 2. Remove gravity with a low-pass filter → only dynamic acceleration remains.
// 3. Compute resultant magnitude of the dynamic vector.
// 4. A single "jolt" is counted when magnitude ≥ _threshold.
// 5. Jolts are debounced by _eventCooldown so one physical shake = one event.
// 6. The callback fires only when _requiredShakes jolts occur within _window ms.
// 7. The callback is itself throttled by _callbackCooldown to prevent retriggering.
//
// THRESHOLD RATIONALE
// Earth gravity: 9.8 m/s².  Walking dynamic peak: 3–6 m/s².
// Putting a phone down hard: ~8 m/s².
// Intentional wrist shake:  12–25 m/s².
// _threshold = 15.0 sits above all incidental motion.

/// Detects intentional shake gestures using the device accelerometer.
///
/// Start with [start] and stop with [stop].
/// The [onShake] callback is guaranteed to be called on the UI isolate.
class ShakeService {
  // ── Tuning ────────────────────────────────────────────────────────────────
  static const double _threshold = 15.0; // m/s² dynamic magnitude
  static const int _requiredShakes = 2; // jolts needed in window
  static const int _window = 800; // ms — confirmation window
  static const int _eventCooldown = 150; // ms — debounce per jolt
  static const int _callbackCooldown = 1200; // ms — min time between callbacks
  static const double _alpha = 0.85; // low-pass filter constant

  // ── State ─────────────────────────────────────────────────────────────────
  StreamSubscription<AccelerometerEvent>? _sub;
  VoidCallback? _onShake;

  double _gx = 0, _gy = 0, _gz = 0; // gravity estimate
  final List<int> _events = []; // recent jolt timestamps (ms)
  int _lastJoltMs = 0;
  int _lastFireMs = 0;
  bool _running = false;

  // ── Public API ─────────────────────────────────────────────────────────────

  bool get isRunning => _running;

  /// Begin listening.  Safe to call multiple times — subsequent calls are no-ops.
  void start(VoidCallback onShake) {
    if (_running) return;
    _running = true;
    _onShake = onShake;

    _sub =
        accelerometerEventStream(
          samplingPeriod: const Duration(milliseconds: 20),
        ).listen(
          _tick,
          onError: (_) {
            /* accelerometer unavailable on this device — ignore */
          },
          cancelOnError: false,
        );
  }

  /// Stop listening.  Safe to call when already stopped.
  void stop() {
    _sub?.cancel();
    _sub = null;
    _onShake = null;
    _running = false;
    _events.clear();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _tick(AccelerometerEvent e) {
    // Low-pass filter extracts gravity
    _gx = _alpha * _gx + (1 - _alpha) * e.x;
    _gy = _alpha * _gy + (1 - _alpha) * e.y;
    _gz = _alpha * _gz + (1 - _alpha) * e.z;

    // Dynamic acceleration (subtract gravity)
    final dx = e.x - _gx;
    final dy = e.y - _gy;
    final dz = e.z - _gz;
    final mag = math.sqrt(dx * dx + dy * dy + dz * dz);

    if (mag < _threshold) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    // Debounce: one physical jolt → one event
    if (now - _lastJoltMs < _eventCooldown) return;
    _lastJoltMs = now;

    // Record and prune events outside the window
    _events.add(now);
    _events.removeWhere((t) => now - t > _window);

    // Need enough jolts in the window
    if (_events.length < _requiredShakes) return;

    // Callback cooldown
    if (now - _lastFireMs < _callbackCooldown) return;

    _lastFireMs = now;
    _events.clear();

    // Always invoke on the UI thread
    _onShake?.call();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Singleton [ShakeService] scoped to the app lifetime.
/// Automatically stopped when the provider is disposed.
final shakeServiceProvider = Provider<ShakeService>((ref) {
  final svc = ShakeService();
  ref.onDispose(svc.stop);
  return svc;
});
