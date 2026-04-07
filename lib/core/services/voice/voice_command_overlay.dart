import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../features/settings/domain/entities/app_settings.dart';
import '../../l10n/app_localizations.dart';
import 'voice_command_service.dart';

/// A globally floated overlay that animates into view when the voice listening is active.
/// It displays the interim recognized words to the user.
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

    // Always visible in some form if voice navigation is on, to provide "visual cues"
    // However, we only show the floating bar if we're actually listening or processing.
    // Passive listening with NO text captured yet shows a very minimalist status.
    // Visibility logic: Active sessions or processing keep the panel "Open"
    final bool isActiveSession = status == VoiceStatus.activeListening || status == VoiceStatus.processing;
    final bool isVisible = status != VoiceStatus.idle && status != VoiceStatus.error;
    
    // Panel stays "active until deactivated" by user or command completion.
    // We'll make it stickier and more prominent.
    final bool isPassive = status == VoiceStatus.passiveListening;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceOpacity = (isPassive && text.isEmpty) ? 0.6 : 1.0;
    final surfaceColor = isDark 
        ? AppColors.darkSurface.withValues(alpha: surfaceOpacity) 
        : AppColors.lightSurface.withValues(alpha: surfaceOpacity);
    final textColor = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;

    // Determine message and icon
    String displayMessage = text;
    IconData displayIcon = Icons.mic_rounded;
    Color iconColor = AppColors.accentBlue;

    if (status == VoiceStatus.processing) {
      displayMessage = text.isNotEmpty ? text : l10n.voiceDetectedLabel;
      displayIcon = Icons.check_circle_rounded;
      iconColor = Colors.green;
    } else if (isPassive && text.isEmpty) {
      displayMessage = l10n.voiceStatusStandingBy;
      displayIcon = Icons.mic_none_rounded;
      iconColor = iconColor.withValues(alpha: 0.4);
    } else if (text.isEmpty) {
      displayMessage = l10n.voiceListeningLabel;
    }

    // Panel Position: Slide from top, more substantial presence
    final double targetTop = isVisible ? (isActiveSession ? 80.0 : 50.0) : -150.0;
    final double targetOpacity = isVisible ? 1.0 : 0.0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut, // Snappy entry
      top: targetTop,
      left: 12,
      right: 12,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: targetOpacity,
        child: Material(
          elevation: isActiveSession ? 12 : 4,
          borderRadius: BorderRadius.circular(24),
          color: surfaceColor,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isActiveSession ? iconColor : Colors.transparent, 
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Activity Indicator
                _PulseIndicator(
                  isActive: isActiveSession,
                  child: Icon(displayIcon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                
                // Transcription Area
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isActiveSession)
                        Text(
                          l10n.voiceListeningLabel.toUpperCase(),
                          style: TextStyle(
                            color: iconColor.withValues(alpha: 0.7),
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      Text(
                        displayMessage,
                        maxLines: 3,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Manual Deactivate Button
                if (isActiveSession)
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      ref.read(voiceCommandServiceProvider).stopListening();
                      // Restart passive listening if navigation is still ON
                      if (settings.voiceNavigation) {
                         ref.read(voiceCommandServiceProvider).startPassiveListening();
                      }
                    },
                    color: textColor.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  const _PulseIndicator({required this.isActive, required this.child});
  final bool isActive;
  final Widget child;

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isActive) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulseIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.isActive 
          ? Tween(begin: 1.0, end: 1.15).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            )
          : const AlwaysStoppedAnimation(1.0),
      child: widget.child,
    );
  }
}
