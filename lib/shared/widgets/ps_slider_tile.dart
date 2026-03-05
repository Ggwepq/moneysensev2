import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A settings tile containing a [Slider] with minus/plus buttons.
///
/// Matches the "Font Size" row in the design with ─ slider + buttons.
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

  /// Override the label shown in the center (e.g. "100%"). If null, shows
  /// the raw percentage.
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
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkOnSurfaceVariant
                      : AppColors.lightOnSurfaceVariant,
                ),
              ),
            ],
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
          const SizedBox(height: AppSpacing.sm),
          // Slider row with – and + buttons
          Row(
            children: [
              _RoundButton(
                icon: Icons.remove,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChanged((value - (max - min) / 10).clamp(min, max));
                },
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
              _RoundButton(
                icon: Icons.add,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChanged((value + (max - min) / 10).clamp(min, max));
                },
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
    final accentColor = isDark ? AppColors.accentYellow : AppColors.accentBlue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: accentColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkBackground : Colors.white,
        ),
      ),
    );
  }
}
