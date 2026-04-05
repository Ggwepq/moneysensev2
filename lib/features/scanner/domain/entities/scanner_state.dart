// lib/features/scanner/domain/entities/scanner_state.dart

/// All possible states of the real-time scanner.
enum ScannerState {
  idle,
  previewing,
  paused,
  scanning,
  processing,
  result,
}

// ── Confidence ─────────────────────────────────────────────────────────────

enum ConfidenceLevel { veryConfident, confident, uncertain }

// ── DetectionResult ─────────────────────────────────────────────────────────

/// Represents a detected Philippine currency denomination.
///
/// 10 trained classes:
///   25c  1  5  10  20  50  100  200  500  1000
///   (20 is a single class covering both the coin and bill)
class DetectionResult {
  const DetectionResult({
    required this.denomination,
    required this.type,
    required this.confidence,
    this.imagePath,
  });

  final String  denomination; // e.g. "100" or "25c"
  final String  type;         // "bill" or "coin"
  final double  confidence;
  final String? imagePath;

  ConfidenceLevel get confidenceLevel {
    if (confidence >= 0.80) return ConfidenceLevel.veryConfident;
    if (confidence >= 0.60) return ConfidenceLevel.confident;
    return ConfidenceLevel.uncertain;
  }

  bool get isUncertain => confidenceLevel == ConfidenceLevel.uncertain;

  /// Display label shown large on the result screen.
  String get displayLabel {
    if (denomination == '25c') return '25 CENTAVO';
    return '$denomination PESOS';
  }
}
