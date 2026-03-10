import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../features/settings/domain/entities/vision_config.dart';

/// Bottom navigation bar for MoneySense.
///
/// Colors adapt to the active VisionProfile through [visionConfigProvider].
/// All accent colours come from [VisionConfig.accent] / [VisionConfig.accentYellow]
/// so contrast boosts applied in Settings propagate here automatically.
class MsBottomNav extends ConsumerWidget {
  const MsBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isCameraOpen = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isCameraOpen;

  static const double _gap          = 12.0;
  static const double _buttonHeight = 70.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final cfg     = ref.watch(visionConfigProvider);
    final bg      = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    final yellow  = cfg.accentYellow;
    final blue    = cfg.accentBlue;

    return SafeArea(
      top: false,
      child: ColoredBox(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding, AppSpacing.sm,
            AppSpacing.pagePadding, AppSpacing.base,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Settings
              Expanded(
                child: _NavButton(
                  icon: Icons.settings_rounded,
                  semanticLabel: 'Settings',
                  height: _buttonHeight,
                  bgColor: yellow,
                  iconColor: AppColors.darkBackground,
                  glowColor: yellow,
                  isSelected: currentIndex == 0,
                  onTap: () { HapticFeedback.lightImpact(); onTap(0); },
                ),
              ),
              const SizedBox(width: _gap),
              // Scan / Stop
              Expanded(
                child: _NavButton(
                  icon: isCameraOpen
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  semanticLabel: isCameraOpen ? 'Stop Camera' : 'Open Camera',
                  height: _buttonHeight,
                  bgColor: blue,
                  iconColor: Colors.white,
                  glowColor: blue,
                  isSelected: currentIndex == 1,
                  isRound: true,
                  onTap: () { HapticFeedback.mediumImpact(); onTap(1); },
                ),
              ),
              const SizedBox(width: _gap),
              // Tutorial
              Expanded(
                child: _NavButton(
                  icon: Icons.help_outline_rounded,
                  semanticLabel: 'Tutorial',
                  height: _buttonHeight,
                  bgColor: yellow,
                  iconColor: AppColors.darkBackground,
                  glowColor: yellow,
                  isSelected: currentIndex == 2,
                  onTap: () { HapticFeedback.lightImpact(); onTap(2); },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.semanticLabel,
    required this.height,
    required this.bgColor,
    required this.iconColor,
    required this.glowColor,
    required this.isSelected,
    required this.onTap,
    this.isRound = false,
  });

  final IconData icon;
  final String semanticLabel;
  final double height;
  final Color bgColor;
  final Color iconColor;
  final Color glowColor;
  final bool isSelected;
  final bool isRound;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = isRound
        ? BorderRadius.circular(height / 2)
        : BorderRadius.circular(AppSpacing.buttonRadius);

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: isSelected ? 0.6 : 0.28),
                blurRadius: isSelected ? 18 : 8,
                spreadRadius: isSelected ? 2 : 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: height * 0.44),
          ),
        ),
      ),
    );
  }
}
