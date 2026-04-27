import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../settings/domain/entities/vision_config.dart';
import '../../../../core/services/earcon_service.dart';
import '../../../../core/services/tts_service.dart';

/// Shared scaffold for all feature tutorials.
///
/// Layout:
///   ┌───────────────────────────────────┐
///   │  AppBar (title + close)           │
///   ├───────────────────────────────────┤
///   │  Hero zone  (animated illustration│
///   │             fixed height 260)     │
///   ├───────────────────────────────────┤
///   │  Scrollable content               │
///   │    • Chip badge (e.g. "Feature")  │
///   │    • Title                        │
///   │    • Description                  │
///   │    • Steps (numbered yellow dots) │
///   │    • [Interactive zone]           │
///   └───────────────────────────────────┘
///
/// Adding a new tutorial: create a widget that extends nothing: just provide
/// [hero], [badge], [title], [description], [steps], and [interactive].
class MsTutorialScaffold extends ConsumerStatefulWidget {
  const MsTutorialScaffold({
    super.key,
    required this.title,
    required this.badge,
    required this.description,
    required this.steps,
    required this.hero,
    this.interactive,
    this.accentColor,
    this.heroSemantic,
    this.interactiveSemantic,
  });

  /// AppBar title AND content heading.
  final String title;

  /// Small chip label above the title: e.g. "Navigation", "Scanning".
  final String badge;

  /// One-paragraph explanation shown below the title.
  final String description;

  /// 2–4 numbered steps.  Keep each to one sentence.
  final List<String> steps;

  /// The animated illustration rendered in the hero zone (260 px tall).
  final Widget hero;

  /// Optional interactive widget rendered below the steps.
  final Widget? interactive;

  /// Semantic label for the hero zone — read by TalkBack instead of
  /// whatever text fragments the animated widgets contain.
  final String? heroSemantic;

  /// Semantic label for the interactive zone.
  final String? interactiveSemantic;

  /// Colour used for the badge chip, step numbers, and interactive accents.
  /// When null, resolved from [visionConfigProvider] at build time.
  final Color? accentColor;

  @override
  ConsumerState<MsTutorialScaffold> createState() => _MsTutorialScaffoldState();
}

class _MsTutorialScaffoldState extends ConsumerState<MsTutorialScaffold> {
  @override
  void dispose() {
    if (mounted) {
      try {
        ref.read(ttsServiceProvider).stop();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cfg    = ref.read(visionConfigProvider);
    final accent = widget.accentColor ?? cfg.accent(isDark);
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            EarconService.instance.play(EarconEvent.navBack);
            Navigator.of(context).maybePop();
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Text(
          widget.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero zone ────────────────────────────────────────────────
            SizedBox(
              height: 260,
              child: widget.heroSemantic != null
                  ? Semantics(
                      label: widget.heroSemantic,
                      excludeSemantics: true,
                      child: widget.hero,
                    )
                  : widget.hero,
            ),

            // ── Content zone ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.xl,
                AppSpacing.pagePadding,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.badge.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Title
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Description
                  Text(
                    widget.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onSurfaceVariant,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Steps
                  ...List.generate(widget.steps.length, (i) => _StepRow(
                    number: i + 1,
                    text: widget.steps[i],
                    accentColor: accent,
                    surface: surface,
                    onSurface: onSurface,
                    theme: theme,
                    isLast: i == widget.steps.length - 1,
                  )),

                  // Interactive zone
                  if (widget.interactive != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    widget.interactiveSemantic != null
                        ? Semantics(
                            label: widget.interactiveSemantic,
                            child: widget.interactive!,
                          )
                        : widget.interactive!,
                  ],

                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.text,
    required this.accentColor,
    required this.surface,
    required this.onSurface,
    required this.theme,
    required this.isLast,
  });

  final int number;
  final String text;
  final Color accentColor;
  final Color surface;
  final Color onSurface;
  final ThemeData theme;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number bubble
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: AppColors.darkBackground,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
