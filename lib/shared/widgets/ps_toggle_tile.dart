import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A settings tile: [Title / Subtitle]  [Switch]  [Help?]
///
/// TalkBack / accessibility design:
///   • The entire title+subtitle+switch area is ONE focusable node.
///     TalkBack announces: "Use Front Camera. Setting subtitle. Switch, off"
///     Double-tapping the node toggles the switch.
///   • The Switch widget inside is hidden from the a11y tree (ExcludeSemantics)
///     to prevent a duplicate "switch, off" node right after the tile node.
///   • The help button (if shown) is a separate node immediately after:
///     "Help for Use Front Camera, button"
class PsToggleTile extends StatelessWidget {
  const PsToggleTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.leading,
    this.showHelpButton = false,
    this.onHelpTap,
    this.semanticLabel,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;
  final bool showHelpButton;
  final VoidCallback? onHelpTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build exactly what TalkBack will read for this one node.
    final baseLabel = semanticLabel ?? title;
    final sub = subtitle != null ? '. $subtitle' : '';
    final state = value ? 'on' : 'off';
    final a11yLabel = '$baseLabel$sub. Switch, $state';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Tile (one node) ───────────────────────────────────────────
          Expanded(
            child: Semantics(
              label: a11yLabel,
              toggled: value,
              // Provide the tap action so TalkBack "double-tap to toggle"
              // activates the correct callback.
              onTap: onChanged == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onChanged!(!value);
                    },
              // Suppress ALL descendant nodes — the Switch and Text widgets
              // must not create their own a11y nodes inside this tile.
              excludeSemantics: true,
              child: InkWell(
                onTap: onChanged == null
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onChanged!(!value);
                      },
                borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: AppSpacing.md),
                    ],
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
                    const SizedBox(width: AppSpacing.sm),
                    Switch(value: value, onChanged: onChanged),
                  ],
                ),
              ),
            ),
          ),
          // ── Help button (separate node) ───────────────────────────────
          if (showHelpButton) ...[
            const SizedBox(width: AppSpacing.sm),
            _HelpButton(settingName: title, onTap: onHelpTap),
          ],
        ],
      ),
    );
  }
}

// ── Help Button ────────────────────────────────────────────────────────────────

class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.settingName, this.onTap});
  final String settingName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Help for $settingName',
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
