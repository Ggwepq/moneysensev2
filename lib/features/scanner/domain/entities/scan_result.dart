// Domain entity for a single identification result from the YOLOv8 model.
//
// Confidence tiers (human-readable UX):
//   very confident  >= 0.80  → green accent, positive phrasing
//   confident       >= 0.60  → green accent, standard phrasing
//   uncertain       <  0.60  → red accent, re-scan suggestion
//
// The 9 classes trained: 1, 5, 10, 20, 50, 100, 200, 500, 1000 (peso)

enum ConfidenceLevel { veryConfident, confident, uncertain }

class ScanResult {
  const ScanResult({
    required this.denominationPesos,
    required this.confidence,
    required this.isCoin,
  });

  /// Detected denomination value in pesos (1, 5, 10, 20, 50, 100, 200, 500, 1000).
  final int denominationPesos;

  /// Raw model confidence 0.0–1.0.
  final double confidence;

  /// True for 1, 5, 10, 20-peso coins; false for bills.
  final bool isCoin;

  ConfidenceLevel get confidenceLevel {
    if (confidence >= 0.80) return ConfidenceLevel.veryConfident;
    if (confidence >= 0.60) return ConfidenceLevel.confident;
    return ConfidenceLevel.uncertain;
  }

  bool get isUncertain => confidenceLevel == ConfidenceLevel.uncertain;

  /// Human-readable denomination label, e.g. "100 PESOS".
  String get displayLabel => '$denominationPesos PESOS';

  /// Returns a copy with updated fields.
  ScanResult copyWith({
    int? denominationPesos,
    double? confidence,
    bool? isCoin,
  }) =>
      ScanResult(
        denominationPesos: denominationPesos ?? this.denominationPesos,
        confidence: confidence ?? this.confidence,
        isCoin: isCoin ?? this.isCoin,
      );
}
