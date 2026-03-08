import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings.dart';
import '../../presentation/providers/settings_provider.dart';

// ---------------------------------------------------------------------------
// VisionConfig — computed from VisionProfile
// ---------------------------------------------------------------------------
//
// Single source of truth for every adaptive behaviour driven by the profile.
// Widgets and services read VisionConfig, never the raw VisionProfile enum.
//
// ┌──────────────────────┬──────────────┬──────────────────┬─────────────────┐
// │                      │  Low Vision  │ Partially Blind  │  Fully Blind    │
// ├──────────────────────┼──────────────┼──────────────────┼─────────────────┤
// │ fontScaleFloor       │     1.0      │      1.3         │      1.6        │
// │ contrastLevel        │   normal     │    elevated      │    maximum      │
// │ ttsVerbosity default │  minimal     │   standard       │    full         │
// │ hapticIntensity def  │  subtle      │   medium         │    strong       │
// │ autoAnnounce         │  false       │   true           │    true         │
// │ announceNav          │  false       │   true           │    true         │
// │ announceIdle         │  false       │   false          │    true         │
// │ preferAudioPrimary   │  false       │   true           │    true         │
// └──────────────────────┴──────────────┴──────────────────┴─────────────────┘

enum ContrastLevel { normal, elevated, maximum }

@immutable
class VisionConfig {
  const VisionConfig({
    required this.profile,
    required this.fontScaleFloor,
    required this.contrastLevel,
    required this.defaultTtsVerbosity,
    required this.defaultHapticIntensity,
    required this.autoAnnounceResults,
    required this.announceNavigation,
    required this.announceIdleState,
    required this.preferAudioPrimary,
  });

  final VisionProfile profile;

  /// Minimum font scale enforced regardless of the user's slider position.
  final double fontScaleFloor;

  /// Colour contrast amplification level.
  ///
  /// [normal]   — standard palette (existing AppColors).
  /// [elevated] — slightly stronger text/border contrast for partial blind.
  /// [maximum]  — maximum contrast: pure white text, stronger borders,
  ///              boosted accent brightness for fully blind.
  final ContrastLevel contrastLevel;

  final TtsVerbosity defaultTtsVerbosity;
  final HapticIntensity defaultHapticIntensity;
  final bool autoAnnounceResults;
  final bool announceNavigation;
  final bool announceIdleState;
  final bool preferAudioPrimary;

  // ── Effective font scale ───────────────────────────────────────────────────

  /// Returns the actual font scale to apply, clamping [userScale] to
  /// [fontScaleFloor] so profiles can never go below their minimum.
  double effectiveFontScale(double userScale) =>
      userScale.clamp(fontScaleFloor, 2.0);

  // ── Colour accessors ───────────────────────────────────────────────────────
  // Centralised here so adding a new colour-adaptive widget means reading one
  // value from VisionConfig rather than switching on profile everywhere.

  /// Primary text colour for the current contrast level / theme brightness.
  Color textPrimary(bool isDark) {
    return switch (contrastLevel) {
      ContrastLevel.normal   => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0E0E0E),
      ContrastLevel.elevated => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
      ContrastLevel.maximum  => const Color(0xFFFFFFFF), // always white — max contrast
    };
  }

  /// Secondary / subtitle text colour.
  Color textSecondary(bool isDark) {
    return switch (contrastLevel) {
      ContrastLevel.normal   => isDark ? const Color(0xFF8A9BB0) : const Color(0xFF555555),
      ContrastLevel.elevated => isDark ? const Color(0xFFBBCCDD) : const Color(0xFF333333),
      ContrastLevel.maximum  => isDark ? const Color(0xFFDDEEFF) : const Color(0xFF111111),
    };
  }

  /// Card/tile surface colour.
  Color surface(bool isDark) {
    return switch (contrastLevel) {
      ContrastLevel.normal   => isDark ? const Color(0xFF0D1B28) : const Color(0xFFFFFFFF),
      ContrastLevel.elevated => isDark ? const Color(0xFF0A1520) : const Color(0xFFFFFFFF),
      ContrastLevel.maximum  => isDark ? const Color(0xFF050D14) : const Color(0xFFFFFFFF),
    };
  }

  /// Border colour — stronger at higher contrast levels.
  Color border(bool isDark) {
    return switch (contrastLevel) {
      ContrastLevel.normal   => isDark ? const Color(0xFF243040) : const Color(0xFFDDDDDD),
      ContrastLevel.elevated => isDark ? const Color(0xFF3A4E62) : const Color(0xFF999999),
      ContrastLevel.maximum  => isDark ? const Color(0xFF6688AA) : const Color(0xFF444444),
    };
  }

  /// Accent yellow — boosted brightness at higher contrast.
  Color get accentYellow => switch (contrastLevel) {
        ContrastLevel.normal   => const Color(0xFFE2DA00),
        ContrastLevel.elevated => const Color(0xFFFFEE00),
        ContrastLevel.maximum  => const Color(0xFFFFFF33),
      };

  // ── Factory ────────────────────────────────────────────────────────────────

  factory VisionConfig.from(VisionProfile profile) {
    return switch (profile) {
      VisionProfile.lowVision => const VisionConfig(
        profile:                VisionProfile.lowVision,
        fontScaleFloor:         1.0,
        contrastLevel:          ContrastLevel.normal,
        defaultTtsVerbosity:    TtsVerbosity.minimal,
        defaultHapticIntensity: HapticIntensity.subtle,
        autoAnnounceResults:    false,
        announceNavigation:     false,
        announceIdleState:      false,
        preferAudioPrimary:     false,
      ),
      VisionProfile.partiallyBlind => const VisionConfig(
        profile:                VisionProfile.partiallyBlind,
        fontScaleFloor:         1.3,
        contrastLevel:          ContrastLevel.elevated,
        defaultTtsVerbosity:    TtsVerbosity.standard,
        defaultHapticIntensity: HapticIntensity.medium,
        autoAnnounceResults:    true,
        announceNavigation:     true,
        announceIdleState:      false,
        preferAudioPrimary:     true,
      ),
      VisionProfile.fullyBlind => const VisionConfig(
        profile:                VisionProfile.fullyBlind,
        fontScaleFloor:         1.6,
        contrastLevel:          ContrastLevel.maximum,
        defaultTtsVerbosity:    TtsVerbosity.full,
        defaultHapticIntensity: HapticIntensity.strong,
        autoAnnounceResults:    true,
        announceNavigation:     true,
        announceIdleState:      true,
        preferAudioPrimary:     true,
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final visionConfigProvider = Provider<VisionConfig>((ref) {
  final profile = ref.watch(
    appSettingsProvider.select((s) => s.visionProfile),
  );
  return VisionConfig.from(profile);
});
