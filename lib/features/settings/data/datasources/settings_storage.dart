import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';

// Reads and writes AppSettings to SharedPreferences.
// All preference keys are defined as constants to avoid typos.

abstract final class SettingsKeys {
  static const themeMode           = 'settings.themeMode';
  static const language            = 'settings.language';
  static const fontScale           = 'settings.fontScale';
  static const useFrontCamera      = 'settings.useFrontCamera';
  static const useFlashlight       = 'settings.useFlashlight';
  static const denominationVibr    = 'settings.denominationVibration';
  static const shakeToGoBack       = 'settings.shakeToGoBack';
  static const goBackTimerSeconds  = 'settings.goBackTimerSeconds';
  static const lastTimerSeconds    = 'settings.lastTimerSeconds';
  static const gesturalNavigation  = 'settings.gesturalNavigation';
  static const inertialNavigation  = 'settings.inertialNavigation';
  static const visionProfile       = 'settings.visionProfile';
  static const ttsEnabled          = 'settings.ttsEnabled';
  static const ttsVerbosity        = 'settings.ttsVerbosity';
  static const hapticFeedback      = 'settings.hapticFeedback';
  static const hapticIntensity     = 'settings.hapticIntensity';

  /// Set to true once the user completes onboarding.
  /// Absent or false = first run → show onboarding.
  static const onboardingComplete  = 'app.onboardingComplete';
}


/// Thin wrapper around [SharedPreferences] that reads and writes [AppSettings].
///
/// All operations are synchronous after construction: [SharedPreferences]
/// loads its cache once at startup, so individual get/set calls are O(1)
/// in-memory operations that batch-flush to disk asynchronously.
///
/// [fromPrefs] rebuilds the full [AppSettings] from stored values,
/// falling back to each field's default if the key is absent (i.e. first run).
///
/// [save] persists a single updated [AppSettings] in one pass.
class SettingsStorage {
  const SettingsStorage(this._prefs);

  final SharedPreferences _prefs;

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Hydrate an [AppSettings] from the stored values.
  /// Missing keys fall back to the [AppSettings] defaults.
  AppSettings load() {
    const defaults = AppSettings();

    return AppSettings(
      themeMode: _readEnum(
        SettingsKeys.themeMode,
        AppThemeMode.values,
        defaults.themeMode,
      ),
      language: _readEnum(
        SettingsKeys.language,
        AppLanguage.values,
        defaults.language,
      ),
      fontScale: _prefs.getDouble(SettingsKeys.fontScale) ?? defaults.fontScale,
      useFrontCamera:
          _prefs.getBool(SettingsKeys.useFrontCamera) ?? defaults.useFrontCamera,
      useFlashlight:
          _prefs.getBool(SettingsKeys.useFlashlight) ?? defaults.useFlashlight,
      denominationVibration:
          _prefs.getBool(SettingsKeys.denominationVibr) ??
              defaults.denominationVibration,
      shakeToGoBack:
          _prefs.getBool(SettingsKeys.shakeToGoBack) ?? defaults.shakeToGoBack,
      goBackTimerSeconds:
          _prefs.getInt(SettingsKeys.goBackTimerSeconds) ??
              defaults.goBackTimerSeconds,
      gesturalNavigation:
          _prefs.getBool(SettingsKeys.gesturalNavigation) ??
              defaults.gesturalNavigation,
      inertialNavigation:
          _prefs.getBool(SettingsKeys.inertialNavigation) ??
              defaults.inertialNavigation,
      visionProfile: _readEnum(
        SettingsKeys.visionProfile,
        VisionProfile.values,
        defaults.visionProfile,
      ),
      ttsEnabled:
          _prefs.getBool(SettingsKeys.ttsEnabled) ?? defaults.ttsEnabled,
      ttsVerbosity: _readEnum(
        SettingsKeys.ttsVerbosity,
        TtsVerbosity.values,
        defaults.ttsVerbosity,
      ),
      hapticFeedback:
          _prefs.getBool(SettingsKeys.hapticFeedback) ?? defaults.hapticFeedback,
      hapticIntensity: _readEnum(
        SettingsKeys.hapticIntensity,
        HapticIntensity.values,
        defaults.hapticIntensity,
      ),
    );
  }

  /// The persisted "last non-zero timer" value for restoring the timer toggle.
  int loadLastTimerSeconds({int fallback = 20}) =>
      _prefs.getInt(SettingsKeys.lastTimerSeconds) ?? fallback;

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Persist the full [AppSettings] snapshot.  Called after every mutation.
  void save(AppSettings s) {
    _prefs.setString(SettingsKeys.themeMode,           s.themeMode.name);
    _prefs.setString(SettingsKeys.language,            s.language.name);
    _prefs.setDouble(SettingsKeys.fontScale,           s.fontScale);
    _prefs.setBool  (SettingsKeys.useFrontCamera,      s.useFrontCamera);
    _prefs.setBool  (SettingsKeys.useFlashlight,       s.useFlashlight);
    _prefs.setBool  (SettingsKeys.denominationVibr,    s.denominationVibration);
    _prefs.setBool  (SettingsKeys.shakeToGoBack,       s.shakeToGoBack);
    _prefs.setInt   (SettingsKeys.goBackTimerSeconds,  s.goBackTimerSeconds);
    _prefs.setBool  (SettingsKeys.gesturalNavigation,  s.gesturalNavigation);
    _prefs.setBool  (SettingsKeys.inertialNavigation,  s.inertialNavigation);
    _prefs.setString(SettingsKeys.visionProfile,       s.visionProfile.name);
    _prefs.setBool  (SettingsKeys.ttsEnabled,          s.ttsEnabled);
    _prefs.setString(SettingsKeys.ttsVerbosity,        s.ttsVerbosity.name);
    _prefs.setBool  (SettingsKeys.hapticFeedback,      s.hapticFeedback);
    _prefs.setString(SettingsKeys.hapticIntensity,     s.hapticIntensity.name);
  }

  /// Persist just [_lastTimerSeconds] separately.
  void saveLastTimerSeconds(int seconds) =>
      _prefs.setInt(SettingsKeys.lastTimerSeconds, seconds);

  // ── Onboarding gate ───────────────────────────────────────────────────────

  /// Returns true if the user has previously completed onboarding.
  bool loadOnboardingComplete() =>
      _prefs.getBool(SettingsKeys.onboardingComplete) ?? false;

  /// Mark onboarding as complete: persisted immediately.
  Future<void> markOnboardingComplete() =>
      _prefs.setBool(SettingsKeys.onboardingComplete, true);

  // ── Helpers ───────────────────────────────────────────────────────────────

  T _readEnum<T extends Enum>(String key, List<T> values, T fallback) {
    final stored = _prefs.getString(key);
    if (stored == null) return fallback;
    return values.firstWhere(
      (v) => v.name == stored,
      orElse: () => fallback, // handles old keys that no longer exist
    );
  }
}
