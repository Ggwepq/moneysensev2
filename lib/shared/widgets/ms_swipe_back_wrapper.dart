import 'package:flutter/material.dart';
import '../../core/services/earcon_service.dart';

/// A wrapper that provides gestural navigation (swipe back).
///
/// Designed for accessibility, this allows a quick swipe from anywhere
/// on the screen to go back to the previous route, provided that
/// [isGesturalNavigationEnabled] is true.
class MsSwipeBackWrapper extends StatelessWidget {
  const MsSwipeBackWrapper({
    super.key,
    required this.child,
    required this.isGesturalNavigationEnabled,
  });

  final Widget child;
  final bool isGesturalNavigationEnabled;

  static const double _minVelocity = 300.0;
  static const double _maxCrossRatio = 0.55;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        if (!isGesturalNavigationEnabled) return;
        final v = details.velocity.pixelsPerSecond;
        final ax = v.dx.abs();
        final ay = v.dy.abs();
        if (ax < _minVelocity) return;
        if (ax < ay) return;
        if (ay / ax > _maxCrossRatio) return;

        // Note: In some locales/platforms, swipe direction might vary,
        // but for this app it's a fixed left-to-right or right-to-left
        // swipe logic based on standard MoneySense accessibility patterns.
        if (v.dx < 0) {
          EarconService.instance.play(EarconEvent.navBack);
          Navigator.of(context).maybePop();
        }
      },
      child: child,
    );
  }
}
