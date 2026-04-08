/// Represents the overarching goal recognized by the Voice Command engine.
sealed class VoiceIntent {
  const VoiceIntent();
}

/// For unknown/unmatched phrases
class UnknownIntent extends VoiceIntent {
  const UnknownIntent(this.detectedWords);
  final String detectedWords;
}

/// Indicates the start of a scanning action
class ScanIntent extends VoiceIntent {
  const ScanIntent();
}

/// Indicates pausing the scanner
class PauseScanIntent extends VoiceIntent {
  const PauseScanIntent();
}

/// Indicates a toggle of the flashlight
class ToggleFlashlightIntent extends VoiceIntent {
  const ToggleFlashlightIntent(this.turnOn);
  final bool turnOn;
}

/// Indicates a semantic change of camera direction
class ChangeCameraIntent extends VoiceIntent {
  const ChangeCameraIntent({required this.toFront});
  final bool toFront;
}

/// Indicates the start of an active listening session triggered by a wake word
class WakeIntent extends VoiceIntent {
  const WakeIntent();
}

/// Indicates the app should close
class ExitAppIntent extends VoiceIntent {
  const ExitAppIntent();
}

/// Indicates a command to stop current speech immediately
class StopSpeakingIntent extends VoiceIntent {
  const StopSpeakingIntent();
}

/// Detailed targets for contextual help
enum HelpTarget { general, inertial, gestural, voice, scanning }

/// Indicates a request for help or available commands
class HelpIntent extends VoiceIntent {
  const HelpIntent([this.target = HelpTarget.general]);
  final HelpTarget target;
}

/// General navigation targets
enum NavTarget { settings, home, tutorial, commandList }

class NavigateIntent extends VoiceIntent {
  const NavigateIntent(this.target);
  final NavTarget target;
}

/// ── Onboarding Specific Intents ─────────────────────────────────────────────

/// Triggers the voice-guided onboarding flow
class StartVoiceSetupIntent extends VoiceIntent {
  const StartVoiceSetupIntent();
}

/// Represents a selection during onboarding (e.g. choice of language, profile)
class SelectionIntent extends VoiceIntent {
  const SelectionIntent(this.value);
  final String value;
}

/// Represents generic agreement/disagreement (Yes/No)
class SelectionConfirmationIntent extends VoiceIntent {
  const SelectionConfirmationIntent(this.isConfirmed);
  final bool isConfirmed;
}
