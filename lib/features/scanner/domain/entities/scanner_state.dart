/// All possible states of the real-time scanner.
enum ScannerState {
  /// Camera is off / preview not started.
  idle,

  /// Camera is running, live preview visible.
  previewing,

  /// Preview is paused (double-tap) — camera stays open but feed is frozen.
  paused,

  /// Actively scanning (yellow border, pulsing).
  scanning,

  /// ML inference in progress (blue border, pulsing).
  processing,

  /// A result is ready to display.
  result,
}

/// Represents a detected Philippine currency denomination.
class DetectionResult {
  final String denomination;  // e.g. "₱1,000"
  final String type;          // "bill" or "coin"
  final double confidence;    // 0.0 – 1.0
  final String? imagePath;    // optional cropped image path

  const DetectionResult({
    required this.denomination,
    required this.type,
    required this.confidence,
    this.imagePath,
  });
}
