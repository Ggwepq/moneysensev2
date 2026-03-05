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

  void setGoBackTimer(int seconds) =>
      state = state.copyWith(goBackTimerSeconds: seconds);

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
