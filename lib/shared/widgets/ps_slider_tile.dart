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
          // ── Node 1: heading with current value ──────────────────────
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
          // ── Nodes 2 / 3 / 4: ─ slider + ─────────────────────────────
          Row(
            children: [
              // Node 2: decrement
              Semantics(
                label: 'Decrease $title',
                button: true,
                excludeSemantics: true,
                child: _RoundButton(
                  icon: Icons.remove,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onChanged((value - (max - min) / 10).clamp(min, max));
                  },
                ),
              ),
              // Node 3: slider (Flutter exposes this natively as a slider node)
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
              // Node 4: increment
              Semantics(
                label: 'Increase $title',
                button: true,
                excludeSemantics: true,
                child: _RoundButton(
                  icon: Icons.add,
                  isDark: isDark,
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

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColors.accentYellow : AppColors.accentBlue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkBackground : Colors.white,
        ),
      ),
    );
  }
}
