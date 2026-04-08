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
  String toDescription(AppLocalizations l10n) => l10n.voiceCmdGoHome;
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
