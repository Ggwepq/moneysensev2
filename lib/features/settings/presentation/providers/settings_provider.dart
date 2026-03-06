import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_settings.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Global settings state.
///
/// TODO: Wire up [SharedPreferences] persistence in the notifier.
final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AppSettingsNotifier extends Notifier<AppSettings> {
  /// Remembers the last non-zero timer value so toggling the switch back on
  /// restores it rather than jumping to 0.
  int _lastTimerSeconds = 20;

  @override
  AppSettings build() => const AppSettings();

  // ── Theme ──────────────────────────────────────────────────────────────
  void setThemeMode(AppThemeMode mode) =>
      state = state.copyWith(themeMode: mode);

  // ── Language ───────────────────────────────────────────────────────────
  void setLanguage(AppLanguage lang) =>
      state = state.copyWith(language: lang);

  // ── Font ───────────────────────────────────────────────────────────────
  void setFontScale(double scale) =>
      state = state.copyWith(fontScale: scale.clamp(0.8, 2.0));

  // ── Scanning ───────────────────────────────────────────────────────────
  void toggleFrontCamera(bool value) =>
      state = state.copyWith(useFrontCamera: value);

  void toggleFlashlight(bool value) =>
      state = state.copyWith(useFlashlight: value);

  void toggleDenominationVibration(bool value) =>
      state = state.copyWith(denominationVibration: value);

  // ── Navigation ─────────────────────────────────────────────────────────
  void toggleShakeToGoBack(bool value) =>
      state = state.copyWith(shakeToGoBack: value);

  /// Called when the timer toggle switch is flipped.
  /// - Turning ON  → restore [_lastTimerSeconds] (minimum 5).
  /// - Turning OFF → set to 0, persisting last value for restore.
  void toggleGoBackTimer(bool enabled) {
    if (enabled) {
      state = state.copyWith(
        goBackTimerSeconds: _lastTimerSeconds.clamp(5, 60),
      );
    } else {
      if (state.goBackTimerSeconds > 0) {
        _lastTimerSeconds = state.goBackTimerSeconds;
      }
      state = state.copyWith(goBackTimerSeconds: 0);
    }
  }

  /// Called when the user picks a specific value from the picker dialog.
  void setGoBackTimer(int seconds) {
    final clamped = seconds.clamp(5, 60);
    _lastTimerSeconds = clamped;
    state = state.copyWith(goBackTimerSeconds: clamped);
  }

  void toggleGesturalNavigation(bool value) =>
      state = state.copyWith(gesturalNavigation: value);

  void toggleInertialNavigation(bool value) =>
      state = state.copyWith(inertialNavigation: value);

  // ── Accessibility ──────────────────────────────────────────────────────
  void setVisionProfile(VisionProfile profile) =>
      state = state.copyWith(visionProfile: profile);

  void toggleTts(bool value) => state = state.copyWith(ttsEnabled: value);

  void toggleHapticFeedback(bool value) =>
      state = state.copyWith(hapticFeedback: value);
}
