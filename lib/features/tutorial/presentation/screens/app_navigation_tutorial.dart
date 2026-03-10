import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../settings/domain/entities/vision_config.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

// ---------------------------------------------------------------------------
// AppNavigationTutorial
// ---------------------------------------------------------------------------
//
// Interactive walkthrough of the three main screens and how to navigate.
// 5 pages, each focused on one concept:
//   0 — Three screens overview (Scanner, Settings, Tutorial)
//   1 — Bottom navigation bar
//   2 — Gestural navigation (swipe)
//   3 — Inertial navigation (tilt)
//   4 — Shake to go back

class AppNavigationTutorial extends ConsumerStatefulWidget {
  const AppNavigationTutorial({super.key});

  @override
  ConsumerState<AppNavigationTutorial> createState() =>
      _AppNavigationTutorialState();
}

class _AppNavigationTutorialState
    extends ConsumerState<AppNavigationTutorial> {
  final _controller = PageController();
  int _page = 0;

  static const int _pageCount = 5;

  void _next() {
    if (_page < _pageCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prev() {
    if (_page > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg      = ref.watch(visionConfigProvider);
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final accent   = cfg.accent(isDark);
    final bg       = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('App Navigation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close tutorial',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Page indicator
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
            child: Row(
              children: List.generate(_pageCount, (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < _pageCount - 1 ? 4 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 3,
                    decoration: BoxDecoration(
                      color: i <= _page ? accent : accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              )),
            ),
          ),

          // Pages
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (p) => setState(() => _page = p),
              children: [
                _OverviewPage(isDark: isDark, accent: accent),
                _BottomNavPage(isDark: isDark, accent: accent),
                _GesturalPage(isDark: isDark, accent: accent),
                _InertialPage(isDark: isDark, accent: accent),
                _ShakePage(isDark: isDark, accent: accent),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
            child: Row(
              children: [
                if (_page > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.base),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSpacing.buttonRadius),
                        ),
                        side: BorderSide(color: accent),
                      ),
                      onPressed: _prev,
                      child: const Text('Back'),
                    ),
                  ),
                if (_page > 0) const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: accent.computeLuminance() > 0.4
                          ? Colors.black
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.base),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppSpacing.buttonRadius),
                      ),
                    ),
                    onPressed: _next,
                    child: Text(
                      _page == _pageCount - 1 ? 'Done' : 'Next',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tutorial pages ─────────────────────────────────────────────────────────────

class _OverviewPage extends StatelessWidget {
  const _OverviewPage({required this.isDark, required this.accent});
  final bool isDark;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _TutPage(
      icon: Icons.widgets_rounded,
      accent: accent,
      title: 'Three screens',
      body: 'MoneySense has three screens you can always reach from anywhere in the app.',
      children: [
        _ScreenCard(
          icon: Icons.crop_free_rounded,
          label: 'Scanner',
          description: 'Point your camera at Philippine currency to identify it.',
          accent: accent,
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ScreenCard(
          icon: Icons.settings_rounded,
          label: 'Settings',
          description: 'Adjust vision profile, language, navigation, and audio.',
          accent: accent,
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ScreenCard(
          icon: Icons.school_rounded,
          label: 'Tutorial',
          description: 'Interactive guides for every app feature.',
          accent: accent,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _BottomNavPage extends StatelessWidget {
  const _BottomNavPage({required this.isDark, required this.accent});
  final bool isDark;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _TutPage(
      icon: Icons.swap_horiz_rounded,
      accent: accent,
      title: 'Bottom navigation',
      body:
          'The bottom bar is always visible. Tap the left icon for Settings, the centre to start or stop scanning, and the right icon for Tutorial.',
      children: [
        _MockBottomNav(accent: accent, isDark: isDark),
        const SizedBox(height: AppSpacing.md),
        _Hint(
          icon: Icons.touch_app_rounded,
          text: 'This is the primary way to navigate. All three styles support it.',
          isDark: isDark,
        ),
      ],
    );
  }
}

class _GesturalPage extends StatelessWidget {
  const _GesturalPage({required this.isDark, required this.accent});
  final bool isDark;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _TutPage(
      icon: Icons.swipe_rounded,
      accent: accent,
      title: 'Gestural navigation',
      body:
          'When Gestural mode is on, you can swipe left or right with one finger on the scanner screen to open Settings or Tutorial.',
      children: [
        _GestureDemo(accent: accent, isDark: isDark),
        const SizedBox(height: AppSpacing.md),
        _Hint(
          icon: Icons.info_outline_rounded,
          text: 'Enable in Settings under Navigation, or go back and change your navigation style.',
          isDark: isDark,
        ),
      ],
    );
  }
}

class _InertialPage extends StatelessWidget {
  const _InertialPage({required this.isDark, required this.accent});
  final bool isDark;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _TutPage(
      icon: Icons.screen_rotation_rounded,
      accent: accent,
      title: 'Inertial navigation',
      body:
          'When Inertial mode is on, tilt your phone left to open Tutorial and right to open Settings. Hold the tilt for one second to confirm.',
      children: [
        _TiltDemo(accent: accent, isDark: isDark),
        const SizedBox(height: AppSpacing.md),
        _Hint(
          icon: Icons.info_outline_rounded,
          text: 'Useful when you need hands-free navigation while holding currency.',
          isDark: isDark,
        ),
      ],
    );
  }
}

class _ShakePage extends StatelessWidget {
  const _ShakePage({required this.isDark, required this.accent});
  final bool isDark;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _TutPage(
      icon: Icons.vibration_rounded,
      accent: accent,
      title: 'Shake to go back',
      body:
          'From any screen, give your phone a quick shake to go back to the scanner. No button needed.',
      children: [
        _ShakeDemo(accent: accent, isDark: isDark),
        const SizedBox(height: AppSpacing.md),
        _Hint(
          icon: Icons.settings_rounded,
          text: 'Enable or disable this in Settings under Navigation.',
          isDark: isDark,
        ),
      ],
    );
  }
}

// ── Shared layout ─────────────────────────────────────────────────────────────

class _TutPage extends StatelessWidget {
  const _TutPage({
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    required this.children,
  });
  final IconData icon;
  final Color accent;
  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.base, AppSpacing.xl, AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accent, size: 28),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    )),
            const SizedBox(height: AppSpacing.sm),
            Text(body,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.6)),
            const SizedBox(height: AppSpacing.xl),
            ...children,
          ],
        ),
      );
}

// ── Demo widgets ──────────────────────────────────────────────────────────────

class _ScreenCard extends StatelessWidget {
  const _ScreenCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.accent,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final String description;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.lightOnSurfaceVariant,
                      height: 1.4,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MockBottomNav extends StatefulWidget {
  const _MockBottomNav({required this.accent, required this.isDark});
  final Color accent;
  final bool isDark;

  @override
  State<_MockBottomNav> createState() => _MockBottomNavState();
}

class _MockBottomNavState extends State<_MockBottomNav> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final items = [
      (Icons.settings_rounded, 'Settings'),
      (Icons.crop_free_rounded, 'Scan'),
      (Icons.school_rounded, 'Tutorial'),
    ];

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(
                color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm + 4, horizontal: AppSpacing.base),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final (icon, label) = items[i];
              final isSelected = i == _selected;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selected = i);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        color: isSelected ? widget.accent : null,
                        size: 26),
                    const SizedBox(height: 3),
                    Text(label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected ? widget.accent : null,
                        )),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _selected == 0
              ? 'Settings tapped'
              : _selected == 1
                  ? 'Scan button tapped'
                  : 'Tutorial tapped',
          style: TextStyle(
            fontSize: 13,
            color: widget.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _GestureDemo extends StatelessWidget {
  const _GestureDemo({required this.accent, required this.isDark});
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ArrowCard(
            icon: Icons.arrow_back_rounded,
            label: 'Swipe left',
            destination: 'Tutorial',
            accent: accent,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ArrowCard(
            icon: Icons.arrow_forward_rounded,
            label: 'Swipe right',
            destination: 'Settings',
            accent: accent,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _TiltDemo extends StatelessWidget {
  const _TiltDemo({required this.accent, required this.isDark});
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ArrowCard(
            icon: Icons.rotate_left_rounded,
            label: 'Tilt left',
            destination: 'Tutorial',
            accent: accent,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ArrowCard(
            icon: Icons.rotate_right_rounded,
            label: 'Tilt right',
            destination: 'Settings',
            accent: accent,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _ShakeDemo extends StatefulWidget {
  const _ShakeDemo({required this.accent, required this.isDark});
  final Color accent;
  final bool isDark;
  @override
  State<_ShakeDemo> createState() => _ShakeDemoState();
}

class _ShakeDemoState extends State<_ShakeDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _shake = Tween(begin: -8.0, end: 8.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.elasticIn),
  );

  void _simulate() {
    HapticFeedback.mediumImpact();
    _ctrl.forward(from: 0).then((_) => _ctrl.reverse());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    return Column(
      children: [
        AnimatedBuilder(
          animation: _shake,
          builder: (_, child) => Transform.translate(
            offset: Offset(_shake.value, 0),
            child: child,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
              border: Border.all(
                  color: widget.isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                Icon(Icons.vibration_rounded, size: 48, color: widget.accent),
                const SizedBox(height: AppSpacing.sm),
                const Text('Shake!',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton.icon(
          icon: Icon(Icons.play_arrow_rounded, color: widget.accent),
          label: Text('Simulate shake',
              style: TextStyle(color: widget.accent)),
          onPressed: _simulate,
        ),
      ],
    );
  }
}

class _ArrowCard extends StatelessWidget {
  const _ArrowCard({
    required this.icon,
    required this.label,
    required this.destination,
    required this.accent,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final String destination;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(destination,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
              )),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text, required this.isDark});
  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 18,
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.lightOnSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkOnSurfaceVariant
                      : AppColors.lightOnSurfaceVariant,
                  height: 1.4,
                )),
          ),
        ],
      );
}
