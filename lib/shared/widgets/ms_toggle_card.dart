import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

/// A square, high-visibility toggle card for the Simple Settings screen.
///
/// Tapping the card triggers [onTap]. The background and foreground colors
/// change based on the [isActive] state.
class MsToggleCard extends StatelessWidget {
  const MsToggleCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest; // Use surfaceContainerHighest for better contrast in modern theme
    final textColor = isActive
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Semantics(
      label: '$label. Button',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(
            minHeight: 160,
            maxHeight: 160,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            boxShadow: [
              if (!isActive)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: textColor),
                const SizedBox(height: 12),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.visible,
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
