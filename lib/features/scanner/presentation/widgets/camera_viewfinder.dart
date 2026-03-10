import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/scanner_state.dart';

/// Animated camera viewfinder that reflects the current [ScannerState].
///
/// Border colors per state (consistent in both light & dark — matches design):
///   idle/previewing → subtle grey
///   scanning        → [AppColors.accentYellow]  (pulsing)
///   processing      → [AppColors.accentBlue]    (pulsing)
///   result          → [AppColors.success]       (solid)
///
/// The border is drawn OUTSIDE the content via a wrapping container with
/// padding equal to the border width, so it is never clipped by the screen
/// edge. The Scanner screen must give this widget enough margin.
class CameraViewfinder extends StatefulWidget {
  const CameraViewfinder({
    super.key,
    required this.scannerState,
    this.child,
    this.statusLabel,
    this.isDark = true,
  });

  final ScannerState scannerState;
  final Widget? child;
  final String? statusLabel;
  final bool isDark;

  @override
  State<CameraViewfinder> createState() => _CameraViewfinderState();
}

class _CameraViewfinderState extends State<CameraViewfinder>
    with SingleTickerProviderStateMixin {
  static const double _borderWidth = 5.0;
  static const double _radius = 20.0;

  late AnimationController _pulseController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(CameraViewfinder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scannerState != widget.scannerState) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    final shouldPulse = widget.scannerState == ScannerState.scanning ||
        widget.scannerState == ScannerState.processing;
    if (shouldPulse) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _borderColor {
    switch (widget.scannerState) {
      case ScannerState.scanning:
        return AppColors.accentYellow;
      case ScannerState.processing:
        return AppColors.accentBlue;
      case ScannerState.result:
        return AppColors.success;
      default:
        return widget.isDark
            ? const Color(0xFF2E2E2E)
            : const Color(0xFFCCCCCC);
    }
  }

  Color get _backgroundColor {
    return widget.isDark ? Colors.black : AppColors.lightSurfaceVariant;
  }

  // Glow is only shown during active states
  List<BoxShadow> get _glow {
    final Color? glowColor;
    switch (widget.scannerState) {
      case ScannerState.scanning:
        glowColor = AppColors.accentYellow;
        break;
      case ScannerState.processing:
        glowColor = AppColors.accentBlue;
        break;
      default:
        glowColor = null;
    }
    if (glowColor == null) return const [];
    return [
      BoxShadow(
        color: glowColor.withValues(alpha: _opacityAnimation.value * 0.6),
        blurRadius: 18,
        spreadRadius: 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          // The border + glow are on this outer container.
          // Content is inset so the border is never hidden behind clip.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: _borderColor.withValues(alpha: _opacityAnimation.value),
              width: _borderWidth,
            ),
            boxShadow: _glow,
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius - _borderWidth),
        child: Stack(
          children: [
            // Background + camera preview
            Container(
              color: _backgroundColor,
              child: widget.child ?? const SizedBox.expand(),
            ),
            // Status label at the bottom
            if (widget.statusLabel != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  color: Colors.black.withValues(alpha: 0.6),
                  child: Text(
                    widget.statusLabel!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
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
