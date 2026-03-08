import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/inertial_detector_widget.dart';
import '../core/services/shake_detector_widget.dart';
import '../core/theme/app_theme.dart';
import '../features/scanner/presentation/screens/scanner_screen.dart'
    show routeObserverProvider;
import '../features/settings/presentation/providers/settings_provider.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/tutorial/presentation/screens/tutorial_screen.dart';
import 'home_shell.dart';

class MoneySenseApp extends ConsumerWidget {
  const MoneySenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings      = ref.watch(appSettingsProvider);
    final routeObserver = ref.read(routeObserverProvider);

    return Builder(
      builder: (outerCtx) {
        return MediaQuery(
          data: MediaQuery.of(outerCtx).copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: MaterialApp(
            title: 'MoneySense',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.flutterThemeMode,
            navigatorObservers: [routeObserver],
            home: _AppRoot(),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _AppRoot — owns both sensor wrappers so they share the Navigator context
// ---------------------------------------------------------------------------

class _AppRoot extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  // ── Inertial navigation ───────────────────────────────────────────────────

  /// Tilt LEFT → Tutorial (mirrored: tutorial is to the right of home in nav
  /// order, but the physical gesture "pushes" to the right visually).
  void _onTiltLeft() {
    final nav = Navigator.of(context, rootNavigator: false);
    // Only navigate if we are at the root (not already on a pushed route)
    if (nav.canPop()) {
      // We're on a sub-screen — go back home
      nav.maybePop();
    } else {
      _pushTutorial(context);
    }
  }

  /// Tilt RIGHT → Settings
  void _onTiltRight() {
    final nav = Navigator.of(context, rootNavigator: false);
    if (nav.canPop()) {
      nav.maybePop();
    } else {
      _pushSettings(context);
    }
  }

  void _pushSettings(BuildContext ctx) {
    Navigator.of(ctx).push(_slideFromLeft(const SettingsScreen()));
  }

  void _pushTutorial(BuildContext ctx) {
    Navigator.of(ctx).push(_slideFromRight(const TutorialScreen()));
  }

  PageRoute<void> _slideFromLeft(Widget page) => PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      );

  PageRoute<void> _slideFromRight(Widget page) => PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ShakeDetectorWidget(
      child: InertialDetectorWidget(
        onTiltLeft:  _onTiltLeft,
        onTiltRight: _onTiltRight,
        child: const HomeShell(),
      ),
    );
  }
}
