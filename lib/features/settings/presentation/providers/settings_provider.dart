import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/settings_storage.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/vision_config.dart';

// ---------------------------------------------------------------------------
// SharedPreferences provider — seeded in main() before runApp
// ---------------------------------------------------------------------------

/// Holds the [SharedPreferences] instance loaded at startup.
///
/// Overridden in [main] via:
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)])
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('sharedPreferencesProvider not initialised'),
);

// ---------------------------------------------------------------------------
// Settings provider
// ---------------------------------------------------------------------------

/// Global settings state — persisted to [SharedPreferences] on every change.
final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AppSettingsNotifier extends Notifier<AppSettings> {
  late final SettingsStorage _storage;

  /// Last non-zero timer value so toggling the switch back on restores it.
  /// Loaded from prefs on startup and saved whenever it changes.
  int _lastTimerSeconds = 20;

  @override
  AppSettings build() {
    final prefs = ref.read(sharedPreferencesProvider);
    _storage = SettingsStorage(prefs);
    _lastTimerSeconds = _storage.loadLastTimerSeconds(fallback: 20);
    return _storage.load();         // hydrate from disk — synchronous
  }

  // ── Internal helper — update state + persist in one call ─────────────────

  void _update(AppSettings next) {
    state = next;
    _storage.save(next);
  }

  // ── Theme ──────────────────────────────────────────────────────────────
  void setThemeMode(AppThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  // ── Language ───────────────────────────────────────────────────────────
  void setLanguage(AppLanguage lang) =>
      _update(state.copyWith(language: lang));

  // ── Font ───────────────────────────────────────────────────────────────
  void setFontScale(double scale) =>
      _update(state.copyWith(fontScale: scale.clamp(0.8, 2.0)));

  // ── Scanning ───────────────────────────────────────────────────────────
  void toggleFrontCamera(bool value) =>
      _update(state.copyWith(useFrontCamera: value));

  void toggleFlashlight(bool value) =>
      _update(state.copyWith(useFlashlight: value));

  void toggleDenominationVibration(bool value) =>
      _update(state.copyWith(denominationVibration: value));

  // ── Navigation ─────────────────────────────────────────────────────────
  void toggleShakeToGoBack(bool value) =>
      _update(state.copyWith(shakeToGoBack: value));

  /// Flipping the timer toggle on/off.
  void toggleGoBackTimer(bool enabled) {
    if (enabled) {
      _update(state.copyWith(
        goBackTimerSeconds: _lastTimerSeconds.clamp(5, 60),
      ));
    } else {
      if (state.goBackTimerSeconds > 0) {
        _lastTimerSeconds = state.goBackTimerSeconds;
        _storage.saveLastTimerSeconds(_lastTimerSeconds);
      }
      _update(state.copyWith(goBackTimerSeconds: 0));
    }
  }

  /// Picking a specific timer value from the picker.
  void setGoBackTimer(int seconds) {
    final clamped = seconds.clamp(5, 60);
    _lastTimerSeconds = clamped;
    _storage.saveLastTimerSeconds(_lastTimerSeconds);
    _update(state.copyWith(goBackTimerSeconds: clamped));
  }

  void toggleGesturalNavigation(bool value) =>
      _update(state.copyWith(gesturalNavigation: value));

  void toggleInertialNavigation(bool value) =>
      _update(state.copyWith(inertialNavigation: value));

  // ── Accessibility ──────────────────────────────────────────────────────

  /// Setting the vision profile also applies that profile's recommended
  /// TTS verbosity and haptic intensity as new defaults — unless the user
  /// has already customised those values, in which case we leave them.
  /// For simplicity we always apply the profile defaults on profile change;
  /// the user can adjust again immediately after.
  void setVisionProfile(VisionProfile profile) {
    final config = VisionConfig.from(profile);
    _update(state.copyWith(
      visionProfile:   profile,
      ttsVerbosity:    config.defaultTtsVerbosity,
      hapticIntensity: config.defaultHapticIntensity,
    ));
  }

  void toggleTts(bool value) =>
      _update(state.copyWith(ttsEnabled: value));

  void setTtsVerbosity(TtsVerbosity verbosity) =>
      _update(state.copyWith(ttsVerbosity: verbosity));

  void toggleHapticFeedback(bool value) =>
      _update(state.copyWith(hapticFeedback: value));

  void setHapticIntensity(HapticIntensity intensity) =>
      _update(state.copyWith(hapticIntensity: intensity));
}
