import 'package:flutter/material.dart';

import '../../domain/tutorial_route.dart';
import 'app_navigation_tutorial.dart';
import 'denomination_vibration_tutorial.dart';
import 'gestural_navigation_tutorial.dart';
import 'inertial_navigation_tutorial.dart';
import 'shake_tutorial.dart';

/// Single entry point for pushing any feature tutorial onto the navigator.
abstract final class TutorialNavigator {
  static Future<void> push(BuildContext context, TutorialRoute route) {
    return Navigator.of(context).push(_slideUp(_buildScreen(route)));
  }

  static Widget _buildScreen(TutorialRoute route) {
    return switch (route) {
      TutorialRoute.denominationVibration =>
        const DenominationVibrationTutorial(),
      TutorialRoute.shakeToGoBack =>
        const ShakeTutorial(),
      TutorialRoute.gesturalNavigation =>
        const GesturalNavigationTutorial(),
      TutorialRoute.inertialNavigation =>
        const InertialNavigationTutorial(),
      TutorialRoute.appNavigation =>
        const AppNavigationTutorial(),
    };
  }

  /// Slide up from bottom — feels like a detail sheet, distinct from the
  /// horizontal slide used for Settings and the main Tutorial screen.
  static PageRoute<void> _slideUp(Widget page) => PageRouteBuilder<void>(
        pageBuilder: (_, __, _) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 320),
      );
}
