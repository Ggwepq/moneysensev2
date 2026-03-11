import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/speech_scripts.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../shared/widgets/full_screen_loader.dart';
import '../../../../shared/widgets/ms_action_tile.dart';
import '../../../../shared/widgets/ms_section_header.dart';
import '../../../../shared/widgets/ms_segmented_selector.dart';
import '../../../../shared/widgets/ms_settings_card.dart';
import '../../../../shared/widgets/ms_slider_tile.dart';
import '../../../../shared/widgets/ms_timer_tile.dart';
import '../../../../shared/widgets/ms_toggle_tile.dart';
import '../../../tutorial/domain/tutorial_route.dart';
import '../../../tutorial/presentation/screens/tutorial_navigator.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/vision_config.dart';
import '../providers/settings_provider.dart';
import '../../../../core/services/earcon_service.dart';
import '../../../../core/services/haptic_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings     = ref.watch(appSettingsProvider);
    final notifier     = ref.read(appSettingsProvider.notifier);
    final visionConfig = ref.watch(visionConfigProvider);
    final l10n         = AppLocalizations.of(settings.isTagalog);
    final isFullVerbosity = settings.ttsVerbosity == TtsVerbosity.full;

    // ── TTS helper: one line at every call site ──────────────────────────
    void say(TtsMessage msg) {
      ref.read(ttsServiceProvider).enqueue(
            msg,
            enabled: settings.ttsEnabled,
            currentVerbosity: settings.ttsVerbosity,
          );
    }

    return _SwipeBackWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline_rounded),
              tooltip: 'Help',
              onPressed: () {/* TODO */},
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.base,
          ),
          children: [
            // ── General ────────────────────────────────────────────────
            MsSectionHeader(title: l10n.sectionGeneral),
            MsSettingsCard(children: [
              _ThemeTile(
                label: l10n.theme,
                subtitle: isFullVerbosity
                    ? l10n.themeSubtitleFull
                    : l10n.themeSubtitle,
                themeMode: settings.themeMode,
                l10n: l10n,
                visionConfig: visionConfig,
                onChanged: (v) {
                  notifier.setThemeMode(v);
                  final label = v == AppThemeMode.system
                      ? l10n.themeSystem
                      : v == AppThemeMode.light
                          ? l10n.themeLight
                          : l10n.themeDark;
                  say(SettingsSpeech.changed(l10n, l10n.theme, label));
                },
              ),
              _LanguageTile(
                label: l10n.language,
                subtitle: isFullVerbosity
                    ? l10n.languageSubtitleFull
                    : l10n.languageSubtitle,
                language: settings.language,
                l10n: l10n,
                visionConfig: visionConfig,
                onChanged: notifier.setLanguage,
              ),
              MsSliderTile(
                title: l10n.fontSize,
                subtitle: isFullVerbosity
                    ? l10n.fontSizeSubtitleFull
                    : l10n.fontSizeSubtitle,
                value: settings.fontScale,
                min: 0.8,
                max: 2.0,
                onChanged: (v) {
                  notifier.setFontScale(v);
                  final pct = ((v - 0.8) / (2.0 - 0.8) * 100).round();
                  say(SettingsSpeech.changed(l10n, l10n.fontSize, '$pct%'));
                },
                displayLabel:
                    '${((settings.fontScale - 0.8) / (2.0 - 0.8) * 100).round()}%',
              ),
            ]),

            // ── Scanning ───────────────────────────────────────────────
            MsSectionHeader(title: l10n.sectionScanning),
            MsSettingsCard(children: [
              MsToggleTile(
                title: l10n.useFrontCamera,
                subtitle: isFullVerbosity
                    ? l10n.useFrontCameraSubtitleFull
                    : l10n.useFrontCameraSubtitle,
                value: settings.useFrontCamera,
                onChanged: (v) {
                  notifier.toggleFrontCamera(v);
                  say(SettingsSpeech.toggled(l10n, l10n.useFrontCamera, v));
                },
              ),
              MsToggleTile(
                title: l10n.useFlashlight,
                subtitle: isFullVerbosity
                    ? l10n.useFlashlightSubtitleFull
                    : l10n.useFlashlightSubtitle,
                value: settings.useFlashlight,
                onChanged: (v) {
                  notifier.toggleFlashlight(v);
                  say(SettingsSpeech.toggled(l10n, l10n.useFlashlight, v));
                },
              ),
              MsToggleTile(
                title: l10n.denominationVibration,
                subtitle: isFullVerbosity
                    ? l10n.denominationVibrationSubtitleFull
                    : l10n.denominationVibrationSubtitle,
                value: settings.denominationVibration,
                onChanged: (v) {
                  notifier.toggleDenominationVibration(v);
                  say(SettingsSpeech.toggled(
                      l10n, l10n.denominationVibration, v));
                },
                showHelpButton: true,
                onHelpTap: () => TutorialNavigator.push(
                    context, TutorialRoute.denominationVibration),
              ),
            ]),

            // ── Navigation ─────────────────────────────────────────────
            MsSectionHeader(title: l10n.sectionNavigation),
            MsSettingsCard(children: [
              MsToggleTile(
                title: l10n.shakeToGoBack,
                subtitle: isFullVerbosity
                    ? l10n.shakeToGoBackSubtitleFull
                    : l10n.shakeToGoBackSubtitle,
                value: settings.shakeToGoBack,
                onChanged: (v) {
                  notifier.toggleShakeToGoBack(v);
                  say(SettingsSpeech.toggled(l10n, l10n.shakeToGoBack, v));
                },
                showHelpButton: true,
                onHelpTap: () => TutorialNavigator.push(
                    context, TutorialRoute.shakeToGoBack),
              ),
              MsTimerTile(
                title: l10n.goBackTimerOnResult,
                subtitle: isFullVerbosity
                    ? l10n.goBackTimerSubtitleFull
                    : l10n.goBackTimerSubtitle,
                enabled: settings.goBackTimerSeconds > 0,
                value: settings.goBackTimerSeconds > 0
                    ? settings.goBackTimerSeconds
                    : 20,
                onToggle: (v) {
                  notifier.toggleGoBackTimer(v);
                  say(SettingsSpeech.toggled(
                      l10n, l10n.goBackTimerOnResult, v));
                },
                onValueChanged: notifier.setGoBackTimer,
              ),
              MsToggleTile(
                title: l10n.gesturalNavigation,
                subtitle: isFullVerbosity
                    ? l10n.gesturalNavigationSubtitleFull
                    : l10n.gesturalNavigationSubtitle,
                value: settings.gesturalNavigation,
                onChanged: (v) {
                  notifier.toggleGesturalNavigation(v);
                  say(SettingsSpeech.toggled(
                      l10n, l10n.gesturalNavigation, v));
                },
                showHelpButton: true,
                onHelpTap: () => TutorialNavigator.push(
                    context, TutorialRoute.gesturalNavigation),
              ),
              MsToggleTile(
                title: l10n.inertialNavigation,
                subtitle: isFullVerbosity
                    ? l10n.inertialNavigationSubtitleFull
                    : l10n.inertialNavigationSubtitle,
                value: settings.inertialNavigation,
                onChanged: (v) {
                  notifier.toggleInertialNavigation(v);
                  say(SettingsSpeech.toggled(
                      l10n, l10n.inertialNavigation, v));
                },
                showHelpButton: true,
                onHelpTap: () => TutorialNavigator.push(
                    context, TutorialRoute.inertialNavigation),
              ),
            ]),

            // ── Accessibility ───────────────────────────────────────────
            MsSectionHeader(title: l10n.sectionAccessibility),
            MsSettingsCard(children: [
              _VisionProfileTile(
                label:    l10n.visionProfileTitle,
                subtitle: isFullVerbosity
                    ? l10n.visionProfileSubtitleFull
                    : l10n.visionProfileSubtitle,
                profile:  settings.visionProfile,
                l10n:     l10n,
                visionConfig: visionConfig,
                onChanged: (v) {
                  notifier.setVisionProfile(v);
                  final label = v == VisionProfile.lowVision
                      ? l10n.visionLowVision
                      : v == VisionProfile.partiallyBlind
                          ? l10n.visionPartiallyBlind
                          : l10n.visionFullyBlind;
                  say(SettingsSpeech.changed(
                      l10n, l10n.visionProfileTitle, label));
                },
              ),
              // TTS toggle: spoken BEFORE turning off so user hears it.
              MsToggleTile(
                title:    l10n.ttsTitle,
                subtitle: isFullVerbosity
                    ? l10n.ttsSubtitleFull
                    : l10n.ttsSubtitle,
                value: settings.ttsEnabled,
                onChanged: (v) {
                  if (!v) {
                    // Announce disabling while TTS is still on, THEN turn off
                    say(AppSpeech.ttsDisabling(l10n));
                    Future.delayed(const Duration(milliseconds: 1200), () {
                      notifier.toggleTts(false);
                    });
                  } else {
                    notifier.toggleTts(true);
                    say(AppSpeech.ttsEnabled(l10n));
                  }
                },
              ),
              if (settings.ttsEnabled)
                _VerbosityTile(
                  label:    l10n.ttsVerbosityTitle,
                  subtitle: isFullVerbosity
                      ? l10n.ttsVerbositySubtitleFull
                      : l10n.ttsVerbositySubtitle,
                  verbosity: settings.ttsVerbosity,
                  l10n:     l10n,
                  visionConfig: visionConfig,
                  onChanged: (v) {
                    notifier.setTtsVerbosity(v);
                    final label = v == TtsVerbosity.minimal
                        ? l10n.ttsVerbosityMinimal
                        : v == TtsVerbosity.standard
                            ? l10n.ttsVerbosityStandard
                            : l10n.ttsVerbosityFull;
                    say(SettingsSpeech.changed(
                        l10n, l10n.ttsVerbosityTitle, label));
                  },
                ),
              MsToggleTile(
                title:    l10n.hapticTitle,
                subtitle: isFullVerbosity
                    ? l10n.hapticSubtitleFull
                    : l10n.hapticSubtitle,
                value: settings.hapticFeedback,
                onChanged: (v) {
                  notifier.toggleHapticFeedback(v);
                  say(SettingsSpeech.toggled(l10n, l10n.hapticTitle, v));
                },
              ),
              if (settings.hapticFeedback)
                _HapticIntensityTile(
                  label:     l10n.hapticIntensityTitle,
                  subtitle:  isFullVerbosity
                      ? l10n.hapticIntensitySubtitleFull
                      : l10n.hapticIntensitySubtitle,
                  intensity: settings.hapticIntensity,
                  l10n:      l10n,
                  visionConfig: visionConfig,
                  onChanged: (v) {
                    notifier.setHapticIntensity(v);
                    final label = v == HapticIntensity.subtle
                        ? l10n.hapticIntensitySubtle
                        : v == HapticIntensity.medium
                            ? l10n.hapticIntensityMedium
                            : l10n.hapticIntensityStrong;
                    say(SettingsSpeech.changed(
                        l10n, l10n.hapticIntensityTitle, label));
                  },
                ),
              MsToggleTile(
                title:    l10n.earconTitle,
                subtitle: isFullVerbosity
                    ? l10n.earconSubtitleFull
                    : l10n.earconSubtitle,
                value: settings.earconEnabled,
                onChanged: (v) {
                  notifier.toggleEarcon(v);
                  EarconService.instance.setEnabled(v);
                  say(SettingsSpeech.toggled(l10n, l10n.earconTitle, v));
                },
              ),
            ]),

            // ── Help & Support ─────────────────────────────────────────
            MsSectionHeader(title: l10n.sectionHelpSupport),
            MsSettingsCard(children: [
              MsActionTile(
                title: l10n.checkForUpdates,
                subtitle: l10n.checkForUpdatesSubtitle,
                icon: Icons.refresh_rounded,
                onTap: () {/* TODO */},
              ),
              MsActionTile(
                title: l10n.playOnboardingSetup,
                subtitle: l10n.playOnboardingSubtitle,
                icon: Icons.play_arrow_rounded,
                onTap: () {
                  // Pop settings first so the slide transition is clean,
                  // then reset the flag: _AppRoot rebuilds to onboarding.
                  Navigator.of(context).pop();
                  ref.read(onboardingCompleteProvider.notifier).state = false;
                },
              ),
              MsActionTile(
                title: l10n.appInformation,
                subtitle: l10n.appInformationSubtitle,
                icon: Icons.info_outline_rounded,
                onTap: () {/* TODO */},
              ),
              MsActionTile(
                title: l10n.leaveAFeedback,
                subtitle: l10n.leaveAFeedbackSubtitle,
                icon: Icons.campaign_outlined,
                onTap: () {/* TODO */},
              ),
              MsActionTile(
                title: l10n.termsOfServices,
                subtitle: l10n.termsOfServicesSubtitle,
                icon: Icons.description_outlined,
                onTap: () {/* TODO */},
              ),
            ]),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}


class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.label,
    required this.subtitle,
    required this.themeMode,
    required this.l10n,
    required this.visionConfig,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final AppThemeMode themeMode;
  final AppLocalizations l10n;
  final VisionConfig visionConfig;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);

    final selectedLabel = themeMode == AppThemeMode.system
        ? l10n.themeSystem
        : themeMode == AppThemeMode.light
            ? l10n.themeLight
            : l10n.themeDark;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            label: '$label. $subtitle. Currently: $selectedLabel',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
                Text(subtitle,
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MsSegmentedSelector<AppThemeMode>(
            options: AppThemeMode.values,
            labels: [l10n.themeSystem, l10n.themeLight, l10n.themeDark],
            leadingIcons: [
              Icons.phone_android_rounded,
              Icons.light_mode_rounded,
              Icons.dark_mode_rounded,
            ],
            selected: themeMode,
            onSelected: onChanged,
            accentColor: visionConfig.accentYellow,
          ),
        ],
      ),
    );
  }
}

// Language Tile
// Stateful so it can show a full-screen blocking loader during engine switch.
//
// Flow:
//   1. User taps a pill.
//   2. Full-screen loader appears (blocks all input).
//   3. "Changing audio to X" spoken in old language.
//   4. TTS engine switches language (awaited).
//   5. "Done. Now speaking X" spoken in new language.
//   6. Loader dismissed after the "done" audio has time to start playing.

class _LanguageTile extends ConsumerStatefulWidget {
  const _LanguageTile({
    required this.label,
    required this.subtitle,
    required this.language,
    required this.l10n,
    required this.visionConfig,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final AppLanguage language;
  final AppLocalizations l10n;
  final VisionConfig visionConfig;
  final ValueChanged<AppLanguage> onChanged;

  @override
  ConsumerState<_LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends ConsumerState<_LanguageTile> {
  bool _isChanging = false;

  Future<void> _handleChange(AppLanguage newLang) async {
    if (_isChanging || newLang == widget.language) return;

    final tts      = ref.read(ttsServiceProvider);
    final settings = ref.read(appSettingsProvider);
    final oldL10n  = widget.l10n;
    final newL10n  = AppLocalizations.of(newLang == AppLanguage.tagalog);
    final newLangName = newLang == AppLanguage.tagalog
        ? newL10n.languageTagalog
        : newL10n.languageEnglish;

    if (!mounted) return;
    _isChanging = true;

    // Show full-screen blocking loader with the "changing" message
    FullScreenLoader.show(
      context,
      message: oldL10n.ttsLangChanging(newLangName),
    );

    // Speak "Changing audio to X" in the OLD language
    tts.enqueue(
      LanguageSpeech.changing(oldL10n, newLangName),
      enabled: settings.ttsEnabled,
      currentVerbosity: settings.ttsVerbosity,
    );

    // Persist setting
    widget.onChanged(newLang);

    // Switch the engine: this is the async work being blocked for
    await tts.changeLanguage(newLang);

    // Speak "Done. Now speaking X" in the NEW language
    tts.enqueue(
      LanguageSpeech.done(newL10n, newLangName),
      enabled: settings.ttsEnabled,
      currentVerbosity: settings.ttsVerbosity,
    );

    // Short delay so TTS "done" announcement starts before overlay disappears.
    // The user hears the confirmation, THEN the screen unlocks.
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      FullScreenLoader.hide(context);
      _isChanging = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final selectedLabel = widget.language == AppLanguage.english
        ? widget.l10n.languageEnglish
        : widget.l10n.languageTagalog;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            label: '${widget.label}. ${widget.subtitle}. Currently: $selectedLabel',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
                Text(widget.subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MsSegmentedSelector<AppLanguage>(
            options: AppLanguage.values,
            labels: [
              widget.l10n.languageEnglish,
              widget.l10n.languageTagalog,
            ],
            selected: widget.language,
            onSelected: _handleChange,
            accentColor: widget.visionConfig.accentYellow,
          ),
        ],
      ),
    );
  }
}


class _VisionProfileTile extends StatelessWidget {
  const _VisionProfileTile({
    required this.label,
    required this.subtitle,
    required this.profile,
    required this.l10n,
    required this.visionConfig,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final VisionProfile profile;
  final AppLocalizations l10n;
  final VisionConfig visionConfig;
  final ValueChanged<VisionProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    // Use theme-aware color so text is always legible regardless of contrast level
    final titleColor = theme.textTheme.bodyLarge?.color;
    final subtitleColor = theme.textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            label: '$label. $subtitle.',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    )),
                Text(subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MsSegmentedSelector<VisionProfile>(
            options: VisionProfile.values,
            labels: [
              l10n.visionLowVision,
              l10n.visionPartiallyBlind,
              l10n.visionFullyBlind,
            ],
            leadingIcons: [
              Icons.visibility_rounded,
              Icons.visibility_off_rounded,
              Icons.blind_rounded,
            ],
            selected: profile,
            onSelected: onChanged,
            accentColor: visionConfig.accentYellow,
          ),
        ],
      ),
    );
  }
}


class _VerbosityTile extends StatelessWidget {
  const _VerbosityTile({
    required this.label,
    required this.subtitle,
    required this.verbosity,
    required this.l10n,
    required this.visionConfig,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final TtsVerbosity verbosity;
  final AppLocalizations l10n;
  final VisionConfig visionConfig;
  final ValueChanged<TtsVerbosity> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            label: '$label. $subtitle.',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MsSegmentedSelector<TtsVerbosity>(
            options: TtsVerbosity.values,
            labels: [
              l10n.ttsVerbosityMinimal,
              l10n.ttsVerbosityStandard,
              l10n.ttsVerbosityFull,
            ],
            leadingIcons: [
              Icons.volume_mute_rounded,
              Icons.volume_down_rounded,
              Icons.volume_up_rounded,
            ],
            selected: verbosity,
            onSelected: onChanged,
            accentColor: visionConfig.accentYellow,
          ),
        ],
      ),
    );
  }
}

// Haptic Intensity Tile

class _HapticIntensityTile extends StatelessWidget {
  const _HapticIntensityTile({
    required this.label,
    required this.subtitle,
    required this.intensity,
    required this.l10n,
    required this.visionConfig,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final HapticIntensity intensity;
  final AppLocalizations l10n;
  final VisionConfig visionConfig;
  final ValueChanged<HapticIntensity> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            label: '$label. $subtitle.',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MsSegmentedSelector<HapticIntensity>(
            options: HapticIntensity.values,
            labels: [
              l10n.hapticIntensitySubtle,
              l10n.hapticIntensityMedium,
              l10n.hapticIntensityStrong,
            ],
            leadingIcons: [
              Icons.vibration_rounded,
              Icons.phone_android_rounded,
              Icons.waves_rounded,
            ],
            selected: intensity,
            onSelected: (v) {
              onChanged(v);
              HapticService.toggle(enabled: true, intensity: v);
            },
            accentColor: visionConfig.accentYellow,
          ),
        ],
      ),
    );
  }
}


class _SwipeBackWrapper extends StatelessWidget {
  const _SwipeBackWrapper({required this.child});
  final Widget child;

  static const double _minVelocity   = 300.0;
  static const double _maxCrossRatio = 0.55;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        final v  = details.velocity.pixelsPerSecond;
        final ax = v.dx.abs();
        final ay = v.dy.abs();
        if (ax < _minVelocity) return;
        if (ax < ay) return;
        if (ay / ax > _maxCrossRatio) return;
        if (v.dx < 0) Navigator.of(context).maybePop();
      },
      child: child,
    );
  }
}
