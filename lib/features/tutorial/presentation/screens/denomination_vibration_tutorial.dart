import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../widgets/ps_tutorial_scaffold.dart';

// ---------------------------------------------------------------------------
// vibration patterns
// ---------------------------------------------------------------------------

class _Denomination {
  const _Denomination({
    required this.label,
    required this.isCoin,
    required this.pattern,
    required this.description,
  });

  final String label;
  final bool isCoin;
  final List<int> pattern;
  final String description;
}

const int _long = 350;
const int _short = 100;
const int _igap = 120;
const int _ggap = 300;

List<int> _coin(int shorts) {
  final p = <int>[_long];
  if (shorts > 0) {
    p.add(_ggap);
    for (int i = 0; i < shorts; i++) {
      p.add(_short);
      if (i < shorts - 1) p.add(_igap);
    }
  }
  return p;
}

List<int> _bill(int shorts) {
  final p = <int>[];
  for (int i = 0; i < shorts; i++) {
    p.add(_short);
    if (i < shorts - 1) p.add(_igap);
  }
  return p;
}

const _denominations = [
  _Denomination(
    label: '1 peso coin',
    isCoin: true,
    pattern: [],
    description: '1 long, 1 short',
  ),
  _Denomination(
    label: '5 peso coin',
    isCoin: true,
    pattern: [],
    description: '1 long, 2 short',
  ),
  _Denomination(
    label: '10 peso coin',
    isCoin: true,
    pattern: [],
    description: '1 long, 3 short',
  ),
  _Denomination(
    label: '20 peso coin',
    isCoin: true,
    pattern: [],
    description: '1 long, 4 short',
  ),
  _Denomination(
    label: '20 peso bill',
    isCoin: false,
    pattern: [],
    description: '1 short',
  ),
  _Denomination(
    label: '50 peso bill',
    isCoin: false,
    pattern: [],
    description: '2 short',
  ),
  _Denomination(
    label: '100 peso bill',
    isCoin: false,
    pattern: [],
    description: '3 short',
  ),
  _Denomination(
    label: '200 peso bill',
    isCoin: false,
    pattern: [],
    description: '4 short',
  ),
  _Denomination(
    label: '500 peso bill',
    isCoin: false,
    pattern: [],
    description: '5 short',
  ),
  _Denomination(
    label: '1000 peso bill',
    isCoin: false,
    pattern: [],
    description: '6 short',
  ),
];

List<List<int>> _buildPatterns() => [
  _coin(1),
  _coin(2),
  _coin(3),
  _coin(4),
  _bill(1),
  _bill(2),
  _bill(3),
  _bill(4),
  _bill(5),
  _bill(6),
];

// ---------------------------------------------------------------------------
// screen
// ---------------------------------------------------------------------------

class DenominationVibrationTutorial extends StatefulWidget {
  const DenominationVibrationTutorial({super.key});

  @override
  State<DenominationVibrationTutorial> createState() =>
      _DenominationVibrationTutorialState();
}

class _DenominationVibrationTutorialState
    extends State<DenominationVibrationTutorial> {
  final _patterns = _buildPatterns();
  int? _playing;

  Future<void> _play(int index) async {
    try {
      await Vibration.cancel();
    } catch (_) {}
    if (!mounted) return;

    setState(() => _playing = index);

    final pattern = _patterns[index];
    HapticFeedback.mediumImpact();

    try {
      final hasV = await Vibration.hasVibrator() ?? false;
      if (hasV) {
        await Vibration.vibrate(pattern: [0, ...pattern]);
      }
    } catch (_) {}

    if (mounted) {
      final total = pattern.fold<int>(0, (s, v) => s + v) + 200;
      await Future.delayed(Duration(milliseconds: total));
      if (mounted) setState(() => _playing = null);
    }
  }

  Future<void> _playDemo() async {
    for (int i = 0; i < _denominations.length; i++) {
      await _play(i);
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    try {
      Vibration.cancel();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PsTutorialScaffold(
      title: 'Denomination Vibration',
      badge: 'Scanning',
      description:
          'Each Philippine denomination produces a unique vibration pattern '
          'so you can identify your currency by touch alone — no screen needed.',
      steps: const [
        'Enable denomination vibration in Settings → Scanning.',
        'Scan a bill or coin with the camera.',
        'The phone vibrates with the pattern shown below.',
        'Use the list to learn each denomination\'s pattern.',
      ],
      hero: _VibrationHero(isDark: isDark),
      interactive: _PatternList(
        denominations: _denominations,
        patterns: _patterns,
        playing: _playing,
        onPlay: _play,
        onPlayDemo: _playDemo,
        isDark: isDark,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// hero illustration
// ---------------------------------------------------------------------------

class _VibrationHero extends StatefulWidget {
  const _VibrationHero({required this.isDark});
  final bool isDark;

  @override
  State<_VibrationHero> createState() => _VibrationHeroState();
}

class _VibrationHeroState extends State<_VibrationHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shake;
  late final Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: false);

    _shake = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 6),
    ]).animate(_ctrl);

    _ring = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      color: bg,
      child: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(3, (i) {
                final progress = (_ring.value - i * 0.28).clamp(0.0, 1.0);
                final scale = 1.0 + progress * 1.6;
                return Opacity(
                  opacity: (1.0 - progress) * 0.35,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accentYellow,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              Transform.translate(
                offset: Offset(_shake.value, 0),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentYellow.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.vibration_rounded,
                    color: AppColors.darkBackground,
                    size: 36,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// pattern list
// ---------------------------------------------------------------------------

class _PatternList extends StatelessWidget {
  const _PatternList({
    required this.denominations,
    required this.patterns,
    required this.playing,
    required this.onPlay,
    required this.onPlayDemo,
    required this.isDark,
  });

  final List<_Denomination> denominations;
  final List<List<int>> patterns;
  final int? playing;
  final void Function(int) onPlay;
  final VoidCallback onPlayDemo;
  final bool isDark;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Play vibration demo. Plays all patterns in sequence. Button',
          button: true,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: playing == null ? onPlayDemo : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                border: Border.all(
                  color: AppColors.accentYellow.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.accentYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.darkBackground,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Play vibration demo',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Plays all patterns in sequence',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (playing != null)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accentYellow,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            'PATTERNS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: onVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(color: border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            child: Column(
              children: List.generate(denominations.length, (i) {
                final d = denominations[i];
                final isPlaying = playing == i;
                final isLast = i == denominations.length - 1;

                return Column(
                  children: [
                    Semantics(
                      label: '${d.label}. Pattern: ${d.description}. Button',
                      button: true,
                      excludeSemantics: true,
                      child: InkWell(
                        onTap: () => onPlay(i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base,
                            vertical: AppSpacing.md + 2,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: d.isCoin
                                      ? AppColors.accentYellow
                                      : AppColors.accentBlue,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.label,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    _PatternDots(
                                      isCoin: d.isCoin,
                                      description: d.description,
                                      isPlaying: isPlaying,
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: isPlaying
                                    ? const SizedBox(
                                        key: ValueKey('loading'),
                                        width: 32,
                                        height: 32,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.accentYellow,
                                        ),
                                      )
                                    : GestureDetector(
                                        key: const ValueKey('play'),
                                        onTap: () => onPlay(i),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.accentYellow
                                                .withOpacity(0.12),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.accentYellow
                                                  .withOpacity(0.4),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow_rounded,
                                            color: AppColors.accentYellow,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: AppSpacing.base,
                        endIndent: AppSpacing.base,
                        color: border,
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// pattern dot visualizer
// ---------------------------------------------------------------------------

class _PatternDots extends StatelessWidget {
  const _PatternDots({
    required this.isCoin,
    required this.description,
    required this.isPlaying,
  });

  final bool isCoin;
  final String description;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final parts = description.split(', ');
    final dots = <Widget>[];

    for (final part in parts) {
      final tokens = part.trim().split(' ');
      final count = int.tryParse(tokens[0]) ?? 1;
      final isLong = tokens.contains('long');

      for (int i = 0; i < count; i++) {
        dots.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isLong ? 20 : 8,
            height: 6,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: isPlaying
                  ? AppColors.accentYellow
                  : (isCoin
                        ? AppColors.accentYellow.withOpacity(0.5)
                        : AppColors.accentBlue.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: dots),
    );
  }
}
