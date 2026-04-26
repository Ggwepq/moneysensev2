import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/earcon_service.dart';
import '../../../../core/services/speech_scripts.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../shared/widgets/full_screen_loader.dart';
import '../../../../shared/widgets/ms_big_row.dart';
import '../../../../shared/widgets/ms_swipe_back_wrapper.dart';
import '../../../../shared/widgets/ms_toggle_card.dart';
import '../../../../shared/widgets/ms_toggle_card_wide.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_provider.dart';
import 'settings_screen.dart';
import 'vision_profile_picker_screen.dart';

class SimpleSettingsScreen extends ConsumerWidget {
  const SimpleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final l10n = AppLocalizations.of(settings.isTagalog);

    void say(TtsMessage msg) {
      ref.read(ttsServiceProvider).enqueue(
            msg,
            enabled: settings.ttsEnabled,
            currentVerbosity: settings.ttsVerbosity,
          );
    }

    // Derived states
    final isDark = settings.themeMode == AppThemeMode.dark;
    final isTagalog = settings.language == AppLanguage.tagalog;
    final isFrontCamera = settings.useFrontCamera;

    return MsSwipeBackWrapper(
      isGesturalNavigationEnabled: settings.gesturalNavigation,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              EarconService.instance.play(EarconEvent.navBack);
              Navigator.of(context).maybePop();
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
              vertical: AppSpacing.base,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MsBigRow(
                          children: [
                            // Font Size
                            MsToggleCard(
                              icon: Icons.format_size_rounded,
                              label:
                                  '${l10n.fontSize}: ${_fontValueLabel(settings.fontScale, l10n)}',
                              isActive: true,
                              onTap: () {
                                EarconService.instance.play(EarconEvent.actionConfirmed);
                                final next = settings.fontScale == 1.0
                                    ? 1.5
                                    : settings.fontScale == 1.5
                                        ? 0.8
                                        : 1.0;
                                notifier.setFontScale(next);
                                say(SettingsSpeech.changed(
                                  l10n,
                                  l10n.fontSize,
                                  _fontValueLabel(next, l10n),
                                ));
                              },
                            ),
                            // Speech Rate
                            MsToggleCard(
                              icon: Icons.speed_rounded,
                              label:
                                  '${l10n.speechRate}: ${_speedValueLabel(settings.speechRate, l10n)}',
                              isActive: true,
                              onTap: () {
                                EarconService.instance.play(EarconEvent.actionConfirmed);
                                final next = settings.speechRate == 1.0
                                    ? 1.5
                                    : settings.speechRate == 1.5
                                        ? 0.5
                                        : 1.0;
                                notifier.setSpeechRate(next);
                                say(SettingsSpeech.changed(
                                  l10n,
                                  l10n.speechRate,
                                  _speedValueLabel(next, l10n),
                                ));
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        MsBigRow(
                          children: [
                            // Theme toggle
                            MsToggleCard(
                              icon: isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              label: isDark ? l10n.themeDark : l10n.themeLight,
                              isActive: isDark, // Highlight only if dark
                              onTap: () {
                                final next = isDark ? AppThemeMode.light : AppThemeMode.dark;
                                EarconService.instance.play(EarconEvent.actionConfirmed);
                                notifier.setThemeMode(next);
                                say(SettingsSpeech.changed(
                                  l10n,
                                  l10n.theme,
                                  next == AppThemeMode.dark
                                      ? l10n.themeDark
                                      : l10n.themeLight,
                                ));
                              },
                            ),
                            // Language toggle
                            MsToggleCard(
                              icon: Icons.language_rounded,
                              label: isTagalog
                                  ? l10n.languageTagalog
                                  : l10n.languageEnglish,
                              isActive: true,
                              onTap: () async {
                                final newLang = isTagalog
                                    ? AppLanguage.english
                                    : AppLanguage.tagalog;
                                await _changeLanguage(
                                  context,
                                  ref,
                                  newLang,
                                  l10n,
                                  settings,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        MsBigRow(
                          children: [
                            // Camera toggle
                            MsToggleCard(
                              icon: isFrontCamera
                                  ? Icons.camera_front_rounded
                                  : Icons.camera_rear_rounded,
                              label: isFrontCamera ? 'Front Cam' : 'Back Cam',
                              isActive: isFrontCamera, // Highlight if front
                              onTap: () {
                                final nextIsFront = !isFrontCamera;
                                EarconService.instance.play(nextIsFront
                                    ? EarconEvent.actionEnabled
                                    : EarconEvent.actionDisabled);
                                notifier.toggleFrontCamera(nextIsFront);
                                say(SettingsSpeech.toggled(
                                  l10n,
                                  l10n.useFrontCamera,
                                  nextIsFront,
                                ));
                              },
                            ),
                            // Flashlight toggle
                            MsToggleCard(
                              icon: settings.useFlashlight
                                  ? Icons.flashlight_on_rounded
                                  : Icons.flashlight_off_rounded,
                              label: l10n.useFlashlight,
                              isActive: settings.useFlashlight,
                              onTap: () {
                                final next = !settings.useFlashlight;
                                EarconService.instance.play(next
                                    ? EarconEvent.actionEnabled
                                    : EarconEvent.actionDisabled);
                                notifier.toggleFlashlight(next);
                                say(SettingsSpeech.toggled(
                                  l10n,
                                  l10n.useFlashlight,
                                  next,
                                ));
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        MsBigRow(
                          children: [
                            // Voice Command Toggle
                            MsToggleCard(
                              icon: settings.voiceNavigation
                                  ? Icons.mic_rounded
                                  : Icons.mic_off_rounded,
                              label: l10n.voiceNavigation,
                              isActive: settings.voiceNavigation,
                              onTap: () {
                                final next = !settings.voiceNavigation;
                                EarconService.instance.play(next
                                    ? EarconEvent.actionEnabled
                                    : EarconEvent.actionDisabled);
                                notifier.toggleVoiceNavigation(next);
                                say(SettingsSpeech.toggled(l10n, l10n.voiceNavigation, next));
                              },
                            ),
                            // Clarify Commands Toggle
                            MsToggleCard(
                              icon: settings.clarifyVoiceCommands
                                  ? Icons.fact_check_rounded
                                  : Icons.fact_check_outlined,
                              label: l10n.clarifyVoiceCommandsTitle,
                              isActive: settings.clarifyVoiceCommands,
                              onTap: () {
                                final next = !settings.clarifyVoiceCommands;
                                EarconService.instance.play(next
                                    ? EarconEvent.actionEnabled
                                    : EarconEvent.actionDisabled);
                                notifier.toggleClarifyVoiceCommands(next);
                                say(SettingsSpeech.toggled(l10n, l10n.clarifyVoiceCommandsTitle, next));
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Text Verbosity - Cycle through options
                        MsToggleCardWide(
                          icon: Icons.short_text_rounded,
                          label: l10n.textVerbosityTitle,
                          sublabel: settings.textVerbosity == TextVerbosity.minimal
                              ? l10n.textVerbosityMinimal
                              : settings.textVerbosity == TextVerbosity.standard
                                  ? l10n.textVerbosityStandard
                                  : l10n.textVerbosityFull,
                          isActive: true,
                          onTap: () {
                            EarconService.instance.play(EarconEvent.actionConfirmed);
                            final next = settings.textVerbosity == TextVerbosity.minimal
                                ? TextVerbosity.standard
                                : settings.textVerbosity == TextVerbosity.standard
                                    ? TextVerbosity.full
                                    : TextVerbosity.minimal;
                            notifier.setTextVerbosity(next);
                            final label = next == TextVerbosity.minimal
                                ? l10n.textVerbosityMinimal
                                : next == TextVerbosity.standard
                                    ? l10n.textVerbosityStandard
                                    : l10n.textVerbosityFull;
                            say(SettingsSpeech.changed(l10n, l10n.textVerbosityTitle, label));
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Vision Profile (Full Width Card)
                        MsToggleCardWide(
                          icon: _visionIcon(settings.visionProfile),
                          label: l10n.visionProfileTitle,
                          sublabel: _visionLabel(settings.visionProfile, l10n),
                          isActive: false,
                          onTap: () async {
                            EarconService.instance.play(EarconEvent.actionConfirmed);
                            final selected = await Navigator.of(context).push<VisionProfile>(
                              MaterialPageRoute(
                                builder: (_) => VisionProfilePickerScreen(
                                  current: settings.visionProfile,
                                  l10n: l10n,
                                ),
                              ),
                            );
                            if (selected != null &&
                                selected != settings.visionProfile &&
                                context.mounted) {
                              notifier.setVisionProfile(selected);
                              say(SettingsSpeech.changed(
                                l10n,
                                l10n.visionProfileTitle,
                                _visionLabel(selected, l10n),
                              ));
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Advanced Mode button
                        Semantics(
                          label: 'Advanced Mode. Go back to the full settings page.',
                          button: true,
                          excludeSemantics: true,
                          child: SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD600),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                                ),
                              ),
                              onPressed: () {
                                EarconService.instance.play(EarconEvent.actionConfirmed);
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                );
                              },
                              icon: const Icon(Icons.settings_rounded, size: 24),
                              label: Text(
                                l10n.advancedMode,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changeLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage newLang,
    AppLocalizations oldL10n,
    AppSettings settings,
  ) async {
    final tts = ref.read(ttsServiceProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final newL10n = AppLocalizations.of(newLang == AppLanguage.tagalog);
    final newLangName =
        newLang == AppLanguage.tagalog ? newL10n.languageTagalog : newL10n.languageEnglish;

    FullScreenLoader.show(context, message: oldL10n.ttsLangChanging(newLangName));
    EarconService.instance.play(EarconEvent.actionConfirmed);

    tts.enqueue(
      LanguageSpeech.changing(oldL10n, newLangName),
      enabled: settings.ttsEnabled,
      currentVerbosity: settings.ttsVerbosity,
    );

    notifier.setLanguage(newLang);
    await tts.changeLanguage(newLang);

    tts.enqueue(
      LanguageSpeech.done(newL10n, newLangName),
      enabled: settings.ttsEnabled,
      currentVerbosity: settings.ttsVerbosity,
    );

    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (context.mounted) FullScreenLoader.hide(context);
  }

  String _fontValueLabel(double scale, AppLocalizations l10n) {
    if (scale >= 1.4) return l10n.fontSizeLarge;
    if (scale <= 0.9) return l10n.fontSizeSmall;
    return l10n.fontSizeMedium;
  }

  String _speedValueLabel(double rate, AppLocalizations l10n) {
    if (rate >= 1.4) return l10n.speechRateFast;
    if (rate <= 0.6) return l10n.speechRateSlow;
    return l10n.speechRateNormal;
  }

  IconData _visionIcon(VisionProfile p) => switch (p) {
        VisionProfile.lowVision => Icons.visibility_rounded,
        VisionProfile.partiallyBlind => Icons.visibility_off_rounded,
        VisionProfile.fullyBlind => Icons.blind_rounded,
      };

  String _visionLabel(VisionProfile p, AppLocalizations l10n) => switch (p) {
        VisionProfile.lowVision => l10n.visionLowVision,
        VisionProfile.partiallyBlind => l10n.visionPartiallyBlind,
        VisionProfile.fullyBlind => l10n.visionFullyBlind,
      };
}
