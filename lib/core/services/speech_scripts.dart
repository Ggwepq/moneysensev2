// ---------------------------------------------------------------------------
// SpeechScripts — the spoken word layer
// ---------------------------------------------------------------------------
//
// This file is the ONLY place that builds TtsMessage objects from text.
// It is the single source of truth for everything the app says aloud.
//
// STRUCTURE
//   Each logical area of the app has its own static class:
//     SpeechScripts.app        — startup, generic app events
//     SpeechScripts.nav        — screen transitions, back navigation
//     SpeechScripts.settings   — setting toggle/change confirmations
//     SpeechScripts.scanner    — see scanner_speech_scripts.dart (dedicated
//                                 file — imported and re-exported here)
//
// ADDING A NEW MESSAGE
//   1. Find the right class below (or create one).
//   2. Add a static method that takes AppLocalizations + whatever data it needs.
//   3. Return a TtsMessage with the right priority and verbosity.
//   4. Call it from your widget/notifier via the ttsServiceProvider.
//
// LANGUAGE
//   All strings are built from AppLocalizations — never hardcoded English.
//   Add the TTS-specific string to en.dart and tl.dart if a direct translation
//   of an existing UI string is not right for speech (e.g. shorter / more
//   natural when heard vs read).

import '../../core/l10n/app_localizations.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import 'tts_message.dart';

export 'scanner_speech_scripts.dart';

// ── App-level ────────────────────────────────────────────────────────────────

abstract final class AppSpeech {
  /// Spoken once when TTS is first enabled.
  static TtsMessage ttsEnabled(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsSpeechEnabled, id: 'app.ttsEnabled');

  /// Spoken when TTS is disabled via the toggle.
  static TtsMessage ttsDisabling(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsSpeechDisabling, id: 'app.ttsDisabling');
}

// ── Navigation ───────────────────────────────────────────────────────────────

abstract final class NavSpeech {
  /// User opened Settings screen.
  static TtsMessage openedSettings(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsNavSettings, id: 'nav.settings');

  /// User opened Tutorial screen.
  static TtsMessage openedTutorial(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsNavTutorial, id: 'nav.tutorial');

  /// User returned to the scanner / home screen.
  static TtsMessage returnedHome(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsNavHome, id: 'nav.home');
}

// ── Settings confirmations ───────────────────────────────────────────────────

abstract final class SettingsSpeech {
  /// A boolean setting was toggled.
  /// [settingName] is the UI label; [isOn] is the new state.
  static TtsMessage toggled(
    AppLocalizations l10n,
    String settingName,
    bool isOn,
  ) => TtsMessage.navigation(
    isOn
        ? l10n.ttsSettingEnabled(settingName)
        : l10n.ttsSettingDisabled(settingName),
    id: 'settings.toggle.$settingName',
  );

  /// A selector setting changed (theme, language, verbosity, etc.).
  static TtsMessage changed(
    AppLocalizations l10n,
    String settingName,
    String newValue,
  ) => TtsMessage.navigation(
    l10n.ttsSettingChanged(settingName, newValue),
    id: 'settings.change.$settingName',
  );
}

// ── Scanner ──────────────────────────────────────────────────────────────────
// Dedicated file — see scanner_speech_scripts.dart.
// Re-exported here so callers only need one import.

// ── Onboarding ───────────────────────────────────────────────────────────────

abstract final class OnboardingSpeech {
  /// Spoken when the welcome step is shown.
  static TtsMessage welcome(AppLocalizations l10n) => TtsMessage.navigation(
    l10n.ttsOnboardingWelcome,
    id: 'onboarding.welcome',
  );

  /// Spoken when the vision profile step is shown.
  static TtsMessage visionStep(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsOnboardingVision, id: 'onboarding.vision');

  /// Spoken when a profile is selected (confirmation).
  static TtsMessage profileSelected(AppLocalizations l10n) =>
      TtsMessage.navigation(
        l10n.ttsOnboardingProfileSelected,
        id: 'onboarding.profileSelected',
      );

  /// Spoken when the language step is shown.
  static TtsMessage languageStep(AppLocalizations l10n) =>
      TtsMessage.navigation(
        l10n.ttsOnboardingLanguage,
        id: 'onboarding.language',
      );
}
