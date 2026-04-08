import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../features/settings/domain/entities/app_settings.dart';
import '../../l10n/app_localizations.dart';
import 'voice_command_service.dart';

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

    // Hide overlay if fully blind (BlindVoiceUi handles it) or voice navigation is off
    if (settings.visionProfile == VisionProfile.fullyBlind || !settings.voiceNavigation) {
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

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      top: 60, // Visible at top
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(24),
        color: bgColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              _PulseMic(color: accentColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  displayMessage,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => ref.read(voiceCommandServiceProvider).stopListening(),
                color: textColor.withValues(alpha: 0.4),
              ),
            ],
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
