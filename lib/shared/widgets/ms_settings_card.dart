import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Rounded card grouping related settings tiles.
///
/// Does NOT add extra Semantics wrappers — each child widget manages its own
/// a11y tree.  This lets [MsToggleTile] expose its tile node and its help-
/// button node as two *separate* focusable items, rather than being collapsed
/// into one container.
///
/// Dividers are hidden from the a11y tree.
class MsSettingsCard extends StatelessWidget {
  const MsSettingsCard({super.key, required this.children});
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
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _withDividers(children, isDark),
        ),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> items, bool isDark) {
    if (items.isEmpty) return [];
    final out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      out.add(items[i]); // no extra Semantics wrapper
      if (i < items.length - 1) {
        out.add(ExcludeSemantics(
          child: Divider(
            height: 1,
            thickness: 1,
            indent: AppSpacing.base,
            endIndent: AppSpacing.base,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ));
      }
    }
    return out;
  }
}
