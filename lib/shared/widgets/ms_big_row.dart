import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

/// A standard row used in the Simple Settings grid.
///
/// Ensures consistent spacing between two side-by-side [MsToggleCard] widgets.
class MsBigRow extends StatelessWidget {
  const MsBigRow({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: children.length > 1 ? children[1] : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
