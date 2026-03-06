import 'package:flutter/material.dart';

import '../../domain/tutorial_route.dart';
import 'denomination_vibration_tutorial.dart';
import 'gestural_navigation_tutorial.dart';
import 'shake_tutorial.dart';

/// Single entry point for pushing any feature tutorial onto the navigator.
///
/// Usage:
/// ```dart
/// TutorialNavigator.push(context, TutorialRoute.shakeToGoBack);
/// ```
///
/// Adding a new tutorial:
///   1. Add a value to [TutorialRoute].
///   2. Add a case in [_buildScreen] returning the new widget.
///   Done — animation, back gesture, and scaffold are all inherited.
abstract final class TutorialNavigator {
  /// Pushes the feature tutorial for [route] with a slide-up presentation.
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
    };
  }

  /// Slide up from bottom — feels like a detail sheet, distinct from the
  /// horizontal slide used for Settings and the main Tutorial screen.
  static PageRoute<void> _slideUp(Widget page) => PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => page,
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
