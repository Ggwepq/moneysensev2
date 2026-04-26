import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/earcon_service.dart';
import '../../../../core/services/speech_scripts.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../shared/widgets/full_screen_loader.dart';
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
      ref
          .read(ttsServiceProvider)
          .enqueue(
            msg,
            enabled: settings.ttsEnabled,
            currentVerbosity: settings.ttsVerbosity,
          );
    }

    // Derived states
    final isDark = settings.themeMode == AppThemeMode.dark;
    final isTagalog = settings.language == AppLanguage.tagalog;
    final isFrontCamera = settings.useFrontCamera;

    return _SwipeBackWrapper(
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
              // ── Scrollable grid ──────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BigRow(
                        children: [
                          // Font Size
                          _ToggleCard(
                            icon: Icons.format_size_rounded,
                            label: 'Font: ${settings.fontScale == 1.0 ? 'Medium' : settings.fontScale == 1.5 ? 'Large' : 'Small'}',
                            isActive: true,
                            onTap: () {
                               EarconService.instance.play(EarconEvent.actionConfirmed);
                               final next = settings.fontScale == 1.0 ? 1.5 : settings.fontScale == 1.5 ? 0.8 : 1.0;
                               notifier.setFontScale(next);
                               final label = next == 1.0 ? 'Medium' : next == 1.5 ? 'Large' : 'Small';
                               say(SettingsSpeech.changed(l10n, 'Font Size', label));
                            },
                          ),
                          // Speech Rate
                          _ToggleCard(
                            icon: Icons.speed_rounded,
                            label: 'Speed: ${settings.speechRate == 1.0 ? 'Normal' : settings.speechRate == 1.5 ? 'Fast' : 'Slow'}',
                            isActive: true,
                            onTap: () {
                               EarconService.instance.play(EarconEvent.actionConfirmed);
                               final next = settings.speechRate == 1.0 ? 1.5 : settings.speechRate == 1.5 ? 0.5 : 1.0;
                               notifier.setSpeechRate(next);
                               final label = next == 1.0 ? 'Normal' : next == 1.5 ? 'Fast' : 'Slow';
                               say(SettingsSpeech.changed(l10n, 'Speech Rate', label));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _BigRow(
                        children: [
                          // Dark Mode toggle
                          _ToggleCard(
                            icon: Icons.dark_mode_rounded,
                            label: l10n.themeDark,
                            isActive: isDark,
                            onTap: () {
                              final next = isDark
                                  ? AppThemeMode.light
                                  : AppThemeMode.dark;
                              EarconService.instance.play(
                                EarconEvent.actionConfirmed,
                              );
                              notifier.setThemeMode(next);
                              say(
                                SettingsSpeech.changed(
                                  l10n,
                                  l10n.theme,
                                  next == AppThemeMode.dark
                                      ? l10n.themeDark
                                      : l10n.themeLight,
                                ),
                              );
                            },
                          ),
                          // Language toggle: English ↔ Tagalog (one box)
                          _ToggleCard(
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
                      _BigRow(
                        children: [
                          // Front Camera toggle
                          _ToggleCard(
                            icon: Icons.camera_front_rounded,
                            label: 'Front Camera',
                            isActive: isFrontCamera,
                            onTap: () {
                              final nextIsFront = !isFrontCamera;
                              EarconService.instance.play(
                                nextIsFront
                                    ? EarconEvent.actionEnabled
                                    : EarconEvent.actionDisabled,
                              );
                              notifier.toggleFrontCamera(nextIsFront);
                              say(
                                SettingsSpeech.toggled(
                                  l10n,
                                  l10n.useFrontCamera,
                                  nextIsFront,
                                ),
                              );
                            },
                          ),
                          // Flashlight toggle
                          _ToggleCard(
                            icon: settings.useFlashlight
                                ? Icons.flashlight_on_rounded
                                : Icons.flashlight_off_rounded,
                            label: l10n.useFlashlight,
                            isActive: settings.useFlashlight,
                            onTap: () {
                              final next = !settings.useFlashlight;
                              EarconService.instance.play(
                                next
                                    ? EarconEvent.actionEnabled
                                    : EarconEvent.actionDisabled,
                              );
                              notifier.toggleFlashlight(next);
                              say(
                                SettingsSpeech.toggled(
                                  l10n,
                                  l10n.useFlashlight,
                                  next,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Vision Profile — full width, opens picker
                      _ToggleCardWide(
                        icon: _visionIcon(settings.visionProfile),
                        label: l10n.visionProfileTitle,
                        sublabel: _visionLabel(settings.visionProfile, l10n),
                        isActive: false,
                        onTap: () async {
                          EarconService.instance.play(
                            EarconEvent.actionConfirmed,
                          );
                          final selected = await Navigator.of(context).push<VisionProfile>(
                            MaterialPageRoute(
                              builder: (_) => VisionProfilePickerScreen(
                                current: settings.visionProfile,
                                l10n: l10n,
                              ),
                            ),
                          );
                          if (selected != null && selected != settings.visionProfile && context.mounted) {
                            notifier.setVisionProfile(selected);
                            final label = selected == VisionProfile.lowVision
                                ? l10n.visionLowVision
                                : selected == VisionProfile.partiallyBlind
                                ? l10n.visionPartiallyBlind
                                : l10n.visionFullyBlind;
                            say(
                              SettingsSpeech.changed(
                                l10n,
                                l10n.visionProfileTitle,
                                label,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _BigRow(
                        children: [
                          // Voice Command
                          _ToggleCard(
                            icon: settings.voiceNavigation
                                ? Icons.mic_rounded
                                : Icons.mic_off_rounded,
                            label: 'Voice Command',
                            isActive: settings.voiceNavigation,
                            onTap: () {
                              final next = !settings.voiceNavigation;
                              EarconService.instance.play(
                                next ? EarconEvent.actionEnabled : EarconEvent.actionDisabled,
                              );
                              notifier.toggleVoiceNavigation(next);
                              say(SettingsSpeech.toggled(l10n, 'Voice Command', next));
                            },
                          ),
                          // Clarify Voice Commands
                          _ToggleCard(
                            icon: settings.clarifyVoiceCommands
                                ? Icons.record_voice_over_rounded
                                : Icons.voice_over_off_rounded,
                            label: 'Clarify Command',
                            isActive: settings.clarifyVoiceCommands,
                            onTap: () {
                              final next = !settings.clarifyVoiceCommands;
                              EarconService.instance.play(
                                next ? EarconEvent.actionEnabled : EarconEvent.actionDisabled,
                              );
                              notifier.toggleClarifyVoiceCommands(next);
                              say(SettingsSpeech.toggled(l10n, 'Clarify Voice Commands', next));
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),
                      // ── Advanced Mode button (scrollable) ─────────────────
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
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.tileRadius,
                                ),
                              ),
                            ),
                            onPressed: () {
                              EarconService.instance.play(EarconEvent.actionConfirmed);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.settings_rounded,
                              size: 22,
                              color: Colors.black,
                            ),
                            label: Text(
                              l10n.advancedMode,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ], // End of inner Column children
                  ), // End of inner Column
                ), // End of SingleChildScrollView
              ), // End of Expanded
            ], // End of outer Column children
          ), // End of outer Column
        ), // End of Padding
      ), // End of SafeArea
      ), // End of Scaffold
    ); // End of _SwipeBackWrapper
  }

  // ── Language change helper ────────────────────────────────────────────────
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
    final newLangName = newLang == AppLanguage.tagalog
        ? newL10n.languageTagalog
        : newL10n.languageEnglish;

    FullScreenLoader.show(
      context,
      message: oldL10n.ttsLangChanging(newLangName),
    );
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
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (context.mounted) FullScreenLoader.hide(context);
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

// ── Two cards side by side ────────────────────────────────────────────────────

class _BigRow extends StatelessWidget {
  const _BigRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: AppSpacing.lg), // Increased from md
        Expanded(child: children.length > 1 ? children[1] : const SizedBox.shrink()),
      ],
    );
  }
}

// ── Square toggle card (half width) ──────────────────────────────────────────
// One box — tapping it switches the icon/label to the opposite state

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;
    final textColor = isActive
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Semantics(
      label: '$label. Button',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          // Remove fixed height, let content determine size
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,  // ← KEY: shrink to fit content
              children: [
                Icon(icon, size: 48, color: textColor),
                const SizedBox(height: 8),
                Flexible(  // ← KEY: allow text to wrap
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.visible,  // Allow wrapping
                      maxLines: 2,  // Allow 2 lines max
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
}
// ── Wide toggle card (full width) ─────────────────────────────────────────────

class _ToggleCardWide extends StatelessWidget {
  const _ToggleCardWide({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.sublabel,
  });

  final IconData icon;
  final String label;
  final String? sublabel;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;
    final textColor = isActive
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Semantics(
      label: '$label. ${sublabel ?? ''}. Button',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 44, color: textColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (sublabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        sublabel!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeBackWrapper extends StatelessWidget {
  const _SwipeBackWrapper({
    required this.child,
    required this.isGesturalNavigationEnabled,
  });
  final Widget child;
  final bool isGesturalNavigationEnabled;

  static const double _minVelocity = 300.0;
  static const double _maxCrossRatio = 0.55;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        if (!isGesturalNavigationEnabled) return;
        final v = details.velocity.pixelsPerSecond;
        final ax = v.dx.abs();
        final ay = v.dy.abs();
        if (ax < _minVelocity) return;
        if (ax < ay) return;
        if (ay / ax > _maxCrossRatio) return;
        if (v.dx < 0) {
          EarconService.instance.play(EarconEvent.navBack);
          Navigator.of(context).maybePop();
        }
      },
      child: child,
    );
  }
}


