import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../widgets/ps_tutorial_scaffold.dart';

class GesturalNavigationTutorial extends StatefulWidget {
  const GesturalNavigationTutorial({super.key});

  @override
  State<GesturalNavigationTutorial> createState() =>
      _GesturalNavigationTutorialState();
}

class _GesturalNavigationTutorialState
    extends State<GesturalNavigationTutorial> {
  _GestureResult? _lastResult;

  void _onGesture(_GestureResult result) {
    HapticFeedback.lightImpact();
    setState(() => _lastResult = result);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _lastResult = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PsTutorialScaffold(
      title: 'Gestural Navigation',
      badge: 'Navigation',
      description:
          'Navigate PesoSense hands-free using swipes and taps on the '
          'scanner screen — perfect when your other hand is holding currency.',
      steps: const [
        'Enable "Gestural Navigation" in Settings → Navigation.',
        'Swipe RIGHT on the scanner screen to open Settings.',
        'Swipe LEFT on the scanner screen to open Tutorial.',
        'Swipe UP on the scanner to toggle the flashlight on or off.',
      ],
      hero: _GestureHero(isDark: isDark, lastResult: _lastResult),
      interactive: _GesturePlayground(
        isDark: isDark,
        lastResult: _lastResult,
        onGesture: _onGesture,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result type
// ---------------------------------------------------------------------------

enum _GestureResult { swipeRight, swipeLeft, swipeUp }

extension _GestureResultLabel on _GestureResult {
  String get label {
    switch (this) {
      case _GestureResult.swipeRight:
        return '→ Opens Settings';
      case _GestureResult.swipeLeft:
        return '← Opens Tutorial';
      case _GestureResult.swipeUp:
        return '↑ Toggles Flashlight';
    }
  }

  Color get color {
    switch (this) {
      case _GestureResult.swipeRight:
        return AppColors.accentYellow;
      case _GestureResult.swipeLeft:
        return AppColors.accentBlue;
      case _GestureResult.swipeUp:
        return const Color(0xFF4CAF50);
    }
  }

  IconData get icon {
    switch (this) {
      case _GestureResult.swipeRight:
        return Icons.settings_rounded;
      case _GestureResult.swipeLeft:
        return Icons.help_outline_rounded;
      case _GestureResult.swipeUp:
        return Icons.flashlight_on_rounded;
    }
  }
}

// ---------------------------------------------------------------------------
// Hero — animated phone showing the four gestures cycling
// ---------------------------------------------------------------------------

class _GestureHero extends StatefulWidget {
  const _GestureHero({required this.isDark, required this.lastResult});
  final bool isDark;
  final _GestureResult? lastResult;

  @override
  State<_GestureHero> createState() => _GestureHeroState();
}

class _GestureHeroState extends State<_GestureHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _step = 0;

  static const _steps = [
    _GestureResult.swipeRight,
    _GestureResult.swipeLeft,
    _GestureResult.swipeUp,
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _advance();
  }

  void _advance() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) break;
      await _ctrl.forward();
      if (!mounted) break;
      setState(() => _step = (_step + 1) % _steps.length);
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final result = widget.lastResult ?? _steps[_step];

    return Container(
      color: bg,
      child: Center(
        child: _PhoneWithGesture(
          isDark: widget.isDark,
          result: result,
          animController: _ctrl,
        ),
      ),
    );
  }
}

class _PhoneWithGesture extends StatelessWidget {
  const _PhoneWithGesture({
    required this.isDark,
    required this.result,
    required this.animController,
  });
  final bool isDark;
  final _GestureResult result;
  final AnimationController animController;

  @override
  Widget build(BuildContext context) {
    final phoneColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    // Arrow animation: slides in the direction of the gesture
    final offset = Tween<Offset>(
      begin: Offset.zero,
      end: _arrowEndOffset(result),
    ).animate(CurvedAnimation(parent: animController, curve: Curves.easeOut));

    return Stack(
      alignment: Alignment.center,
      children: [
        // Phone body
        Container(
          width: 100,
          height: 170,
          decoration: BoxDecoration(
            color: phoneColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  result.icon,
                  key: ValueKey(result),
                  color: result.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _screenLabel(result),
                  key: ValueKey(result),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: result.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Animated gesture arrow
        AnimatedBuilder(
          animation: animController,
          builder: (_, __) => Transform.translate(
            offset: Offset(offset.value.dx * 60, offset.value.dy * 60),
            child: Opacity(
              opacity: (1.0 - animController.value).clamp(0.0, 1.0),
              child: _GestureArrow(result: result),
            ),
          ),
        ),
      ],
    );
  }

  String _screenLabel(_GestureResult r) {
    switch (r) {
      case _GestureResult.swipeRight:
        return 'Settings';
      case _GestureResult.swipeLeft:
        return 'Tutorial';
      case _GestureResult.swipeUp:
        return 'Flash';
    }
  }

  Offset _arrowEndOffset(_GestureResult r) {
    switch (r) {
      case _GestureResult.swipeRight:
        return const Offset(0.8, 0);
      case _GestureResult.swipeLeft:
        return const Offset(-0.8, 0);
      case _GestureResult.swipeUp:
        return const Offset(0, -0.8);
    }
  }
}

class _GestureArrow extends StatelessWidget {
  const _GestureArrow({required this.result});
  final _GestureResult result;

  @override
  Widget build(BuildContext context) {
    final iconData = switch (result) {
      _GestureResult.swipeRight => Icons.arrow_forward_rounded,
      _GestureResult.swipeLeft => Icons.arrow_back_rounded,
      _GestureResult.swipeUp => Icons.arrow_upward_rounded,
    };

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: result.color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: result.color.withOpacity(0.6)),
      ),
      child: Icon(iconData, color: result.color, size: 20),
    );
  }
}

// ---------------------------------------------------------------------------
// Interactive playground — detect actual swipes
// ---------------------------------------------------------------------------

class _GesturePlayground extends StatelessWidget {
  const _GesturePlayground({
    required this.isDark,
    required this.lastResult,
    required this.onGesture,
  });

  final bool isDark;
  final _GestureResult? lastResult;
  final void Function(_GestureResult) onGesture;

  static const double _minVelocity = 200.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final onSurface = isDark
        ? AppColors.darkOnSurface
        : AppColors.lightOnSurface;
    final onVariant = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final active = lastResult != null;
    final accent = lastResult?.color ?? AppColors.accentYellow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Swipe pad
        GestureDetector(
          onPanEnd: (d) {
            final v = d.velocity.pixelsPerSecond;
            final ax = v.dx.abs();
            final ay = v.dy.abs();
            if (ax < _minVelocity && ay < _minVelocity) return;
            if (ax >= ay) {
              onGesture(
                v.dx > 0 ? _GestureResult.swipeRight : _GestureResult.swipeLeft,
              );
            } else if (v.dy < 0) {
              onGesture(_GestureResult.swipeUp);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 140,
            decoration: BoxDecoration(
              color: active
                  ? accent.withOpacity(isDark ? 0.12 : 0.07)
                  : surface,
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
              border: Border.all(
                color: active ? accent : border,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: active
                      ? Icon(
                          lastResult!.icon,
                          key: ValueKey(lastResult),
                          color: accent,
                          size: 32,
                        )
                      : Icon(
                          Icons.swipe_rounded,
                          key: const ValueKey('idle'),
                          color: onVariant,
                          size: 32,
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    active ? lastResult!.label : 'Swipe here to try',
                    key: ValueKey(lastResult),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: active ? accent : onVariant,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Legend
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              _LegendRow(
                icon: Icons.arrow_forward_rounded,
                color: AppColors.accentYellow,
                label: 'Swipe right',
                action: 'Opens Settings',
                theme: theme,
                onSurface: onSurface,
                onVariant: onVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              _LegendRow(
                icon: Icons.arrow_back_rounded,
                color: AppColors.accentBlue,
                label: 'Swipe left',
                action: 'Opens Tutorial',
                theme: theme,
                onSurface: onSurface,
                onVariant: onVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              _LegendRow(
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xFF4CAF50),
                label: 'Swipe up',
                action: 'Toggles flashlight',
                theme: theme,
                onSurface: onSurface,
                onVariant: onVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.action,
    required this.theme,
    required this.onSurface,
    required this.onVariant,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String action;
  final ThemeData theme;
  final Color onSurface;
  final Color onVariant;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label — $action',
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            action,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
