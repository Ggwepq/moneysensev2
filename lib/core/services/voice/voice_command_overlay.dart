import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../core/services/voice/voice_command_service.dart';
import '../../../features/settings/domain/entities/app_settings.dart';
import '../../l10n/app_localizations.dart';

/// A minimalist globally floated overlay that animates into view only when the voice engine is active.
/// Reverted to production UI: non-persistent, clean, and helpful.
class VoiceCommandOverlay extends ConsumerWidget {
  const VoiceCommandOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(voiceCommandStatusProvider);
    final text = ref.watch(voiceCommandTextProvider);
    final settings = ref.watch(appSettingsProvider);
    final l10n = AppLocalizations.of(settings.isTagalog);

    // Hide overlay if fully blind (BlindVoiceUi handles it)
    if (settings.visionProfile == VisionProfile.fullyBlind) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bool isPassive = status == VoiceStatus.passiveListening;

    final bgColor = isDark 
        ? AppColors.darkSurface.withValues(alpha: 0.95) 
        : AppColors.lightSurface.withValues(alpha: 0.95);
    final textColor = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;

    // Determine signal color and message
    Color accentColor = AppColors.accentBlue;
    String displayMessage = text;

    if (status == VoiceStatus.processing) {
      displayMessage = text.isNotEmpty ? text : l10n.voiceDetectedLabel;
      accentColor = Colors.green;
    } else if (isPassive && text.isEmpty) {
      displayMessage = '${l10n.voiceStatusStandingBy}\n(Say "Hey MS")';
      accentColor = accentColor.withValues(alpha: 0.4);
    } else if (text.isEmpty) {
      displayMessage = l10n.voiceListeningLabel;
    }

    final bool isVisible = status != VoiceStatus.idle && status != VoiceStatus.error;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      top: isVisible ? 50 : -200,
      left: 12,
      right: 12,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: isDark ? 0.7 : 0.8),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _PulseMic(color: accentColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVisible && status == VoiceStatus.passiveListening 
                              ? l10n.voiceStatusStandingBy 
                              : l10n.voiceListeningLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: accentColor.withValues(alpha: 0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayMessage.isNotEmpty ? displayMessage : '...',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 24),
                    onPressed: () => ref.read(voiceCommandServiceProvider).stopListening(),
                    color: textColor.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseMic extends StatefulWidget {
  final Color color;
  const _PulseMic({required this.color});

  @override
  State<_PulseMic> createState() => _PulseMicState();
}

class _PulseMicState extends State<_PulseMic> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.1 + (_controller.value * 0.1)),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.4 + (_controller.value * 0.4)),
              width: 2,
            ),
          ),
          child: Icon(Icons.mic_rounded, color: widget.color, size: 22),
        );
      },
    );
  }
}
