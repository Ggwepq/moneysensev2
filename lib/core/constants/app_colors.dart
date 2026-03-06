import 'package:flutter/material.dart';

/// PesoSense brand and semantic colors.
///
/// The design uses a dark-first palette with high-contrast accent colors
/// (neon yellow #D4FF00 and vibrant blue #3D5AFE) to ensure maximum
abstract final class AppColors {
  // ── Brand Accents (same in light and dark) ────────────────────────────────
  /// Primary accent — bright yellow used for selected states, sliders, CTAs.
  static const Color accentYellow = Color(0xFFE2DA00);

  /// Secondary accent — electric blue used for scan button, switches, help btn.
  static const Color accentBlue = Color(0xFF1E30F0);

  // ── Dark Theme Surfaces ────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF010F1C);
  static const Color darkSurface = Color(0xFF0D1B28);
  static const Color darkSurfaceVariant = Color(0xFF162330);
  static const Color darkBorder = Color(0xFF243040);

  // ── Light Theme Surfaces ───────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEEEEE);
  static const Color lightBorder = Color(0xFFDDDDDD);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnSurfaceVariant = Color(0xFF8A9BB0);
  static const Color lightOnSurface = Color(0xFF0E0E0E);
  static const Color lightOnSurfaceVariant = Color(0xFF555555);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);

  // ── Scanner overlay borders ────────────────────────────────────────────────
  static const Color scannerBorderIdle = Color(0xFF243040);
  static const Color scannerBorderScanning = accentYellow;
  static const Color scannerBorderProcessing = accentBlue;
}
