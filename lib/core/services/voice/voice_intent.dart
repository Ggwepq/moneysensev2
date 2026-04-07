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

/// General navigation targets
enum NavTarget { settings, home, tutorial }

class NavigateIntent extends VoiceIntent {
  const NavigateIntent(this.target);
  final NavTarget target;
}
