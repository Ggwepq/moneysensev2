import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// MoneySense theme.
///
/// Color philosophy:
///   Yellow (#E2DA00) is the PRIMARY accent on BOTH themes: it drives
///   selected states, sliders, segmented pills, and the Settings/Help nav buttons.
///
///   Blue (#1E30F0) is the SECONDARY accent on BOTH themes: it drives the
///   scan/stop button, Switch tracks, and the help-info button.
///
///   This makes the UI consistent regardless of theme: "yellow = primary
///   selection", "blue = action/toggle".
///
/// Font scale / WCAG 1.4.4:
///   bodyLarge 16 sp, bodySmall 13 sp, labelSmall 11 sp.
///   At 80% user scale those become 12.8 / 10.4 / 8.8: still legible.
///   At 200% scale the layout is designed to accommodate without overflow.
abstract final class AppTheme {

  // ── Shared text theme ──────────────────────────────────────────────────────

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
        displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: primary),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: primary),
        titleLarge:    TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
        titleMedium:   TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
        titleSmall:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
        bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
        bodyMedium:    TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: primary),
        bodySmall:     TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: secondary),
        labelLarge:    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
        labelMedium:   TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: secondary),
        labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: secondary),
      );

  // ── Shared switch theme ────────────────────────────────────────────────────

  /// Switch track = blue when on, muted when off.
  /// Switch thumb = contrasting on/off colour.
  ///
  /// Material 3 Switch ignores trackColor alone when the ColorScheme primary
  /// overrides it. Setting trackOutlineColor to transparent removes the outline
  /// border that M3 draws on top, letting our trackColor show through correctly.
  static SwitchThemeData _switchTheme({
    required Color thumbOn,
    required Color thumbOff,
    required Color trackOff,
  }) =>
      SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? thumbOn : thumbOff),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.accentBlue : trackOff),
        // Transparent outline lets our trackColor show — without this M3 draws
        // a coloured border that visually overrides the track on some devices.
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.accentBlue.withValues(alpha: 0.12)
                : null),
      );

  // ── Shared slider theme ────────────────────────────────────────────────────

  static SliderThemeData _sliderTheme(Color inactive) => SliderThemeData(
        activeTrackColor:  AppColors.accentYellow,
        inactiveTrackColor: inactive,
        thumbColor:  AppColors.accentYellow,
        overlayColor: AppColors.accentYellow.withValues(alpha: 0.20),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        trackHeight: 4,
      );

  // ── Dark ───────────────────────────────────────────────────────────────────

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accentBlue,
      brightness: Brightness.dark,
    ).copyWith(
      // Yellow = primary (drives M3 filled buttons, segmented control, etc.)
      primary:   AppColors.accentYellow,
      onPrimary: AppColors.darkBackground,
      // Blue = secondary (switches, FAB, outlined buttons)
      secondary:   AppColors.accentBlue,
      onSecondary: Colors.white,
      surface:           AppColors.darkSurface,
      onSurface:         AppColors.darkOnSurface,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      outline:           AppColors.darkBorder,
      // ignore: deprecated_member_use
      background:        AppColors.darkBackground,
      // ignore: deprecated_member_use
      onBackground:      AppColors.darkOnSurface,
    );

    return base.copyWith(
      colorScheme:             scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme:               _textTheme(AppColors.darkOnSurface, AppColors.darkOnSurfaceVariant),
      primaryTextTheme:        _textTheme(AppColors.darkOnSurface, AppColors.darkOnSurfaceVariant),
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
        thumbOn:  AppColors.darkBackground,
        thumbOff: AppColors.darkOnSurfaceVariant,
        trackOff: AppColors.darkSurfaceVariant,
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder, thickness: 1, space: 0),
      listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
      sliderTheme: _sliderTheme(AppColors.darkSurfaceVariant),
    );
  }

  // ── Light ──────────────────────────────────────────────────────────────────

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accentBlue,
      brightness: Brightness.light,
    ).copyWith(
      // Yellow = primary on light too: fixes blue slider/pill bug
      primary:   AppColors.accentYellow,
      onPrimary: AppColors.lightOnSurface,
      secondary:   AppColors.accentBlue,
      onSecondary: Colors.white,
      surface:           AppColors.lightSurface,
      onSurface:         AppColors.lightOnSurface,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      outline:           AppColors.lightBorder,
      // ignore: deprecated_member_use
      background:        AppColors.lightBackground,
      // ignore: deprecated_member_use
      onBackground:      AppColors.lightOnSurface,
    );

    return base.copyWith(
      colorScheme:             scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme:               _textTheme(AppColors.lightOnSurface, AppColors.lightOnSurfaceVariant),
      primaryTextTheme:        _textTheme(AppColors.lightOnSurface, AppColors.lightOnSurfaceVariant),
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
        thumbOn:  Colors.white,
        thumbOff: AppColors.lightOnSurfaceVariant,
        trackOff: AppColors.lightSurfaceVariant,
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.lightBorder, thickness: 1, space: 0),
      listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
      sliderTheme: _sliderTheme(AppColors.lightSurfaceVariant),
    );
  }
}
