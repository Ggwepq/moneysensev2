import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A settings tile: [Title / Subtitle]  [Switch]  [Counter badge]
///
/// TalkBack / accessibility design:
///   Node 1 — the tile (label + switch):
///     "Go Back Timer on Result. 20 seconds. Switch, on"
///     Double-tap → toggles the switch
///   Node 2 — the counter badge (only when enabled):
///     "Timer value: 20 seconds. Tap to change. Button"
///     Double-tap → opens the picker dialog
///
/// Node order in the a11y tree matches reading order (LTR):
///   tile node → badge node
///
/// When disabled, the badge node is still present but marked
/// [enabled: false] so TalkBack announces "dimmed" and skips it
/// in linear navigation on most Android versions.
class MsTimerTile extends StatelessWidget {
  const MsTimerTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.enabled,
    required this.value,
    required this.onToggle,
    required this.onValueChanged,
    this.min = 5,
    this.max = 60,
  });

  final String title;
  final String? subtitle;
  final bool enabled;
  final int value;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onValueChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dimmedTitle = (isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface)
        .withOpacity(enabled ? 1.0 : 0.4);
    final dimmedSub =
        (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant)
            .withOpacity(enabled ? 1.0 : 0.4);

    // Node 1 label
    final sub = subtitle != null ? '. $subtitle' : '';
    final valueText = enabled ? '. $value seconds' : '';
    final state = enabled ? 'on' : 'off';
    final tileLabel = '$title$sub$valueText. Switch, $state';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // ── Node 1: tile + switch ─────────────────────────────────────
          Expanded(
            child: Semantics(
              label: tileLabel,
              toggled: enabled,
              container: true,
              excludeSemantics: true,
              onTap: () {
                HapticFeedback.lightImpact();
                onToggle(!enabled);
              },
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggle(!enabled);
                },
                borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  color: dimmedTitle,
                                  fontWeight: FontWeight.w500)),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(subtitle!,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: dimmedSub)),
                          ],
                        ],
                      ),
                    ),
                    Switch(
                      value: enabled,
                      onChanged: (v) {
                        HapticFeedback.lightImpact();
                        onToggle(v);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // ── Node 2: counter badge ────────────────────────────────────
          Semantics(
            label: enabled
                ? 'Timer value: $value seconds. Tap to change.'
                : 'Timer disabled',
            button: enabled,
            enabled: enabled,
            container: true,
            // excludeSemantics keeps the badge text from leaking into
            // the surrounding tree.
            excludeSemantics: true,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: enabled ? 1.0 : 0.35,
              child: GestureDetector(
                onTap: enabled ? () => _showPicker(context) : null,
                child: Container(
                  width: 48,
                  height: 38,
                  decoration: BoxDecoration(
                    color: enabled
                        ? (isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant)
                        : (isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                    borderRadius: BorderRadius.circular(8),
                    border: enabled
                        ? Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$value',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: enabled
                            ? (isDark
                                ? AppColors.darkOnSurface
                                : AppColors.lightOnSurface)
                            : (isDark
                                ? AppColors.darkOnSurfaceVariant
                                : AppColors.lightOnSurfaceVariant),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _TimerPickerDialog(
          current: value, min: min, max: max, onConfirm: onValueChanged),
    );
  }
}

// ── Timer picker ───────────────────────────────────────────────────────────────

class _TimerPickerDialog extends StatefulWidget {
  const _TimerPickerDialog({
    required this.current,
    required this.min,
    required this.max,
    required this.onConfirm,
  });
  final int current;
  final int min;
  final int max;
  final ValueChanged<int> onConfirm;

  @override
  State<_TimerPickerDialog> createState() => _TimerPickerDialogState();
}

class _TimerPickerDialogState extends State<_TimerPickerDialog> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.current.clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Go Back Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$_value seconds',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Semantics(
            label: 'Timer duration $_value seconds',
            slider: true,
            child: Slider(
              value: _value.toDouble(),
              min: widget.min.toDouble(),
              max: widget.max.toDouble(),
              divisions: widget.max - widget.min,
              label: '$_value s',
              onChanged: (v) => setState(() => _value = v.round()),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onConfirm(_value);
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
