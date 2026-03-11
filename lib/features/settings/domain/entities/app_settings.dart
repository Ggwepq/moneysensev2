import 'package:flutter/material.dart';

/// Represents the app-wide accessibility and preference settings.
///
/// This is a plain immutable value object.  State management (Riverpod) wraps
/// this and handles persistence via [SharedPreferences].

enum AppThemeMode { system, light, dark }

enum AppLanguage { english, tagalog }

/// The user's declared vision profile.
///
/// This drives [VisionConfig], which in turn controls TTS verbosity,
/// haptic intensity defaults, font scale floors, and UI density.
enum VisionProfile { lowVision, partiallyBlind, fullyBlind }

/// How much the TTS engine announces.
///
/// [minimal] : scan results only.
/// [standard]: results + navigation events + setting confirmations.
/// [full]    : everything: screen transitions, idle state, all interactions.
///
/// [VisionConfig] sets the default for each [VisionProfile].
/// The user can override this independently in Settings → Accessibility.
enum TtsVerbosity { minimal, standard, full }

/// How strongly the haptic / vibration engine responds.
///
/// [subtle]  : HapticFeedback only (no motor vibration), short patterns.
/// [medium]  : HapticFeedback + short motor pulse.
/// [strong]  : HapticFeedback + full motor vibration with rich patterns.
///
/// [VisionConfig] sets the default per profile; user can override.
enum HapticIntensity { subtle, medium, strong }

class AppSettings {
  // ── General ────────────────────────────────────────────────────────────
  final AppThemeMode themeMode;
  final AppLanguage language;

  /// Font scale factor: 0.8 – 2.0, default 1.0.
  final double fontScale;

  // ── Scanning ──────────────────────────────────────────────────────────
  final bool useFrontCamera;
  final bool useFlashlight;
  final bool denominationVibration;

  // ── Navigation ────────────────────────────────────────────────────────
  final bool shakeToGoBack;

  /// Seconds to wait before auto-navigating back after a result (0 = off).
  final int goBackTimerSeconds;
  final bool gesturalNavigation;
  final bool inertialNavigation;

  // ── Accessibility ─────────────────────────────────────────────────────
  final VisionProfile visionProfile;
  final bool ttsEnabled;
  final TtsVerbosity ttsVerbosity;
  final bool hapticFeedback;
  final HapticIntensity hapticIntensity;

  // ── Earcons ───────────────────────────────────────────────────────────
  /// Whether short audio cues play for scan events (independent of TTS).
  final bool earconEnabled;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.language = AppLanguage.english,
    this.fontScale = 1.0,
    this.useFrontCamera = false,
    this.useFlashlight = false,
    this.denominationVibration = true,
    this.shakeToGoBack = true,
    this.goBackTimerSeconds = 20,
    this.gesturalNavigation = true,
    this.inertialNavigation = true,
    this.visionProfile = VisionProfile.lowVision,
    this.ttsEnabled = true,
    this.ttsVerbosity = TtsVerbosity.standard,
    this.hapticFeedback = true,
    this.hapticIntensity = HapticIntensity.medium,
    this.earconEnabled = true,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    double? fontScale,
    bool? useFrontCamera,
    bool? useFlashlight,
    bool? denominationVibration,
    bool? shakeToGoBack,
    int? goBackTimerSeconds,
    bool? gesturalNavigation,
    bool? inertialNavigation,
    VisionProfile? visionProfile,
    bool? ttsEnabled,
    TtsVerbosity? ttsVerbosity,
    bool? hapticFeedback,
    HapticIntensity? hapticIntensity,
    bool? earconEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      fontScale: fontScale ?? this.fontScale,
      useFrontCamera: useFrontCamera ?? this.useFrontCamera,
      useFlashlight: useFlashlight ?? this.useFlashlight,
      denominationVibration:
          denominationVibration ?? this.denominationVibration,
      shakeToGoBack: shakeToGoBack ?? this.shakeToGoBack,
      goBackTimerSeconds: goBackTimerSeconds ?? this.goBackTimerSeconds,
      gesturalNavigation: gesturalNavigation ?? this.gesturalNavigation,
      inertialNavigation: inertialNavigation ?? this.inertialNavigation,
      visionProfile: visionProfile ?? this.visionProfile,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      ttsVerbosity: ttsVerbosity ?? this.ttsVerbosity,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      hapticIntensity: hapticIntensity ?? this.hapticIntensity,
      earconEnabled: earconEnabled ?? this.earconEnabled,
    );
  }

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:  return ThemeMode.light;
      case AppThemeMode.dark:   return ThemeMode.dark;
      case AppThemeMode.system: return ThemeMode.system;
    }
  }

  bool get isTagalog => language == AppLanguage.tagalog;
}
