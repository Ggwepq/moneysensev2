import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// A premium, glassmorphic pulsing orb used during voice onboarding.
/// 
/// It visually represents the system's state:
/// - Listening: Pulsing blue/purple.
/// - Thinking/Speaking: Vibrant gold/yellow ripple.
class VoiceOnboardingOrb extends StatefulWidget {
  const VoiceOnboardingOrb({
    super.key,
    required this.isListening,
    required this.isSpeaking,
  });

  final bool isListening;
  final bool isSpeaking;

  @override
  State<VoiceOnboardingOrb> createState() => _VoiceOnboardingOrbState();
}

class _VoiceOnboardingOrbState extends State<VoiceOnboardingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color baseColor = widget.isSpeaking
        ? AppColors.accentYellow
        : widget.isListening
            ? AppColors.accentBlue
            : (isDark ? Colors.white24 : Colors.black12);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ripples
            if (widget.isListening || widget.isSpeaking)
              ...List.generate(3, (index) {
                final progress = (_controller.value + index / 3) % 1.0;
                return Opacity(
                  opacity: (1.0 - progress) * 0.4,
                  child: Container(
                    width: 140 + (progress * 120),
                    height: 140 + (progress * 120),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: baseColor, width: 2),
                    ),
                  ),
                );
              }),

            // Glassmorphic core
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    baseColor.withValues(alpha: 0.8),
                    baseColor.withValues(alpha:0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.1),
                    BlendMode.overlay,
                  ),
                  child: Center(
                    child: Icon(
                      widget.isSpeaking
                          ? Icons.spatial_audio_off_rounded
                          : widget.isListening
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded,
                      color: isDark ? Colors.white : Colors.black,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            
            // Subtle rotation glow
            Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      baseColor.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
