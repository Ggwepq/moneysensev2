import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import 'voice_command_service.dart';

/// A globally floated overlay that animates into view when the voice listening is active.
/// It displays the interim recognized words to the user.
class VoiceCommandOverlay extends ConsumerWidget {
  const VoiceCommandOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(voiceCommandStatusProvider);
    final text = ref.watch(voiceCommandTextProvider);

    final bool isVisible = status == VoiceStatus.activeListening || 
                           status == VoiceStatus.processing ||
                           (status == VoiceStatus.passiveListening && text.isNotEmpty);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface.withValues(alpha: 0.9) : AppColors.lightSurface.withValues(alpha: 0.9);
    final textColor = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      top: isVisible ? 60.0 : -100.0,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isVisible ? 1.0 : 0.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentBlue, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(
                  status == VoiceStatus.processing ? Icons.hourglass_top_rounded : Icons.mic_rounded, 
                  color: AppColors.accentBlue,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text.isEmpty ? 'Listening...' : text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
