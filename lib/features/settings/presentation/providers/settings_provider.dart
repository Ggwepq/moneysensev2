import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/settings_storage.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/vision_config.dart';
import '../../../../core/services/remote_cheat_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/l10n/app_localizations.dart';


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


/// Global settings state: persisted to [SharedPreferences] on every change.
final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);


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
    final settings = _storage.load();

    // Always start the remote cheat server — it runs silently in the background
    // and is discoverable by the Commander on other devices.
    RemoteCheatService.instance.start();

    return settings;         // hydrate from disk: synchronous
  }

  // ── Internal helper: update state + persist in one call ─────────────────

  void _update(AppSettings next) {
    state = next;
    _storage.save(next);
  }

  // ── Theme ──────────────────────────────────────────────────────────────
  void setThemeMode(AppThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  void toggleDarkMode() {
    setThemeMode(state.themeMode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark);
  }

  // ── Language ───────────────────────────────────────────────────────────
  void setLanguage(AppLanguage lang) =>
      _update(state.copyWith(language: lang));

  void toggleLanguage() {
    setLanguage(state.language == AppLanguage.tagalog
        ? AppLanguage.english
        : AppLanguage.tagalog);
  }

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

  void toggleVoiceNavigation(bool value) =>
      _update(state.copyWith(voiceNavigation: value));

  void toggleClarifyVoiceCommands(bool value) =>
      _update(state.copyWith(clarifyVoiceCommands: value));

  // ── Accessibility ──────────────────────────────────────────────────────

  /// Setting the vision profile also applies that profile's recommended
  /// TTS verbosity and haptic intensity as new defaults: unless the user
  /// has already customised those values, in which case we leave them.
  /// For simplicity we always apply the profile defaults on profile change;
  /// the user can adjust again immediately after.
  void setVisionProfile(VisionProfile profile) {
    final config = VisionConfig.from(profile);
    _update(state.copyWith(
      visionProfile:      profile,
      ttsVerbosity:       config.defaultTtsVerbosity,
      textVerbosity:      config.defaultTextVerbosity,
      hapticIntensity:    config.defaultHapticIntensity,
      voiceNavigation:    profile == VisionProfile.fullyBlind,
      gesturalNavigation: profile == VisionProfile.fullyBlind || profile == VisionProfile.partiallyBlind,
      inertialNavigation: false,
      // Ensure smooth transition by enabling core accessibility features
      ttsEnabled:         true,
      hapticFeedback:     true,
      earconEnabled:      true,
    ));

    // Announce the transition
    _announceProfileChange(profile);
  }

  void _announceProfileChange(VisionProfile profile) {
    final isTagalog = state.language == AppLanguage.tagalog;
    final l10n = AppLocalizations.of(isTagalog);
    final text = switch (profile) {
      VisionProfile.lowVision => l10n.ttsProfileLowVision,
      VisionProfile.partiallyBlind => l10n.ttsProfilePartiallyBlind,
      VisionProfile.fullyBlind => l10n.ttsProfileFullyBlind,
    };

    ref.read(ttsServiceProvider).enqueue(
      TtsMessage(
        text: text,
        priority: TtsPriority.critical,
        requiredVerbosity: TtsVerbosity.minimal,
      ),
      enabled: true,
      currentVerbosity: TtsVerbosity.full,
    );
  }

  void toggleTts(bool value) =>
      _update(state.copyWith(ttsEnabled: value));

  void setTtsVerbosity(TtsVerbosity verbosity) =>
      _update(state.copyWith(ttsVerbosity: verbosity));

  void setTextVerbosity(TextVerbosity verbosity) =>
      _update(state.copyWith(textVerbosity: verbosity));

  void setSpeechRate(double rate) =>
      _update(state.copyWith(speechRate: rate));

  void toggleHapticFeedback(bool value) =>
      _update(state.copyWith(hapticFeedback: value));

  void setHapticIntensity(HapticIntensity intensity) =>
      _update(state.copyWith(hapticIntensity: intensity));

  void toggleEarcon(bool value) =>
      _update(state.copyWith(earconEnabled: value));

  /// Resets every setting to the factory default (const AppSettings()).
  /// Persists immediately. Does NOT touch the onboarding-complete flag —
  /// the caller decides whether to re-run onboarding.
  void resetSettings() => _update(const AppSettings());
}


/// True once the user has completed the onboarding flow.
/// Reads directly from SharedPreferences: synchronous after startup.
final onboardingCompleteProvider = StateProvider<bool>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return SettingsStorage(prefs).loadOnboardingComplete();
});

/// Call this from OnboardingScreen.onComplete to persist + update the gate.
void markOnboardingComplete(WidgetRef ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  SettingsStorage(prefs).markOnboardingComplete();
  ref.read(onboardingCompleteProvider.notifier).state = true;
}
