import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A settings tile with a [Slider] and ± step buttons.
///
/// TalkBack / accessibility design:
///   Node 1 — title heading:
///     "Font Size. Setting subtitle. Currently: 100%"
///   Node 2 — decrement button:
///     "Decrease Font Size, button"
///   Node 3 — slider:
///     "Font Size: 100%, slider" (Android reads this natively)
///   Node 4 — increment button:
///     "Increase Font Size, button"
class PsSliderTile extends StatelessWidget {
  const PsSliderTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.displayLabel,
  });

  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String? displayLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pct = ((value - min) / (max - min) * 100).round();
    final label = displayLabel ?? '$pct%';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Node 1: heading ───────────────────────────────────────────
          Semantics(
            header: true,
            label: subtitle != null
                ? '$title. $subtitle. Currently: $label'
                : '$title. Currently: $label',
            excludeSemantics: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppColors.darkOnSurface
                              : AppColors.lightOnSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkOnSurfaceVariant
                                : AppColors.lightOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // ── Nodes 2 / 3 / 4 ──────────────────────────────────────────
          Row(
            children: [
              Semantics(
                label: 'Decrease $title',
                button: true,
                excludeSemantics: true,
                child: _StepButton(
                  icon: Icons.remove,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onChanged((value - (max - min) / 10).clamp(min, max));
                  },
                ),
              ),
              Expanded(
                child: Semantics(
                  label: '$title: $label',
                  slider: true,
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Semantics(
                label: 'Increase $title',
                button: true,
                excludeSemantics: true,
                child: _StepButton(
                  icon: Icons.add,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onChanged((value + (max - min) / 10).clamp(min, max));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Step button (always yellow) ────────────────────────────────────────────────

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Yellow is the primary accent on both themes.
    // #E2DA00 is dark enough that the near-black darkBackground icon reads well.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.accentYellow,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.darkBackground),
      ),
    );
  }
}
