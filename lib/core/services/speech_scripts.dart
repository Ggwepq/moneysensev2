// The only place that builds TtsMessage objects. All spoken text lives here.
// Classes: AppSpeech, NavSpeech, SettingsSpeech, LanguageSpeech, OnboardingSpeech.
// ScannerSpeech lives in scanner_speech_scripts.dart and is re-exported here.

import '../../core/l10n/app_localizations.dart';
import 'tts_message.dart';

export 'scanner_speech_scripts.dart';

abstract final class AppSpeech {
  /// Spoken once when TTS is first enabled.
  static TtsMessage ttsEnabled(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsSpeechEnabled, id: 'app.ttsEnabled');

  /// Spoken when TTS is disabled via the toggle.
  static TtsMessage ttsDisabling(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsSpeechDisabling, id: 'app.ttsDisabling');
}


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


abstract final class SettingsSpeech {
  /// A boolean setting was toggled.
  static TtsMessage toggled(
          AppLocalizations l10n, String settingName, bool isOn) =>
      TtsMessage.navigation(
        isOn
            ? l10n.ttsSettingEnabled(settingName)
            : l10n.ttsSettingDisabled(settingName),
        id: 'settings.toggle.$settingName',
      );

  /// A selector setting changed (theme, verbosity, etc.).
  static TtsMessage changed(
          AppLocalizations l10n, String settingName, String newValue) =>
      TtsMessage.navigation(
        l10n.ttsSettingChanged(settingName, newValue),
        id: 'settings.change.$settingName',
      );
}


abstract final class LanguageSpeech {
  /// Spoken in the OLD language, before the engine switches.
  /// Tells the user what's happening so the silence isn't confusing.
  static TtsMessage changing(AppLocalizations oldL10n, String newLangName) =>
      TtsMessage.navigation(
        oldL10n.ttsLangChanging(newLangName),
        id: 'lang.changing',
      );

  /// Spoken in the NEW language, after the engine has switched.
  /// First thing the user hears in the new voice: confirms it worked.
  static TtsMessage done(AppLocalizations newL10n, String newLangName) =>
      TtsMessage.navigation(
        newL10n.ttsLangChanged(newLangName),
        id: 'lang.done',
      );
}

abstract final class OnboardingSpeech {
  /// Spoken when the welcome step is shown.
  static TtsMessage welcome(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsOnboardingWelcome, id: 'onboarding.welcome');

  /// Spoken when the vision profile step is shown.
  static TtsMessage visionStep(AppLocalizations l10n) =>
      TtsMessage.navigation('${l10n.onboardingVisionTitle}. ${l10n.onboardingVisionSubtitle}. ${l10n.onboardingVisionOptions}', id: 'onboarding.vision');

  /// Spoken when a profile is selected (confirmation).
  static TtsMessage profileSelected(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsOnboardingProfileSelected,
          id: 'onboarding.profileSelected');

  /// Spoken when the language step is shown.
  static TtsMessage languageStep(AppLocalizations l10n) =>
      TtsMessage.navigation('${l10n.language}. ${l10n.onboardingLanguageOptions}',
          id: 'onboarding.language');

  /// Spoken when the navigation style step is shown.
  static TtsMessage navStep(AppLocalizations l10n) =>
      TtsMessage.navigation('${l10n.onboardingNavTitle}. ${l10n.onboardingNavOptions}',
          id: 'onboarding.nav');

  /// Spoken when the permission step is shown.
  static TtsMessage permStep(AppLocalizations l10n) =>
      TtsMessage.navigation('${l10n.onboardingPermissionTitle}. MoneySense needs access to the Camera and Microphone. Say Proceed or Yes to grant permissions.',
          id: 'onboarding.perm');

  /// Spoken when the final step is shown.
  static TtsMessage finish(AppLocalizations l10n) =>
      TtsMessage.navigation('${l10n.onboardingFinishTitle}. ${l10n.onboardingFinishSubtitle} ${l10n.onboardingFinishOptions}',
          id: 'onboarding.finish');
}

abstract final class TutorialSpeech {
  /// Spoken when the inertial navigation tutorial opens.
  static TtsMessage inertialGuide(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsInertialGuide, id: 'tutorial.inertial');

  /// Spoken when the gestural navigation tutorial opens.
  static TtsMessage gesturalGuide(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsGesturalGuide, id: 'tutorial.gestural');

  /// Spoken when the shake tutorial opens.
  static TtsMessage shakeGuide(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsShakeGuide, id: 'tutorial.shake');

  /// Spoken when the haptic/denomination vibration tutorial opens.
  static TtsMessage hapticGuide(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsHapticGuide, id: 'tutorial.haptic');

  /// Spoken when the voice navigation tutorial opens.
  static TtsMessage voiceGuide(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsVoiceGuide, id: 'tutorial.voice');
}
