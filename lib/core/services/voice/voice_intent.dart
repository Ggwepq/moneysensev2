import '../../l10n/app_localizations.dart';

/// Represents the overarching goal recognized by the Voice Command engine.
sealed class VoiceIntent {
  const VoiceIntent();

  String toDescription(AppLocalizations l10n);
}

/// For unknown/unmatched phrases
class UnknownIntent extends VoiceIntent {
  const UnknownIntent(this.detectedWords);
  final String detectedWords;

  @override
  String toDescription(AppLocalizations l10n) => l10n.voiceCmdHelp;
}

/// Indicates the start of a scanning action
class ScanIntent extends VoiceIntent {
  const ScanIntent();

  @override
  String toDescription(AppLocalizations l10n) => l10n.voiceCmdStartScanner;
}

/// Indicates pausing the scanner
class PauseScanIntent extends VoiceIntent {
  const PauseScanIntent();

  @override
  String toDescription(AppLocalizations l10n) => 'pause scanning';
}

/// Indicates a toggle of the flashlight
class ToggleFlashlightIntent extends VoiceIntent {
  const ToggleFlashlightIntent(this.turnOn);
  final bool turnOn;

  @override
  String toDescription(AppLocalizations l10n) =>
      turnOn ? l10n.voiceCmdFlashOn : l10n.voiceCmdFlashOff;
}

/// Indicates a semantic change of camera direction
class ChangeCameraIntent extends VoiceIntent {
  const ChangeCameraIntent({required this.toFront});
  final bool toFront;

  @override
  String toDescription(AppLocalizations l10n) =>
      toFront ? l10n.voiceCmdFrontCam : l10n.voiceCmdBackCam;
}

/// Indicates the start of an active listening session triggered by a wake word
class WakeIntent extends VoiceIntent {
  const WakeIntent();

  @override
  String toDescription(AppLocalizations l10n) => 'wake word';
}

/// Indicates the app should close
class ExitAppIntent extends VoiceIntent {
  const ExitAppIntent();

  @override
  String toDescription(AppLocalizations l10n) => l10n.voiceCmdExit;
}

/// Indicates a command to stop current speech immediately
class StopSpeakingIntent extends VoiceIntent {
  const StopSpeakingIntent();

  @override
  String toDescription(AppLocalizations l10n) => 'stop speaking';
}

/// Detailed targets for contextual help
enum HelpTarget { general, inertial, gestural, voice, scanning }

/// Indicates a request for help or available commands
class HelpIntent extends VoiceIntent {
  const HelpIntent([this.target = HelpTarget.general]);
  final HelpTarget target;

  @override
  String toDescription(AppLocalizations l10n) => l10n.voiceCmdOpenTutorial;
}

/// General navigation targets
enum NavTarget { settings, home, tutorial, commandList }

class NavigateIntent extends VoiceIntent {
  const NavigateIntent(this.target);
  final NavTarget target;

  @override
  String toDescription(AppLocalizations l10n) {
    return switch (target) {
      NavTarget.settings => l10n.voiceCmdOpenSettings,
      NavTarget.home => l10n.voiceCmdGoHome,
      NavTarget.tutorial => l10n.voiceCmdOpenTutorial,
      NavTarget.commandList => l10n.voiceCmdCommandList,
    };
  }
}

/// ── Onboarding Specific Intents ─────────────────────────────────────────────

/// Triggers the voice-guided onboarding flow
class StartVoiceSetupIntent extends VoiceIntent {
  const StartVoiceSetupIntent();

  @override
  String toDescription(AppLocalizations l10n) => 'start setup';
}

/// Represents a selection during onboarding (e.g. choice of language, profile)
class SelectionIntent extends VoiceIntent {
  const SelectionIntent(this.value);
  final String value;

  @override
  String toDescription(AppLocalizations l10n) => 'select $value';
}

/// Represents generic agreement/disagreement (Yes/No)
class SelectionConfirmationIntent extends VoiceIntent {
  const SelectionConfirmationIntent(this.isConfirmed);
  final bool isConfirmed;

  @override
  String toDescription(AppLocalizations l10n) => isConfirmed ? 'Yes' : 'No';
}

/// Represents a manual request to identify the current frame
class IdentifyIntent extends VoiceIntent {
  const IdentifyIntent();

  @override
  String toDescription(AppLocalizations l10n) => l10n.voiceCmdIdentify;
}

/// Represents a request to skip the current step
class SkipIntent extends VoiceIntent {
  const SkipIntent();

  @override
  String toDescription(AppLocalizations l10n) => 'Skip';
}

/// Represents a request to retry identification/verification on the Result Screen
class RetryIntent extends VoiceIntent {
  const RetryIntent();

  @override
  String toDescription(AppLocalizations l10n) => 'Retry last detection';
}

/// ── Settings Modification Intents ───────────────────────────────────────

class ChangeLanguageIntent extends VoiceIntent {
  final String language; // 'english' or 'tagalog'
  const ChangeLanguageIntent(this.language);

  @override
  String toDescription(AppLocalizations l10n) => 'Change language to $language';
}

class ChangeThemeIntent extends VoiceIntent {
  final String theme; // 'light', 'dark', 'system'
  const ChangeThemeIntent(this.theme);

  @override
  String toDescription(AppLocalizations l10n) => 'Change theme to $theme';
}

class ChangeFontSizeIntent extends VoiceIntent {
  final String size; // 'small', 'regular', 'large'
  const ChangeFontSizeIntent(this.size);

  @override
  String toDescription(AppLocalizations l10n) => 'Set font size to $size';
}

class ChangeSpeechRateIntent extends VoiceIntent {
  final String rate; // 'slow', 'normal', 'fast'
  const ChangeSpeechRateIntent(this.rate);

  @override
  String toDescription(AppLocalizations l10n) => 'Set speech rate to $rate';
}

class ChangeVerbosityIntent extends VoiceIntent {
  final String level; // 'minimal', 'standard', 'full'
  const ChangeVerbosityIntent(this.level);

  @override
  String toDescription(AppLocalizations l10n) => 'Set verbosity to $level';
}

class ChangeVisionProfileIntent extends VoiceIntent {
  final String profile; // 'lowVision', 'partiallyBlind', 'fullyBlind'
  const ChangeVisionProfileIntent(this.profile);

  @override
  String toDescription(AppLocalizations l10n) => 'Change vision profile to $profile';
}
