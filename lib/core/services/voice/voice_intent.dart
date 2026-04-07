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

/// Indicates a toggle of the flashlight
class ToggleFlashlightIntent extends VoiceIntent {
  const ToggleFlashlightIntent(this.turnOn);
  final bool turnOn;
}

/// Indicates switching the camera
class ChangeCameraIntent extends VoiceIntent {
  const ChangeCameraIntent({required this.toFront});
  final bool toFront;
}

/// General navigation targets
enum NavTarget { settings, home, tutorial }

class NavigateIntent extends VoiceIntent {
  const NavigateIntent(this.target);
  final NavTarget target;
}
