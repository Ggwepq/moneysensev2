import 'dart:typed_data';
import 'package:flutter/painting.dart';

/// All possible states of the real-time scanner.
enum ScannerState {
  idle,
  previewing,
  paused,
  scanning,
  centering,
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
    this.boundingBox,
    this.capturedImage,
    this.imagePath,
  });

  final String      denomination; // e.g. "100" or "25c"
  final String      type;         // "bill" or "coin"
  final double      confidence;
  final Rect?       boundingBox;  // Normalized coordinates [0,1] in detection space
  final Uint8List?  capturedImage; // High-res frame for verification
  final String?     imagePath;

  ConfidenceLevel get confidenceLevel {
    if (confidence >= 0.75) return ConfidenceLevel.veryConfident;
    if (confidence >= 0.50) return ConfidenceLevel.confident;
    return ConfidenceLevel.uncertain;
  }

  bool get isUncertain => confidenceLevel == ConfidenceLevel.uncertain;

  /// Display label shown large on the result screen.
  String get displayLabel {
    if (denomination == '25c') return '25 CENTAVO';
    return '$denomination PESOS';
  }
}
