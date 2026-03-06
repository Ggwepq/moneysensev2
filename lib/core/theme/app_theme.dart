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
abstract final class AppTheme {
  // ── Shared text theme ──────────────────────────────────────────────────────

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
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: secondary,
    ),
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
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: secondary,
    ),
  );

  // ── Shared switch theme ────────────────────────────────────────────────────

  /// Switch track = blue when on, muted when off.
  /// Switch thumb = contrasting on/off colour.
  static SwitchThemeData _switchTheme({
    required Color thumbOn,
    required Color thumbOff,
    required Color trackOff,
  }) => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? thumbOn : thumbOff,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? AppColors.accentBlue : trackOff,
    ),
  );

  // ── Shared slider theme ────────────────────────────────────────────────────

  static SliderThemeData _sliderTheme(Color inactive) => SliderThemeData(
    activeTrackColor: AppColors.accentYellow,
    inactiveTrackColor: inactive,
    thumbColor: AppColors.accentYellow,
    overlayColor: AppColors.accentYellow.withOpacity(0.20),
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    trackHeight: 4,
  );

  // ── Dark ───────────────────────────────────────────────────────────────────

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.accentBlue,
          brightness: Brightness.dark,
        ).copyWith(
          // Yellow = primary (drives M3 filled buttons, segmented control, etc.)
          primary: AppColors.accentYellow,
          onPrimary: AppColors.darkBackground,
          // Blue = secondary (switches, FAB, outlined buttons)
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
        titleTextStyle: const TextStyle(
          color: AppColors.darkOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkOnSurface),
      ),
      switchTheme: _switchTheme(
        thumbOn: AppColors.darkBackground,
        thumbOff: AppColors.darkOnSurfaceVariant,
        trackOff: AppColors.darkSurfaceVariant,
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
      sliderTheme: _sliderTheme(AppColors.darkSurfaceVariant),
    );
  }

  // ── Light ──────────────────────────────────────────────────────────────────

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.accentBlue,
          brightness: Brightness.light,
        ).copyWith(
          // Yellow = primary on light too — fixes blue slider/pill bug
          primary: AppColors.accentYellow,
          onPrimary: AppColors.lightOnSurface,
          secondary: AppColors.accentBlue,
          onSecondary: Colors.white,
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
      switchTheme: _switchTheme(
        thumbOn: Colors.white,
        thumbOff: AppColors.lightOnSurfaceVariant,
        trackOff: AppColors.lightSurfaceVariant,
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
      sliderTheme: _sliderTheme(AppColors.lightSurfaceVariant),
    );
  }
}
