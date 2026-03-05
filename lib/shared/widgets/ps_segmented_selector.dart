import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A pill-style segmented selector that closely matches the design.
///
/// The selected segment is filled with [AppColors.accentYellow] (dark mode)
/// or [AppColors.accentBlue] (light mode).
class PsSegmentedSelector<T> extends StatelessWidget {
  const PsSegmentedSelector({
    super.key,
    required this.options,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.leadingIcons,
  })  : assert(options.length == labels.length),
        assert(leadingIcons == null || leadingIcons.length == options.length);

  final List<T> options;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onSelected;

  /// Optional icon per option (shown before the label).
  final List<IconData?>? leadingIcons;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor =
        isDark ? AppColors.accentYellow : AppColors.accentBlue;
    final activeTextColor =
        isDark ? AppColors.darkBackground : Colors.white;
    final inactiveColor =
        isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final inactiveTextColor =
        isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: inactiveColor,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final isSelected = options[i] == selected;
          return Expanded(
            child: Semantics(
              selected: isSelected,
              label: labels[i],
              button: true,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(options[i]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + 2,
                    horizontal: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius - 3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (leadingIcons != null &&
                          leadingIcons![i] != null) ...[
                        Icon(
                          leadingIcons![i],
                          size: 16,
                          color: isSelected
                              ? activeTextColor
                              : inactiveTextColor,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? activeTextColor
                              : inactiveTextColor,
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
    );
  }
}
