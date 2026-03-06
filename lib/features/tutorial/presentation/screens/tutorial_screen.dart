import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/tutorial_route.dart';
import 'tutorial_navigator.dart';

/// Main Tutorial screen — accessible from the bottom nav.
///
/// Shows a card for each available feature tutorial.
/// Tapping a card pushes the full interactive tutorial.
///
/// Swipe LEFT to go back (mirrors the gesture that opened this screen).
class TutorialScreen extends ConsumerWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final l10n = AppLocalizations.of(settings.isTagalog);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onVariant = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return _SwipeBackWrapper(
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          title: Text(l10n.navTutorial),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.base,
          ),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                  bottom: AppSpacing.xl, top: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tutorialScreenTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.tutorialScreenSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scanning section ─────────────────────────────────────────
            _SectionLabel(label: l10n.tutorialSectionScanning, isDark: isDark),
            const SizedBox(height: AppSpacing.sm),
            _TutorialCard(
              route: TutorialRoute.denominationVibration,
              icon: Icons.vibration_rounded,
              title: l10n.tutorialCardDenomTitle,
              description: l10n.tutorialCardDenomDesc,
              accentColor: AppColors.accentYellow,
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Navigation section ───────────────────────────────────────
            _SectionLabel(label: l10n.tutorialSectionNavigation, isDark: isDark),
            const SizedBox(height: AppSpacing.sm),
            _TutorialCard(
              route: TutorialRoute.shakeToGoBack,
              icon: Icons.screen_rotation_rounded,
              title: l10n.tutorialCardShakeTitle,
              description: l10n.tutorialCardShakeDesc,
              accentColor: AppColors.accentBlue,
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.md),
            _TutorialCard(
              route: TutorialRoute.gesturalNavigation,
              icon: Icons.swipe_rounded,
              title: l10n.tutorialCardGestureTitle,
              description: l10n.tutorialCardGestureDesc,
              accentColor: AppColors.accentYellow,
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark
              ? AppColors.darkOnSurfaceVariant
              : AppColors.lightOnSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Tutorial card ─────────────────────────────────────────────────────────────

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({
    required this.route,
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.isDark,
  });

  final TutorialRoute route;
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onVariant = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return Semantics(
      label: '$title. $description. Button',
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          TutorialNavigator.push(context, route);
        },
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(color: border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent panel — stretches to match card height
                Container(
                  width: 72,
                  decoration: BoxDecoration(
                    // Light: solid accent fill so the icon (white/dark) reads cleanly.
                    // Dark: subtle tint so the accent icon reads against the dark bg.
                    color: isDark
                        ? accentColor.withOpacity(0.14)
                        : accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.tileRadius),
                      bottomLeft: Radius.circular(AppSpacing.tileRadius),
                    ),
                    border: Border(
                      right: BorderSide(color: border),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      // Light: white on solid accent = always readable.
                      // Dark: accent on tinted bg = readable.
                      color: isDark ? accentColor : AppColors.darkBackground,
                      size: 28,
                    ),
                  ),
                ),
                // Text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Chevron
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Center(
                    child: Icon(Icons.chevron_right_rounded,
                        color: onVariant, size: 22),
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

// ── Swipe-back wrapper ────────────────────────────────────────────────────────

/// Swipe LEFT to pop — mirrors the left-swipe gesture that opened this screen.
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
        if (ax < ay) return;
        if (ay / ax > _maxCrossRatio) return;
        if (v.dx > 0) Navigator.of(context).maybePop(); // swipe right = back
      },
      child: child,
    );
  }
}
