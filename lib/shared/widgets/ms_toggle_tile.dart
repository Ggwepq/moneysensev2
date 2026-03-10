import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_spacing.dart';
import '../../features/settings/domain/entities/vision_config.dart';

/// Settings tile: [Icon?]  [Title / Subtitle]  [Switch]  [? Help]
///
/// TalkBack tree: each bullet is one independent focusable node:
///   - Tile : "Shake to Go Back. Description. Switch, on"
///              double-tap → toggles switch
///   - Help : "Help for Shake to Go Back. Button"  (only if [showHelpButton])
///              double-tap → opens help dialog
///
/// Implementation notes:
///   [container: true] on each Semantics node creates a hard boundary that
///   prevents TalkBack from merging the tile and the help button into one
///   (which would make the help button invisible to linear navigation).
///   [excludeSemantics: true] suppresses descendant nodes (Switch text,
///   Icon descriptions) so they don't duplicate content.
class MsToggleTile extends StatelessWidget {
  const MsToggleTile({
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

    final base = semanticLabel ?? title;
    final sub = subtitle != null ? '. $subtitle' : '';
    final state = value ? 'on' : 'off';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Node 1: tile + switch ─────────────────────────────────
          Expanded(
            child: Semantics(
              label: '$base$sub. Switch, $state',
              toggled: value,
              container: true,       // hard boundary: no merging with neighbour
              excludeSemantics: true, // hide Switch / Text descendants
              onTap: onChanged == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onChanged!(!value);
                    },
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall,
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
          // ── Node 2: help button (distinct focusable node) ─────────
          if (showHelpButton) ...[
            const SizedBox(width: AppSpacing.sm),
            _HelpButton(settingName: title, onTap: onHelpTap),
          ],
        ],
      ),
    );
  }
}


class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.settingName, this.onTap});
  final String settingName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cfg     = ProviderScope.containerOf(context, listen: false)
        .read(visionConfigProvider);
    final accent  = cfg.accentBlue; // help button always uses blue

    return Semantics(
      label: 'Help for $settingName',
      button: true,
      container: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '?',
              style: TextStyle(
                color: accent.computeLuminance() > 0.4 ? Colors.black : Colors.white,
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
