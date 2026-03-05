import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A settings tile with a label, optional subtitle, a [Switch] and an
/// optional circular help/info button.
///
/// Matches the custom dark-card rows seen in the PesoSense design:
///   [Icon?] Title              [Switch] [?]
///            Subtitle
///
/// The tile itself has no explicit background — it is placed inside a
/// [PsSettingsCard] which provides the rounded dark surface.
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

    return Semantics(
      label: semanticLabel ?? title,
      toggled: value,
      child: InkWell(
        onTap: onChanged == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onChanged!(!value);
              },
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.md),
              ],
              // Title + Subtitle
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
              // Switch
              Switch(
                value: value,
                onChanged: onChanged,
              ),
              // Optional help button
              if (showHelpButton) ...[
                const SizedBox(width: AppSpacing.sm),
                _HelpButton(onTap: onHelpTap),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Help Button ─────────────────────────────────────────────────────────────

class _HelpButton extends StatelessWidget {
  const _HelpButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Help',
      button: true,
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
