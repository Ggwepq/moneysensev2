import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Custom bottom navigation bar matching the PesoSense design.
///
/// Three buttons:
///  - [0] Settings  — gear icon, yellow square
///  - [1] Scan      — play icon, blue circle (larger, CTA)
///  - [2] Help      — question mark, yellow square
///
/// The center button is intentionally larger to draw attention as the
/// primary action.
class PsBottomNav extends StatelessWidget {
  const PsBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isCameraOpen = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// When [isCameraOpen] is true the center button shows a stop icon.
  final bool isCameraOpen;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.base,
        ),
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Settings
            _NavButton(
              icon: Icons.settings,
              isSelected: currentIndex == 0,
              isDark: isDark,
              semanticLabel: 'Settings',
              size: 52,
              onTap: () {
                HapticFeedback.lightImpact();
                onTap(0);
              },
            ),
            const SizedBox(width: AppSpacing.xl),
            // Scan (center, larger)
            _NavButton(
              icon: isCameraOpen
                  ? Icons.stop_circle_outlined
                  : Icons.play_circle_fill_rounded,
              isSelected: currentIndex == 1,
              isDark: isDark,
              semanticLabel: isCameraOpen ? 'Stop Camera' : 'Open Camera',
              size: 64,
              isCircle: true,
              accentColor: AppColors.accentBlue,
              iconColor: Colors.white,
              onTap: () {
                HapticFeedback.mediumImpact();
                onTap(1);
              },
            ),
            const SizedBox(width: AppSpacing.xl),
            // Tutorial / Help
            _NavButton(
              icon: Icons.help_outline_rounded,
              isSelected: currentIndex == 2,
              isDark: isDark,
              semanticLabel: 'Tutorial',
              size: 52,
              onTap: () {
                HapticFeedback.lightImpact();
                onTap(2);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Individual Button ────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.semanticLabel,
    required this.size,
    required this.onTap,
    this.isCircle = false,
    this.accentColor,
    this.iconColor,
  });

  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final String semanticLabel;
  final double size;
  final VoidCallback onTap;
  final bool isCircle;
  final Color? accentColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final defaultAccent =
        isDark ? AppColors.accentYellow : AppColors.accentBlue;
    final bg = accentColor ?? defaultAccent;
    final ic = iconColor ??
        (isDark ? AppColors.darkBackground : Colors.white);

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: isCircle
                ? BorderRadius.circular(size / 2)
                : BorderRadius.circular(AppSpacing.buttonRadius),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: bg.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Icon(icon, color: ic, size: size * 0.45),
        ),
      ),
    );
  }
}
