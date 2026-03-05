import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A rounded card surface that groups related settings tiles.
///
/// Matching the design: dark rounded rectangle with subtle border.
class PsSettingsCard extends StatelessWidget {
  const PsSettingsCard({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        child: Column(
          children: _buildWithDividers(children, isDark),
        ),
      ),
    );
  }

  List<Widget> _buildWithDividers(List<Widget> items, bool isDark) {
    if (items.isEmpty) return [];
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(Divider(
          height: 1,
          thickness: 1,
          indent: AppSpacing.base,
          endIndent: AppSpacing.base,
          color:
              isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ));
      }
    }
    return result;
  }
}
