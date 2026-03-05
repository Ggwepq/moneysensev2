import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A rounded card that groups related settings tiles.
///
/// Each child is placed inside a [Semantics] node with [container]=true.
/// This creates a hard boundary in the a11y tree so TalkBack cannot merge
/// content from one tile into the next — each tile is exactly one swipe away.
///
/// Dividers are hidden from the a11y tree ([ExcludeSemantics]) because they
/// carry no meaningful information.
class PsSettingsCard extends StatelessWidget {
  const PsSettingsCard({super.key, required this.children});
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
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildWithDividers(children, isDark),
        ),
      ),
    );
  }

  List<Widget> _buildWithDividers(List<Widget> items, bool isDark) {
    if (items.isEmpty) return [];
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(
        // container=true creates a boundary: TalkBack stops merging here.
        Semantics(container: true, child: items[i]),
      );
      if (i < items.length - 1) {
        result.add(
          ExcludeSemantics(
            child: Divider(
              height: 1,
              thickness: 1,
              indent: AppSpacing.base,
              endIndent: AppSpacing.base,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
        );
      }
    }
    return result;
  }
}
