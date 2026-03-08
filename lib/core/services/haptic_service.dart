import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

// ---------------------------------------------------------------------------
// HapticService — named semantic haptic patterns
// ---------------------------------------------------------------------------
//
// INTENSITY LEVELS — designed to be clearly perceptibly different
//
// ┌──────────────┬────────────────────────────────────────────────────────────┐
// │   subtle     │ Flutter HapticFeedback API only — no motor.               │
// │              │ The lightest possible feedback; almost unnoticeable.       │
// ├──────────────┼────────────────────────────────────────────────────────────┤
// │   medium     │ Short single motor pulse (80ms / amplitude 200).          │
// │              │ Clearly felt, clearly distinct from subtle.               │
// ├──────────────┼────────────────────────────────────────────────────────────┤
// │   strong     │ Rich multi-pulse PATTERN — long and distinct.             │
// │              │ Each event type has a unique pattern so the user can      │
// │              │ recognise what happened by feel alone, without audio.     │
// │              │ Duration is 3–5× longer than medium to be unmistakable.   │
// └──────────────┴────────────────────────────────────────────────────────────┘
//
// STRONG PATTERN LEGEND
//   scanSuccess:        ██ ░ ████  (short-pause-long)   = "got it"
//   scanError:          ██ ██ ██   (triple-short)        = "bad / repeat"
//   navigate:           ████       (single medium-long)  = "moved"
//   toggle:             █          (single short)        = "changed"
//   denominationResult: ██ ░ ████  (same as scanSuccess for now)

abstract final class HapticService {

  // ── Named semantic events ──────────────────────────────────────────────────

  /// Denomination successfully identified.
  static Future<void> scanSuccess({
    required bool enabled,
    required HapticIntensity intensity,
  }) async {
    if (!enabled) return;
    switch (intensity) {
      case HapticIntensity.subtle:
        HapticFeedback.mediumImpact();

      case HapticIntensity.medium:
        // Single firm pulse — clearly felt
        await _pulse(duration: 80, amplitude: 200);

      case HapticIntensity.strong:
        // Short–pause–long: a recognisable "got it" rhythm
        await _pattern(
          pattern:    [0,  60, 100, 180],
          intensities: [0, 220,   0, 255],
        );
    }
  }

  /// Scan or camera error.
  static Future<void> scanError({
    required bool enabled,
    required HapticIntensity intensity,
  }) async {
    if (!enabled) return;
    switch (intensity) {
      case HapticIntensity.subtle:
        HapticFeedback.lightImpact();

      case HapticIntensity.medium:
        // Two short pulses — clearly "wrong"
        await _pattern(
          pattern:    [0, 50, 60, 50],
          intensities: [0, 200,  0, 200],
        );

      case HapticIntensity.strong:
        // Triple short sharp bursts — unmistakably "error"
        await _pattern(
          pattern:    [0,  50,  50,  50,  50,  50],
          intensities: [0, 255,   0, 255,   0, 255],
        );
    }
  }

  /// Screen pushed or popped.
  static Future<void> navigate({
    required bool enabled,
    required HapticIntensity intensity,
  }) async {
    if (!enabled) return;
    switch (intensity) {
      case HapticIntensity.subtle:
        HapticFeedback.selectionClick();

      case HapticIntensity.medium:
        await _pulse(duration: 55, amplitude: 180);

      case HapticIntensity.strong:
        // Single solid pulse, longer than medium
        await _pulse(duration: 120, amplitude: 230);
    }
  }

  /// Toggle / selector tapped.
  static Future<void> toggle({
    required bool enabled,
    required HapticIntensity intensity,
  }) async {
    if (!enabled) return;
    switch (intensity) {
      case HapticIntensity.subtle:
        HapticFeedback.selectionClick();

      case HapticIntensity.medium:
        HapticFeedback.selectionClick();
        await _pulse(duration: 30, amplitude: 160);

      case HapticIntensity.strong:
        await _pulse(duration: 60, amplitude: 200);
    }
  }

  /// Rich haptic for denomination result.
  /// Same as [scanSuccess] for now; [denomination] reserved for future
  /// per-bill pulse-count encoding.
  static Future<void> denominationResult({
    required bool enabled,
    required HapticIntensity intensity,
    int denomination = 0,
  }) =>
      scanSuccess(enabled: enabled, intensity: intensity);

  // ── Motor primitives ───────────────────────────────────────────────────────

  /// Single motor vibration pulse.
  static Future<void> _pulse({
    int duration = 80,
    int amplitude = 200,
  }) async {
    try {
      final hasVibe = await Vibration.hasVibrator() ?? false;
      if (!hasVibe) return;
      final hasAmplitude = await Vibration.hasAmplitudeControl() ?? false;
      if (hasAmplitude) {
        Vibration.vibrate(duration: duration, amplitude: amplitude);
      } else {
        Vibration.vibrate(duration: duration);
      }
    } catch (_) {}
  }

  /// Multi-step motor pattern.
  /// [pattern] alternates: wait(ms), vibrate(ms), wait, vibrate …
  /// [intensities] must match [pattern] length (0 = off, 1–255 = intensity).
  static Future<void> _pattern({
    required List<int> pattern,
    required List<int> intensities,
  }) async {
    try {
      final hasVibe = await Vibration.hasVibrator() ?? false;
      if (!hasVibe) return;
      final hasAmplitude = await Vibration.hasAmplitudeControl() ?? false;
      if (hasAmplitude) {
        Vibration.vibrate(pattern: pattern, intensities: intensities);
      } else {
        // Fallback: fire the pattern without amplitude control
        Vibration.vibrate(pattern: pattern);
      }
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final hapticIntensityProvider = Provider<HapticIntensity>((ref) =>
    ref.watch(appSettingsProvider.select((s) => s.hapticIntensity)));

final hapticEnabledProvider = Provider<bool>((ref) =>
    ref.watch(appSettingsProvider.select((s) => s.hapticFeedback)));
