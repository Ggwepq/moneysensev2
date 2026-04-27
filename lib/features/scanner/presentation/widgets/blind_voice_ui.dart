import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/voice/voice_command_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../onboarding/presentation/widgets/voice_onboarding_orb.dart';

/// A heavily optimised, minimal-touch UI for fully blind users.
/// Replaces standard menus with a massive, high-contrast, fully tappable layout.
///
/// Tap gesture logic:
///   • Single tap  → start active listening (or stop if already active)
///   • Debounce 500 ms between taps to prevent accidental double-fires.
///
/// After a command is executed the service automatically restores passive
/// (wake-word) listening, so the orb always reflects the correct state.
class BlindVoiceUi extends ConsumerStatefulWidget {
  const BlindVoiceUi({super.key});

  @override
  ConsumerState<BlindVoiceUi> createState() => _BlindVoiceUiState();
}

class _BlindVoiceUiState extends ConsumerState<BlindVoiceUi> {
  /// Timestamp of the last accepted tap — prevents rapid-fire activations.
  DateTime _lastAcceptedTap = DateTime.fromMillisecondsSinceEpoch(0);

  void _handleTap() {
    final now = DateTime.now();
    if (now.difference(_lastAcceptedTap).inMilliseconds < 500) return;
    _lastAcceptedTap = now;

    final status = ref.read(voiceCommandStatusProvider);
    final service = ref.read(voiceCommandServiceProvider);

    HapticFeedback.mediumImpact();

    if (status == VoiceStatus.activeListening || status == VoiceStatus.processing) {
      // User wants to RESTART or interrupt.
      service.startActiveListening(withPrompt: false);
    } else {
      // Open active listening (with prompt).
      service.startActiveListening(withPrompt: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status   = ref.watch(voiceCommandStatusProvider);
    final text     = ref.watch(voiceCommandTextProvider);
    final settings = ref.watch(appSettingsProvider);
    final l10n     = AppLocalizations.of(settings.isTagalog);
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    // Orb reflects active AND passive listening so the user always knows
    // the mic is open and waiting for them.
    final micOpen = status == VoiceStatus.activeListening ||
        status == VoiceStatus.passiveListening;
    final isProcessing = status == VoiceStatus.processing;

    String statusLabel;
    if (isProcessing) {
      statusLabel = l10n.voiceDetectedLabel;
    } else if (text.isNotEmpty && status == VoiceStatus.activeListening) {
      statusLabel = text;
    } else {
      switch (status) {
        case VoiceStatus.activeListening:
          statusLabel = l10n.voiceListeningLabel;
        case VoiceStatus.passiveListening:
          statusLabel = l10n.voiceStatusStandingBy;
        case VoiceStatus.error:
          statusLabel = 'Microphone error — tap to retry';
        default:
          statusLabel = l10n.blindTapToSpeak;
      }
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent overlay behind the camera stream.
          Positioned.fill(
            child: Container(
              color: (isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground)
                  .withValues(alpha: 0.55),
            ),
          ),

          // Full-screen gesture target.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleTap,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Orb pulses when the mic is open (active or passive).
                      VoiceOnboardingOrb(
                        isListening: micOpen,
                        isSpeaking: isProcessing,
                      ),

                      const SizedBox(height: 80),

                      Text(
                        statusLabel,
                        key: ValueKey(statusLabel),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          height: 1.2,
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
