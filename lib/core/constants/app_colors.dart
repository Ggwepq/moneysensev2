import 'package:flutter/material.dart';

/// PesoSense brand and semantic colors.
///
/// The design uses a dark-first palette with high-contrast accent colors
/// (neon yellow #D4FF00 and vibrant blue #3D5AFE) to ensure maximum
/// legibility for users with low vision.
abstract final class AppColors {
  // ── Brand Accents ─────────────────────────────────────────────────────────
  /// Primary accent – neon yellow used for selected states, icons, and CTAs.
  static const Color accentYellow = Color(0xFFD4FF00);

  /// Secondary accent – electric blue used for toggles, buttons, and overlays.
  static const Color accentBlue = Color(0xFF3D5AFE);

  /// Help/info button background
  static const Color accentBlueDark = Color(0xFF2A3FC7);

  // ── Dark Theme Surfaces ────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0E0E0E);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF242424);
  static const Color darkBorder = Color(0xFF2E2E2E);

  // ── Light Theme Surfaces ───────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEEEEE);
  static const Color lightBorder = Color(0xFFDDDDDD);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnSurfaceVariant = Color(0xFFAAAAAA);
  static const Color lightOnSurface = Color(0xFF0E0E0E);
  static const Color lightOnSurfaceVariant = Color(0xFF555555);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);

  // ── Scanner overlay borders ────────────────────────────────────────────────
  static const Color scannerBorderIdle = Color(0xFF2E2E2E);
  static const Color scannerBorderScanning = Color(0xFFD4FF00); // yellow
  static const Color scannerBorderProcessing = Color(0xFF3D5AFE); // blue
}
