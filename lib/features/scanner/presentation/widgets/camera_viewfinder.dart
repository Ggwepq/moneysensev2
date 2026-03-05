import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/scanner_state.dart';

/// Animated camera viewfinder that reflects the current [ScannerState].
///
/// Border colors per state:
///   idle/previewing → [AppColors.darkBorder]      (neutral dark)
///   scanning        → [AppColors.accentYellow]    (yellow, pulsing)
///   processing      → [AppColors.accentBlue]      (blue, pulsing)
///   result          → [AppColors.success]         (green)
class CameraViewfinder extends StatefulWidget {
  const CameraViewfinder({
    super.key,
    required this.scannerState,
    this.child,
    this.statusLabel,
    this.isDark = true,
  });

  final ScannerState scannerState;

  /// The camera preview widget (or placeholder if camera is off).
  final Widget? child;

  /// Optional label shown at the bottom of the viewfinder.
  final String? statusLabel;

  final bool isDark;

  @override
  State<CameraViewfinder> createState() => _CameraViewfinderState();
}

class _CameraViewfinderState extends State<CameraViewfinder>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
        return AppColors.scannerBorderScanning;
      case ScannerState.processing:
        return AppColors.scannerBorderProcessing;
      case ScannerState.result:
        return AppColors.success;
      default:
        return widget.isDark
            ? AppColors.darkBorder
            : AppColors.lightBorder;
    }
  }

  Color get _backgroundColor {
    return widget.isDark ? Colors.black : AppColors.lightSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _borderColor.withOpacity(_opacityAnimation.value),
              width: 3,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: child,
        );
      },
      child: Stack(
        children: [
          // Camera preview (or placeholder)
          Positioned.fill(
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
                color: Colors.black.withOpacity(0.6),
                child: Text(
                  widget.statusLabel!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
