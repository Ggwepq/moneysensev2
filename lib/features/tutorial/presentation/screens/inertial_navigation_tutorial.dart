import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/inertial_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/domain/entities/vision_config.dart';
import '../widgets/ms_tutorial_scaffold.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class InertialNavigationTutorial extends ConsumerStatefulWidget {
  const InertialNavigationTutorial({super.key});

  @override
  ConsumerState<InertialNavigationTutorial> createState() =>
      _InertialNavigationTutorialState();
}

class _InertialNavigationTutorialState
    extends ConsumerState<InertialNavigationTutorial> {

  // Poll the service at 30 Hz so the live tilt bar is smooth
  Timer? _pollTimer;
  double _rawX  = 0;
  bool   _isFlat = false;
  bool   _justDetected = false;
  String? _lastLabel;

  @override
  void initState() {
    super.initState();

    // Start / ensure the service is running so the playground shows live data.
    // We temporarily override the callbacks to capture detections visually.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final svc = ref.read(inertialServiceProvider);
      // Stop whatever was running and restart with tutorial callbacks
      svc.stop();
      svc.start(
        onTiltLeft:  () => _onDetected('left'),
        onTiltRight: () => _onDetected('right'),
      );
    });

    _pollTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!mounted) return;
      final svc = ref.read(inertialServiceProvider);
      setState(() {
        _rawX   = svc.rawX;
        _isFlat = svc.isFlat;
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    // Stop and let InertialDetectorWidget restart on next frame
    ref.read(inertialServiceProvider).stop();
    super.dispose();
  }

  void _onDetected(String direction) {
    if (!mounted) return;
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(ref.read(appSettingsProvider).isTagalog);
    setState(() {
      _justDetected = true;
      _lastLabel = direction == 'right'
          ? l10n.inertialTiltRight
          : l10n.inertialTiltLeft;
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() { _justDetected = false; _lastLabel = null; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg    = ref.watch(visionConfigProvider);
    final blue    = cfg.accentBlue;
    final l10n   = AppLocalizations.of(
        ref.watch(appSettingsProvider).isTagalog);

    return MsTutorialScaffold(
      title: l10n.tutorialCardInertialTitle,
      badge: l10n.inertialTutorialBadge,
      accentColor: blue,
      description: l10n.inertialTutorialDescription,
      steps: [
        l10n.inertialTutorialStep1,
        l10n.inertialTutorialStep2,
        l10n.inertialTutorialStep3,
        l10n.inertialTutorialStep4,
        l10n.inertialTutorialStep5,
      ],
      hero: _TiltHero(
        isDark: isDark,
        rawX: _rawX,
        isFlat: _isFlat,
        justDetected: _justDetected,
      ),
      interactive: _TiltPlayground(
        isDark: isDark,
        rawX: _rawX,
        isFlat: _isFlat,
        justDetected: _justDetected,
        lastLabel: _lastLabel,
        l10n: l10n,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero — phone body that physically tilts matching the real accelerometer X
// ---------------------------------------------------------------------------

class _TiltHero extends StatelessWidget {
  const _TiltHero({
    required this.isDark,
    required this.rawX,
    required this.isFlat,
    required this.justDetected,
  });
  final bool   isDark;
  final double rawX;
  final bool   isFlat;
  final bool   justDetected;

  // Max raw X we map to full visual tilt (±9.8 = gravity fully sideways)
  static const double _maxRaw = 9.8;

  @override
  Widget build(BuildContext context) {
    final _cfg   = ProviderScope.containerOf(context, listen: false)
        .read(visionConfigProvider);
    final yellow  = _cfg.accentYellow;
    final blue    = _cfg.accentBlue;
    final bg    = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final phone = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;

    // Visual tilt angle: positive rawX = left tilt, negative = right tilt
    final tiltFraction = (rawX / _maxRaw).clamp(-1.0, 1.0);
    final tiltDeg      = tiltFraction * 40.0; // max ±40° visual
    final tiltRad      = tiltDeg * math.pi / 180.0;

    final accent     = justDetected ? yellow : blue;
    final glowOpacity = justDetected ? 0.40 : 0.20;

    return Container(
      color: bg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Live tilt direction hint arrows
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded,
                    color: blue.withValues(alpha: 
                        rawX > 0 ? 0.9 : 0.25),
                    size: 20),
                const SizedBox(width: 6),
                Text('Tilt',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.lightOnSurfaceVariant,
                    )),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded,
                    color: yellow.withValues(alpha: 
                        rawX < 0 ? 0.9 : 0.25),
                    size: 20),
              ],
            ),
            const SizedBox(height: 10),

            // Phone — rotates with raw accelerometer data
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: tiltRad),
              duration: const Duration(milliseconds: 100),
              builder: (_, angle, __) => Transform.rotate(
                angle: angle,
                child: Container(
                  width: 88,
                  height: 152,
                  decoration: BoxDecoration(
                    color: phone,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isFlat ? AppColors.error : accent,
                      width: justDetected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isFlat
                            ? Colors.transparent
                            : accent.withValues(alpha: glowOpacity),
                        blurRadius: 18,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Icon(
                          isFlat
                              ? Icons.smartphone_rounded
                              : justDetected
                                  ? Icons.check_circle_rounded
                                  : Icons.stay_current_portrait_rounded,
                          key: ValueKey('$isFlat$justDetected'),
                          color: isFlat ? AppColors.error : accent,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isFlat
                            ? 'Flat'
                            : rawX > 1.5
                                ? '← Left'
                                : rawX < -1.5
                                    ? 'Right →'
                                    : 'Upright',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isFlat ? AppColors.error : accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interactive playground
// ---------------------------------------------------------------------------

class _TiltPlayground extends StatelessWidget {
  const _TiltPlayground({
    required this.isDark,
    required this.rawX,
    required this.isFlat,
    required this.justDetected,
    required this.lastLabel,
    required this.l10n,
  });

  final bool   isDark;
  final double rawX;
  final bool   isFlat;
  final bool   justDetected;
  final String? lastLabel;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final _cfg   = ProviderScope.containerOf(context, listen: false)
        .read(visionConfigProvider);
    final yellow  = _cfg.accentYellow;
    final blue    = _cfg.accentBlue;
    final theme      = Theme.of(context);
    final surface    = isDark ? AppColors.darkSurface    : AppColors.lightSurface;
    final border     = isDark ? AppColors.darkBorder     : AppColors.lightBorder;
    final onSurface  = isDark ? AppColors.darkOnSurface  : AppColors.lightOnSurface;
    final onVariant  = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Live tilt meter ───────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: isFlat
                ? AppColors.error.withValues(alpha: isDark ? 0.12 : 0.07)
                : justDetected
                    ? yellow.withValues(alpha: isDark ? 0.13 : 0.07)
                    : surface,
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(
              color: isFlat
                  ? AppColors.error
                  : justDetected
                      ? yellow
                      : border,
              width: (isFlat || justDetected) ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              // Status line
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  isFlat
                      ? l10n.inertialFlatWarning
                      : justDetected
                          ? (lastLabel ?? l10n.inertialTiltDetected)
                          : l10n.inertialTryItHint,
                  key: ValueKey('$isFlat$justDetected$lastLabel'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isFlat
                        ? AppColors.error
                        : justDetected
                            ? yellow
                            : onVariant,
                    fontWeight: (isFlat || justDetected)
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Tilt bar — maps accelerometer X to bar position
              _TiltBar(rawX: rawX, isDark: isDark, isFlat: isFlat),

              const SizedBox(height: AppSpacing.xs + 2),

              // Labels — Flexible so they never overflow at large font scales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text('← Tutorial',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: blue,
                            fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('Hold 1 s',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: onVariant)),
                  ),
                  Flexible(
                    child: Text('Settings →',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: yellow,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Legend ────────────────────────────────────────────────────────
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
                icon: Icons.screen_rotation_alt_rounded,
                color: yellow,
                label: l10n.inertialLegendRight,
                action: l10n.inertialLegendOpensSettings,
                theme: theme, onSurface: onSurface, onVariant: onVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              _LegendRow(
                icon: Icons.screen_rotation_rounded,
                color: blue,
                label: l10n.inertialLegendLeft,
                action: l10n.inertialLegendOpensTutorial,
                theme: theme, onSurface: onSurface, onVariant: onVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              _LegendRow(
                icon: Icons.swap_horiz_rounded,
                color: const Color(0xFF4CAF50),
                label: l10n.inertialLegendGoBack,
                action: '',
                theme: theme, onSurface: onSurface, onVariant: onVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tilt bar — accelerometer X mapped to position
// ---------------------------------------------------------------------------

class _TiltBar extends StatelessWidget {
  const _TiltBar({required this.rawX, required this.isDark, required this.isFlat});
  final double rawX;
  final bool   isDark;
  final bool   isFlat;

  // X values that must be exceeded to trigger (matching _dominanceMargin + absY)
  // Visually we show the zone roughly at ±6/9.8 ≈ ±0.6 of full width
  static const double _triggerFraction = 0.55;
  static const double _maxRaw          = 9.8;

  @override
  Widget build(BuildContext context) {
    final _cfg   = ProviderScope.containerOf(context, listen: false)
        .read(visionConfigProvider);
    final yellow  = _cfg.accentYellow;
    final blue    = _cfg.accentBlue;
    final norm       = (rawX / _maxRaw).clamp(-1.0, 1.0); // +1 = left, -1 = right
    final trackColor = isDark
        ? AppColors.darkSurfaceVariant
        : const Color(0xFFE8ECF0);

    final Color dotColor;
    if (isFlat) {
      dotColor = AppColors.error;
    } else if (norm > _triggerFraction) {
      dotColor = blue;   // tilt left zone
    } else if (norm < -_triggerFraction) {
      dotColor = yellow; // tilt right zone
    } else {
      dotColor = isDark
          ? AppColors.darkOnSurfaceVariant
          : AppColors.lightOnSurfaceVariant;
    }

    return LayoutBuilder(builder: (_, c) {
      final w   = c.maxWidth;
      final mid = w / 2;
      // rawX > 0 = left tilt → dot moves LEFT (decreasing x)
      // rawX < 0 = right tilt → dot moves RIGHT (increasing x)
      final dotX = (mid - norm * mid).clamp(8.0, w - 8.0);

      return SizedBox(
        height: 28,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Track
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Left trigger zone marker
            Positioned(
              left: mid - _triggerFraction * mid - 1,
              child: Container(
                width: 2, height: 14,
                decoration: BoxDecoration(
                  color: blue.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            // Right trigger zone marker
            Positioned(
              left: mid + _triggerFraction * mid - 1,
              child: Container(
                width: 2, height: 14,
                decoration: BoxDecoration(
                  color: yellow.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            // Centre tick
            Positioned(
              left: mid - 1,
              child: Container(
                width: 2, height: 18,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            // Moving indicator dot
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              left: dotX - 8,
              child: Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.4),
                      blurRadius: 8, spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Legend row
// ---------------------------------------------------------------------------

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
    final hasAction = action.isNotEmpty;
    return Semantics(
      label: hasAction ? '$label — $action' : label,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fixed icon chip
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          // Label — gets the bulk of the row
          Expanded(
            flex: 3,
            child: Text(
              label,
              softWrap: true,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: onSurface, fontWeight: FontWeight.w500),
            ),
          ),
          // Action badge — only shown when non-empty
          if (hasAction) ...[
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: Text(
                action,
                textAlign: TextAlign.end,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
