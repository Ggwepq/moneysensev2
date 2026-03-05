import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/ps_action_tile.dart';
import '../../../../shared/widgets/ps_section_header.dart';
import '../../../../shared/widgets/ps_segmented_selector.dart';
import '../../../../shared/widgets/ps_settings_card.dart';
import '../../../../shared/widgets/ps_slider_tile.dart';
import '../../../../shared/widgets/ps_timer_tile.dart';
import '../../../../shared/widgets/ps_toggle_tile.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final l10n = AppLocalizations.of(settings.isTagalog);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(l10n.settings),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Help',
            onPressed: () {/* TODO: show global help */},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.base,
        ),
        children: [
          // ── General ────────────────────────────────────────────────────
          PsSectionHeader(title: l10n.sectionGeneral),
          PsSettingsCard(children: [
            // Theme selector
            _ThemeTile(
              label: l10n.theme,
              subtitle: l10n.settingSubtitle,
              themeMode: settings.themeMode,
              l10n: l10n,
              onChanged: notifier.setThemeMode,
            ),
            // Language selector
            _LanguageTile(
              label: l10n.language,
              subtitle: l10n.settingSubtitle,
              language: settings.language,
              l10n: l10n,
              onChanged: notifier.setLanguage,
            ),
            // Font Size slider
            PsSliderTile(
              title: l10n.fontSize,
              subtitle: l10n.fontSizeSubtitle,
              value: settings.fontScale,
              min: 0.8,
              max: 2.0,
              onChanged: notifier.setFontScale,
              displayLabel:
                  '${((settings.fontScale - 0.8) / (2.0 - 0.8) * 100).round()}%',
            ),
          ]),

          // ── Scanning ───────────────────────────────────────────────────
          PsSectionHeader(title: l10n.sectionScanning),
          PsSettingsCard(children: [
            PsToggleTile(
              title: l10n.useFrontCamera,
              subtitle: l10n.settingSubtitle,
              value: settings.useFrontCamera,
              onChanged: notifier.toggleFrontCamera,
            ),
            PsToggleTile(
              title: l10n.useFlashlight,
              subtitle: l10n.settingSubtitle,
              value: settings.useFlashlight,
              onChanged: notifier.toggleFlashlight,
            ),
            PsToggleTile(
              title: l10n.denominationVibration,
              subtitle: l10n.settingSubtitle,
              value: settings.denominationVibration,
              onChanged: notifier.toggleDenominationVibration,
              showHelpButton: true,
              onHelpTap: () => _showHelp(
                context,
                l10n.denominationVibration,
                'Each Philippine denomination produces a unique vibration pattern '
                'so you can identify it without looking at the screen.',
              ),
            ),
          ]),

          // ── Navigation ─────────────────────────────────────────────────
          PsSectionHeader(title: l10n.sectionNavigation),
          PsSettingsCard(children: [
            PsToggleTile(
              title: l10n.shakeToGoBack,
              subtitle: l10n.settingSubtitle,
              value: settings.shakeToGoBack,
              onChanged: notifier.toggleShakeToGoBack,
              showHelpButton: true,
              onHelpTap: () => _showHelp(
                context,
                l10n.shakeToGoBack,
                'Shake your phone to navigate back from any screen.',
              ),
            ),
            PsTimerTile(
              title: l10n.goBackTimerOnResult,
              subtitle: l10n.settingSubtitle,
              enabled: settings.goBackTimerSeconds > 0,
              value: settings.goBackTimerSeconds,
              onToggle: (v) =>
                  notifier.setGoBackTimer(v ? 20 : 0),
              onValueChanged: notifier.setGoBackTimer,
            ),
            PsToggleTile(
              title: l10n.gesturalNavigation,
              subtitle: l10n.settingSubtitle,
              value: settings.gesturalNavigation,
              onChanged: notifier.toggleGesturalNavigation,
              showHelpButton: true,
              onHelpTap: () => _showHelp(
                context,
                l10n.gesturalNavigation,
                'Swipe left to open Settings, right to open Tutorial, '
                'swipe up to toggle flash, and double-tap to force scan.',
              ),
            ),
            PsToggleTile(
              title: l10n.inertialNavigation,
              subtitle: l10n.settingSubtitle,
              value: settings.inertialNavigation,
              onChanged: notifier.toggleInertialNavigation,
              showHelpButton: true,
              onHelpTap: () => _showHelp(
                context,
                l10n.inertialNavigation,
                'Tilt your phone left to open Settings, '
                'tilt right to open the Tutorial screen.',
              ),
            ),
          ]),

          // ── Help & Support ─────────────────────────────────────────────
          PsSectionHeader(title: l10n.sectionHelpSupport),
          PsSettingsCard(children: [
            PsActionTile(
              title: l10n.checkForUpdates,
              subtitle: l10n.settingSubtitle,
              icon: Icons.refresh_rounded,
              onTap: () {/* TODO */},
            ),
            PsActionTile(
              title: l10n.playOnboardingSetup,
              subtitle: l10n.settingSubtitle,
              icon: Icons.play_arrow_rounded,
              onTap: () {/* TODO: navigate to onboarding */},
            ),
            PsActionTile(
              title: l10n.appInformation,
              subtitle: l10n.settingSubtitle,
              icon: Icons.info_outline_rounded,
              onTap: () {/* TODO */},
            ),
            PsActionTile(
              title: l10n.leaveAFeedback,
              subtitle: l10n.settingSubtitle,
              icon: Icons.campaign_outlined,
              onTap: () {/* TODO */},
            ),
            PsActionTile(
              title: l10n.termsOfServices,
              subtitle: l10n.settingSubtitle,
              icon: Icons.description_outlined,
              onTap: () {/* TODO */},
            ),
          ]),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// ── Theme Tile ───────────────────────────────────────────────────────────────

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.label,
    required this.subtitle,
    required this.themeMode,
    required this.l10n,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final AppThemeMode themeMode;
  final AppLocalizations l10n;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF0E0E0E),
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? const Color(0xFFAAAAAA)
                  : const Color(0xFF555555),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PsSegmentedSelector<AppThemeMode>(
            options: AppThemeMode.values,
            labels: [l10n.themeSystem, l10n.themeLight, l10n.themeDark],
            leadingIcons: [
              Icons.phone_android_rounded,
              Icons.light_mode_rounded,
              Icons.dark_mode_rounded,
            ],
            selected: themeMode,
            onSelected: onChanged,
          ),
        ],
      ),
    );
  }
}

// ── Language Tile ────────────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.subtitle,
    required this.language,
    required this.l10n,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final AppLanguage language;
  final AppLocalizations l10n;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF0E0E0E),
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? const Color(0xFFAAAAAA)
                  : const Color(0xFF555555),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PsSegmentedSelector<AppLanguage>(
            options: AppLanguage.values,
            labels: [l10n.languageEnglish, l10n.languageTagalog],
            selected: language,
            onSelected: onChanged,
          ),
        ],
      ),
    );
  }
}
