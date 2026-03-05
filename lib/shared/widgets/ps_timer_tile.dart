import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A settings tile that shows a toggle plus a numeric counter badge.
/// Used for "Go Back Timer on Result".
class PsTimerTile extends StatelessWidget {
  const PsTimerTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.enabled,
    required this.value,
    required this.onToggle,
    required this.onValueChanged,
    this.min = 0,
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

    return Semantics(
      label: '$title: $value seconds',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
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
            Switch(
              value: enabled,
              onChanged: (v) {
                HapticFeedback.lightImpact();
                onToggle(v);
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            // Counter badge — tapping opens a dialog to change the value
            GestureDetector(
              onTap: () => _showTimerPicker(context),
              child: Container(
                width: 44,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.lightOnSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerPicker(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _TimerPickerDialog(
        current: value,
        min: min,
        max: max,
        onConfirm: onValueChanged,
      ),
    );
  }
}

// ── Timer Picker Dialog ──────────────────────────────────────────────────────

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
    _value = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Go Back Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$_value seconds'),
          Slider(
            value: _value.toDouble(),
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            divisions: widget.max - widget.min,
            onChanged: (v) => setState(() => _value = v.round()),
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
