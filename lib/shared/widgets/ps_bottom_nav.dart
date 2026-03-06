import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Bottom navigation bar for PesoSense.
///
/// Three equal-width buttons that together span the full screen width
/// (minus horizontal page padding). The layout matches the design:
///
///   |← pagePadding →|  [⚙]  gap  [▶]  gap  [?]  |← pagePadding →|
///
/// All three buttons are the same size — driven by [Expanded] so they
/// automatically divide the available width equally on every device.
///
/// Colors (both light & dark, matching design):
///   [⚙] and [?] → yellow background, dark icon
class PsBottomNav extends StatelessWidget {
  const PsBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isCameraOpen = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isCameraOpen;

  // Gap between the three buttons
  static const double _gap = 12.0;

  // Height of each button. Width is driven by Expanded so on most phones
  // each button ends up close to square (screen_width - 2*padding - 2*gaps) / 3.
  static const double _buttonHeight = 100.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return SafeArea(
      top: false,
      child: ColoredBox(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.sm,
            AppSpacing.pagePadding,
            AppSpacing.base,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Settings ────────────────────────────────────────────────
              Expanded(
                child: _EqualButton(
                  icon: Icons.settings_rounded,
                  semanticLabel: 'Settings',
                  height: _buttonHeight,
                  bgColor: AppColors.accentYellow,
                  iconColor: AppColors.darkBackground,
                  isSelected: currentIndex == 0,
                  glowColor: AppColors.accentYellow,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(0);
                  },
                ),
              ),
              const SizedBox(width: _gap),
              // ── Scan / Stop ─────────────────────────────────────────────
              Expanded(
                child: _EqualButton(
                  icon: isCameraOpen
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  semanticLabel: isCameraOpen ? 'Stop Camera' : 'Open Camera',
                  height: _buttonHeight,
                  bgColor: AppColors.accentBlue,
                  iconColor: Colors.white,
                  isSelected: currentIndex == 1,
                  isRound: true,
                  glowColor: AppColors.accentBlue,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onTap(1);
                  },
                ),
              ),
              const SizedBox(width: _gap),
              // ── Tutorial / Help ─────────────────────────────────────────
              Expanded(
                child: _EqualButton(
                  icon: Icons.help_outline_rounded,
                  semanticLabel: 'Tutorial',
                  height: _buttonHeight,
                  bgColor: AppColors.accentYellow,
                  iconColor: AppColors.darkBackground,
                  isSelected: currentIndex == 2,
                  glowColor: AppColors.accentYellow,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(2);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Equal-width button ───────────────────────────────────────────────────────

/// A button that fills its parent's width (used inside [Expanded]).
/// Height is fixed; width is unconstrained so [Expanded] can size it.
class _EqualButton extends StatelessWidget {
  const _EqualButton({
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
    // Border radius: pill/round for center, rounded-rect for sides
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
          // width is unconstrained — Expanded handles it
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(isSelected ? 0.6 : 0.28),
                blurRadius: isSelected ? 18 : 8,
                spreadRadius: isSelected ? 2 : 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              // Icon scales with button height
              size: height * 0.44,
            ),
          ),
        ),
      ),
    );
  }
}
