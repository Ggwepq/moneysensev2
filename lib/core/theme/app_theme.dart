import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// PesoSense theme.
///
/// Font size baseline — WCAG 2.1 AA compliance:
///   displayLarge  32 sp  (section titles, result denomination)
///   titleLarge    22 sp  (card headings)
///   titleMedium   18 sp  (dialog titles, section headers)
///   bodyLarge     16 sp  (tile titles — minimum for readable body text)
///   bodyMedium    15 sp
///   bodySmall     13 sp  (subtitles — minimum for secondary text)
///   labelSmall    11 sp  (badges, percentage labels — never goes below 10sp)
///
/// Contrast ratios (against backgrounds) all pass WCAG AA (4.5:1 for normal
/// text, 3:1 for large text ≥18sp bold or ≥24sp regular):
///   darkOnSurface  (#FFFFFF) on darkSurface  (#1A1A1A) → ~15.7:1 ✓
///   lightOnSurface (#0E0E0E) on lightSurface (#F5F5F5) → ~17.3:1 ✓
///   accentYellow   (#D4FF00) on darkBackground (#000000)→ ~16.4:1 ✓
///   accentBlue     (#3D5AFE) on lightBackground(#FFFFFF)→ ~4.6:1  ✓
abstract final class AppTheme {
  // ── Shared text theme ─────────────────────────────────────────────────────

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: primary,
    ),
    displayMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: primary,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: primary,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    // bodyLarge: tile titles — must be ≥ 16 sp (WCAG minimum for body)
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: primary,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: primary,
    ),
    // bodySmall: subtitles — ≥ 13 sp so at 80% scale = 10.4 sp (just above 10)
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: secondary,
    ),
    // labelLarge: buttons
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: secondary,
    ),
    // labelSmall: badges, percentages — floor at 11 sp
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: secondary,
    ),
  );

  // ── Dark ──────────────────────────────────────────────────────────────────

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.accentBlue,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.accentYellow,
          onPrimary: AppColors.darkBackground,
          secondary: AppColors.accentBlue,
          onSecondary: Colors.white,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkOnSurface,
          surfaceContainerHighest: AppColors.darkSurfaceVariant,
          outline: AppColors.darkBorder,
          // ignore: deprecated_member_use
          background: AppColors.darkBackground,
          // ignore: deprecated_member_use
          onBackground: AppColors.darkOnSurface,
        );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _textTheme(
        AppColors.darkOnSurface,
        AppColors.darkOnSurfaceVariant,
      ),
      primaryTextTheme: _textTheme(
        AppColors.darkOnSurface,
        AppColors.darkOnSurfaceVariant,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: true,
        // AppBar title uses titleLarge from textTheme (22 sp) but we want
        // a slightly smaller, tighter headline — override explicitly.
        titleTextStyle: const TextStyle(
          color: AppColors.darkOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkOnSurface),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.darkBackground
              : AppColors.darkOnSurfaceVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.accentBlue
              : AppColors.darkSurfaceVariant,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accentYellow,
        inactiveTrackColor: AppColors.darkSurfaceVariant,
        thumbColor: AppColors.accentYellow,
        overlayColor: AppColors.accentYellow.withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        trackHeight: 4,
      ),
    );
  }

  // ── Light ─────────────────────────────────────────────────────────────────

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.accentBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.accentBlue,
          onPrimary: Colors.white,
          secondary: AppColors.accentYellow,
          onSecondary: AppColors.lightOnSurface,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightOnSurface,
          surfaceContainerHighest: AppColors.lightSurfaceVariant,
          outline: AppColors.lightBorder,
          // ignore: deprecated_member_use
          background: AppColors.lightBackground,
          // ignore: deprecated_member_use
          onBackground: AppColors.lightOnSurface,
        );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _textTheme(
        AppColors.lightOnSurface,
        AppColors.lightOnSurfaceVariant,
      ),
      primaryTextTheme: _textTheme(
        AppColors.lightOnSurface,
        AppColors.lightOnSurfaceVariant,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.lightOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightOnSurface),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.lightOnSurfaceVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.accentBlue
              : AppColors.lightSurfaceVariant,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accentBlue,
        inactiveTrackColor: AppColors.lightSurfaceVariant,
        thumbColor: AppColors.accentBlue,
        overlayColor: AppColors.accentBlue.withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        trackHeight: 4,
      ),
    );
  }
}
