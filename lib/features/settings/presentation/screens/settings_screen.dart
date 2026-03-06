import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
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
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final l10n = AppLocalizations.of(settings.isTagalog);

    return _SwipeBackWrapper(
      child: Scaffold(
      appBar: AppBar(
        // Flutter automatically inserts a back button and wires it to
        // Navigator.pop when this screen is pushed onto the stack.
        // No manual leading / onPressed needed.
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
          MsSectionHeader(title: l10n.sectionGeneral),
          MsSettingsCard(children: [
            // Theme selector
            _ThemeTile(
              label: l10n.theme,
              subtitle: l10n.themeSubtitle,
              themeMode: settings.themeMode,
              l10n: l10n,
              onChanged: notifier.setThemeMode,
            ),
            // Language selector
            _LanguageTile(
              label: l10n.language,
              subtitle: l10n.languageSubtitle,
              language: settings.language,
              l10n: l10n,
              onChanged: notifier.setLanguage,
            ),
            // Font Size slider
            MsSliderTile(
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
          MsSectionHeader(title: l10n.sectionScanning),
          MsSettingsCard(children: [
            MsToggleTile(
              title: l10n.useFrontCamera,
              subtitle: l10n.useFrontCameraSubtitle,
              value: settings.useFrontCamera,
              onChanged: notifier.toggleFrontCamera,
            ),
            MsToggleTile(
              title: l10n.useFlashlight,
              subtitle: l10n.useFlashlightSubtitle,
              value: settings.useFlashlight,
              onChanged: notifier.toggleFlashlight,
            ),
            MsToggleTile(
              title: l10n.denominationVibration,
              subtitle: l10n.denominationVibrationSubtitle,
              value: settings.denominationVibration,
              onChanged: notifier.toggleDenominationVibration,
              showHelpButton: true,
              onHelpTap: () => TutorialNavigator.push(
                  context, TutorialRoute.denominationVibration),
            ),
          ]),

          // ── Navigation ─────────────────────────────────────────────────
          MsSectionHeader(title: l10n.sectionNavigation),
          MsSettingsCard(children: [
            MsToggleTile(
              title: l10n.shakeToGoBack,
              subtitle: l10n.shakeToGoBackSubtitle,
              value: settings.shakeToGoBack,
              onChanged: notifier.toggleShakeToGoBack,
              showHelpButton: true,
              onHelpTap: () => TutorialNavigator.push(
                  context, TutorialRoute.shakeToGoBack),
            ),
            MsTimerTile(
              title: l10n.goBackTimerOnResult,
              subtitle: l10n.goBackTimerSubtitle,
              enabled: settings.goBackTimerSeconds > 0,
              value: settings.goBackTimerSeconds > 0
                  ? settings.goBackTimerSeconds
                  : 20,
              onToggle: notifier.toggleGoBackTimer,
              onValueChanged: notifier.setGoBackTimer,
            ),
            MsToggleTile(
              title: l10n.gesturalNavigation,
              subtitle: l10n.gesturalNavigationSubtitle,
              value: settings.gesturalNavigation,
              onChanged: notifier.toggleGesturalNavigation,
              showHelpButton: true,
              onHelpTap: () => TutorialNavigator.push(
                  context, TutorialRoute.gesturalNavigation),
            ),
            MsToggleTile(
              title: l10n.inertialNavigation,
              subtitle: l10n.inertialNavigationSubtitle,
              value: settings.inertialNavigation,
              onChanged: notifier.toggleInertialNavigation,
              showHelpButton: true,
              onHelpTap: () => showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(l10n.inertialNavigation),
                  content: Text(l10n.inertialDialogBody),
                  actions: [
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.gotIt),
                    ),
                  ],
                ),
              ),
            ),
          ]),

          // ── Help & Support ─────────────────────────────────────────────
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
              onTap: () {/* TODO: navigate to onboarding */},
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
    ), // Scaffold
    ); // _SwipeBackWrapper
  }

  // Help buttons now open full feature tutorials via TutorialNavigator.push().
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

    final selectedLabel = themeMode == AppThemeMode.system
        ? l10n.themeSystem
        : themeMode == AppThemeMode.light
            ? l10n.themeLight
            : l10n.themeDark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row — read as heading by TalkBack
          Semantics(
            header: true,
            label: '$label. $subtitle. Currently: $selectedLabel',
            excludeSemantics: true,
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Each option is its own button node in the selector
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

    final selectedLabel = language == AppLanguage.english
        ? l10n.languageEnglish
        : l10n.languageTagalog;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title heading — one node: name + subtitle + current value
          Semantics(
            header: true,
            label: '$label. $subtitle. Currently: $selectedLabel',
            excludeSemantics: true,
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Each option is its own button node
          MsSegmentedSelector<AppLanguage>(
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

// ── Swipe-back wrapper ────────────────────────────────────────────────────────

/// Wraps any pushed screen so a LEFT-swipe pops the route — Settings slides in
/// from the left, so the natural reverse gesture is a left swipe to push it back.
class _SwipeBackWrapper extends StatelessWidget {
  const _SwipeBackWrapper({required this.child});
  final Widget child;

  static const double _minVelocity = 300.0;
  static const double _maxCrossRatio = 0.55;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        final v = details.velocity.pixelsPerSecond;
        final ax = v.dx.abs();
        final ay = v.dy.abs();
        if (ax < _minVelocity) return;
        if (ax < ay) return; // more vertical than horizontal
        if (ay / ax > _maxCrossRatio) return; // too diagonal
        if (v.dx < 0) Navigator.of(context).maybePop(); // swipe LEFT = back
      },
      child: child,
    );
  }
}
