import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/shake_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/domain/entities/vision_config.dart';
import '../widgets/ms_tutorial_scaffold.dart';

class ShakeTutorial extends ConsumerStatefulWidget {
  const ShakeTutorial({super.key});

  @override
  ConsumerState<ShakeTutorial> createState() => _ShakeTutorialState();
}

class _ShakeTutorialState extends ConsumerState<ShakeTutorial> {
  int _shakeCount = 0;
  bool _justShook  = false; // brief highlight flag

  @override
  void initState() {
    super.initState();
    // Start a local shake listener just for this tutorial's demo zone.
    // We use the shared ShakeService but swap the callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shakeServiceProvider).start(_onShake);
    });
  }

  @override
  void dispose() {
    // Don't stop the service — ShakeDetectorWidget manages start/stop based
    // on the user's setting.  But we do need to remove our tutorial callback
    // by calling start() again with the detector widget's handler.
    // Since we can't easily get that reference here, we just stop and the
    // ShakeDetectorWidget's build() will restart it on the next frame.
    ref.read(shakeServiceProvider).stop();
    super.dispose();
  }

  void _onShake() {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _shakeCount++;
      _justShook = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _justShook = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg    = ref.watch(visionConfigProvider);
    final blue    = cfg.accentBlue;
    final l10n = AppLocalizations.of(ref.watch(appSettingsProvider).isTagalog);

    return MsTutorialScaffold(
      title: l10n.tutorialCardShakeTitle,
      badge: l10n.shakeTutorialBadge,
      description: l10n.shakeTutorialDescription,
      steps: [
        l10n.shakeTutorialStep1,
        l10n.shakeTutorialStep2,
        l10n.shakeTutorialStep3,
        l10n.shakeTutorialStep4,
      ],
      hero: _ShakeHero(isDark: isDark, justShook: _justShook),
      accentColor: blue,
      interactive: _ShakeDemo(
        shakeCount: _shakeCount,
        justShook: _justShook,
        isDark: isDark,
        l10n: l10n,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class _ShakeHero extends StatefulWidget {
  const _ShakeHero({required this.isDark, required this.justShook});
  final bool isDark;
  final bool justShook;

  @override
  State<_ShakeHero> createState() => _ShakeHeroState();
}

class _ShakeHeroState extends State<_ShakeHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idle;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _float = Tween(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _idle, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final shakeOffset = widget.justShook
        ? (math.sin(DateTime.now().millisecondsSinceEpoch / 30) * 10)
        : 0.0;

    return Container(
      color: bg,
      child: Center(
        child: AnimatedBuilder(
          animation: _float,
          builder: (_, __) => Transform.translate(
            offset: Offset(shakeOffset, _float.value),
            child: _PhoneGraphic(
              isDark: widget.isDark,
              glowing: widget.justShook,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneGraphic extends StatelessWidget {
  const _PhoneGraphic({required this.isDark, required this.glowing});
  final bool isDark;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    final _cfg   = ProviderScope.containerOf(context, listen: false)
        .read(visionConfigProvider);
    final blue    = _cfg.accentBlue;
    final phoneColor = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final border     = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accent     = glowing ? blue : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow
        if (glowing)
          Container(
            width: 120,
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: blue.withValues(alpha: 0.45),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        // Phone body
        Container(
          width: 80,
          height: 140,
          decoration: BoxDecoration(
            color: phoneColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: glowing ? blue : border,
              width: glowing ? 2 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                glowing ? Icons.check_circle_rounded : Icons.vibration_rounded,
                color: accent,
                size: 32,
              ),
              const SizedBox(height: 6),
              Text(
                glowing ? '← Back' : 'Shake',
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Motion lines
        if (!glowing) ...[
          Positioned(
            left: -18, top: 44,
            child: _MotionLine(isDark: isDark),
          ),
          Positioned(
            right: -18, top: 44,
            child: _MotionLine(isDark: isDark, flip: true),
          ),
          Positioned(
            left: -14, top: 70,
            child: _MotionLine(isDark: isDark, short: true),
          ),
          Positioned(
            right: -14, top: 70,
            child: _MotionLine(isDark: isDark, flip: true, short: true),
          ),
        ],
      ],
    );
  }
}

class _MotionLine extends StatelessWidget {
  const _MotionLine({
    required this.isDark,
    this.flip = false,
    this.short = false,
  });
  final bool isDark;
  final bool flip;
  final bool short;

  @override
  Widget build(BuildContext context) {
    final color = (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant)
        .withValues(alpha: 0.35);
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: Container(
        width: short ? 10 : 14,
        height: 2,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interactive demo zone
// ---------------------------------------------------------------------------

class _ShakeDemo extends StatelessWidget {
  const _ShakeDemo({
    required this.shakeCount,
    required this.justShook,
    required this.isDark,
    required this.l10n,
  });

  final int shakeCount;
  final bool justShook;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final _cfg   = ProviderScope.containerOf(context, listen: false)
        .read(visionConfigProvider);
    final blue    = _cfg.accentBlue;
    final theme = Theme.of(context);
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder   : AppColors.lightBorder;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onVariant = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: justShook
            ? blue.withValues(alpha: isDark ? 0.15 : 0.08)
            : surface,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        border: Border.all(
          color: justShook ? blue : border,
          width: justShook ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            justShook ? l10n.shakeDetected : l10n.shakeTryItTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: justShook ? blue : onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.shakeTryItHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: onVariant),
          ),
          if (shakeCount > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.shakeCount(shakeCount),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
