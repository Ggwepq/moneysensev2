import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A pill-style segmented selector matching the PesoSense design.
///
/// Font overflow fix: the label inside each pill uses [TextScaler.noScaling]
/// so it is immune to the user's font-size preference.  The pill has a fixed
/// height that can accommodate any of the app's short option strings.
/// Long strings are ellipsized rather than overflowing.
///
/// A11y: each pill is one Semantics node — label + selected state.
class PsSegmentedSelector<T> extends StatelessWidget {
  const PsSegmentedSelector({
    super.key,
    required this.options,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.leadingIcons,
  }) : assert(options.length == labels.length),
       assert(leadingIcons == null || leadingIcons.length == options.length);

  final List<T> options;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onSelected;
  final List<IconData?>? leadingIcons;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Yellow is the primary accent on both themes — active pill is always yellow.
    const activeColor = AppColors.accentYellow;
    // Yellow is dark enough to need a dark label in both themes.
    final activeText = isDark
        ? AppColors.darkBackground
        : AppColors.lightOnSurface;
    final inactiveColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;
    final inactiveText = isDark
        ? AppColors.darkOnSurface
        : AppColors.lightOnSurface;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: inactiveColor,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(options.length, (i) {
            final isSelected = options[i] == selected;
            final icon = leadingIcons?[i];

            return Expanded(
              child: Semantics(
                selected: isSelected,
                label: isSelected ? '${labels[i]}, selected' : labels[i],
                button: true,
                // Prevent icon + text from becoming separate nodes
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelected(options[i]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                      horizontal: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? activeColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.buttonRadius - 3,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 14,
                            color: isSelected ? activeText : inactiveText,
                          ),
                          const SizedBox(width: 3),
                        ],
                        Flexible(
                          child: MediaQuery.withNoTextScaling(
                            // Pill labels are fixed-size UI chrome — they
                            // should not scale with the accessibility font
                            // preference.  The setting name in the tile
                            // above already scales.
                            child: Text(
                              labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected ? activeText : inactiveText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
