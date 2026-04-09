import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/voice/voice_command_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../settings/domain/entities/vision_config.dart';
import '../../../settings/domain/entities/app_settings.dart';

/// A heavily optimized, minimal-touch UI for fully blind users.
/// Replaces standard menus with a massive, high-contrast, fully tappable layout.
class BlindVoiceUi extends ConsumerStatefulWidget {
  const BlindVoiceUi({super.key});

  @override
  ConsumerState<BlindVoiceUi> createState() => _BlindVoiceUiState();
}

class _BlindVoiceUiState extends ConsumerState<BlindVoiceUi> {
  DateTime _lastTap = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(voiceCommandStatusProvider);
    final text = ref.watch(voiceCommandTextProvider);
    final settings = ref.watch(appSettingsProvider);
    final l10n = AppLocalizations.of(settings.isTagalog);
    
    final cfg = VisionConfig.from(VisionProfile.fullyBlind);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final accent = cfg.accent(isDark);
    final accentFg = cfg.accentForeground(isDark);
    final isListening = status == VoiceStatus.activeListening || 
                        status == VoiceStatus.processing ||
                        status == VoiceStatus.passiveListening;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark background over the active camera stream (removed blur for performance)
          Positioned.fill(
            child: Container(
              color: (isDark ? AppColors.darkBackground : AppColors.lightBackground)
                  .withValues(alpha: 0.5),
            ),
          ),
  
          // Massive Gesture Target
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.opaque, // Entire screen captures touches
              onPointerDown: (_) {
                 final now = DateTime.now();
                 if (now.difference(_lastTap).inMilliseconds < 500) return;
                 _lastTap = now;
  
                 if (status == VoiceStatus.activeListening) {
                   ref.read(voiceCommandServiceProvider).stopListening();
                 } else {
                   ref.read(voiceCommandServiceProvider).startActiveListening(withPrompt: true);
                 }
              },
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glow animation if listening
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        width: isListening ? 220 : 160,
                        height: isListening ? 220 : 160,
                        decoration: BoxDecoration(
                          color: isListening ? accent : accent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: isListening ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.6),
                              blurRadius: 40,
                              spreadRadius: 20,
                            )
                          ] : [],
                        ),
                        child: Icon(
                          isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          size: isListening ? 100 : 80,
                          color: isListening ? accentFg : accent,
                        ),
                      ),
  
                      const SizedBox(height: 60),
  
                      Text(
                        status == VoiceStatus.processing
                            ? l10n.voiceDetectedLabel
                            : (text.isNotEmpty
                                ? text
                                : (status == VoiceStatus.passiveListening
                                    ? l10n.voiceStatusStandingBy
                                    : (status == VoiceStatus.activeListening
                                        ? l10n.voiceListeningLabel
                                        : l10n.blindTapToSpeak))),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
  
                      const SizedBox(height: 16),
  
                      Text(
                        l10n.voiceTryItHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
