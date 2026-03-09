import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

// ---------------------------------------------------------------------------
// HapticService
// ---------------------------------------------------------------------------
//
// INTENSITY LEVELS — designed to be clearly perceptibly different
//
// subtle   Flutter HapticFeedback only. Lightest possible, no motor.
// medium   Single motor pulse (100ms / amplitude 200). Clearly felt.
// strong   Multi-pulse pattern unique per event. 3-5x longer than medium.
//
// DEVICE CAPABILITY CACHING
// hasVibrator and hasAmplitudeControl are async platform calls (~10ms each).
// We cache them on first use so subsequent calls are synchronous boolean checks.
// This means patterns fire with correct timing and no async delay.
//
// STRONG PATTERNS
//   scanSuccess:  short-pause-long ("got it")
//   scanError:    triple short burst ("bad, retry")
//   navigate:     single solid long pulse ("moved")
//   toggle:       medium single pulse ("changed")

abstract final class HapticService {

  // Cached device capabilities — null means not yet checked
  static bool? _hasVibrator;
  static bool? _hasAmplitude;

  /// Call once at app startup (e.g. in main.dart or ttsInitProvider).
  /// Safe to call multiple times — subsequent calls are instant no-ops.
  static Future<void> init() async {
    _hasVibrator  ??= await Vibration.hasVibrator() ?? false;
    _hasAmplitude ??= await Vibration.hasAmplitudeControl() ?? false;
  }

  // ── Named semantic events ──────────────────────────────────────────────────

  static Future<void> scanSuccess({
    required bool enabled,
    required HapticIntensity intensity,
  }) async {
    if (!enabled) return;
    await init();
    switch (intensity) {
      case HapticIntensity.subtle:
        HapticFeedback.mediumImpact();
      case HapticIntensity.medium:
        _pulse(duration: 100, amplitude: 200);
      case HapticIntensity.strong:
        // Short-pause-long: a recognisable "got it" rhythm
        _pattern(pattern: [0, 60, 100, 180], intensities: [0, 220, 0, 255]);
    }
  }

  static Future<void> scanError({
    required bool enabled,
    required HapticIntensity intensity,
  }) async {
    if (!enabled) return;
    await init();
    switch (intensity) {
      case HapticIntensity.subtle:
        HapticFeedback.lightImpact();
      case HapticIntensity.medium:
        _pattern(pattern: [0, 60, 60, 60], intensities: [0, 200, 0, 200]);
      case HapticIntensity.strong:
        // Triple short burst — unmistakably error
        _pattern(
          pattern:     [0,  60,  50,  60,  50,  60],
          intensities: [0, 255,   0, 255,   0, 255],
        );
    }
  }

  static Future<void> navigate({
    required bool enabled,
    required HapticIntensity intensity,
  }) async {
    if (!enabled) return;
    await init();
    switch (intensity) {
      case HapticIntensity.subtle:
        HapticFeedback.selectionClick();
      case HapticIntensity.medium:
        _pulse(duration: 70, amplitude: 180);
      case HapticIntensity.strong:
        _pulse(duration: 150, amplitude: 240);
    }
  }

  static Future<void> toggle({
    required bool enabled,
    required HapticIntensity intensity,
  }) async {
    if (!enabled) return;
    await init();
    switch (intensity) {
      case HapticIntensity.subtle:
        HapticFeedback.selectionClick();
      case HapticIntensity.medium:
        _pulse(duration: 50, amplitude: 160);
      case HapticIntensity.strong:
        _pulse(duration: 90, amplitude: 220);
    }
  }

  static Future<void> denominationResult({
    required bool enabled,
    required HapticIntensity intensity,
    int denomination = 0,
  }) => scanSuccess(enabled: enabled, intensity: intensity);

  // ── Motor primitives (synchronous after init) ──────────────────────────────

  static void _pulse({int duration = 80, int amplitude = 200}) {
    if (_hasVibrator != true) return;
    if (_hasAmplitude == true) {
      Vibration.vibrate(duration: duration, amplitude: amplitude);
    } else {
      Vibration.vibrate(duration: duration);
    }
  }

  static void _pattern({
    required List<int> pattern,
    required List<int> intensities,
  }) {
    if (_hasVibrator != true) return;
    if (_hasAmplitude == true) {
      Vibration.vibrate(pattern: pattern, intensities: intensities);
    } else {
      Vibration.vibrate(pattern: pattern);
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final hapticIntensityProvider = Provider<HapticIntensity>((ref) =>
    ref.watch(appSettingsProvider.select((s) => s.hapticIntensity)));

final hapticEnabledProvider = Provider<bool>((ref) =>
    ref.watch(appSettingsProvider.select((s) => s.hapticFeedback)));
