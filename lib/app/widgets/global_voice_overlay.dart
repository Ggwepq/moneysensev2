import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/voice/voice_command_overlay.dart';
import '../../../features/scanner/presentation/widgets/blind_voice_ui.dart';
import '../../../features/settings/domain/entities/app_settings.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../core/services/voice/voice_command_service.dart';

/// A global wrapper that displays the appropriate voice UI (Overlay or Blind UI)
/// over the entire application.
class GlobalVoiceOverlay extends ConsumerWidget {
  const GlobalVoiceOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final isFullyBlind = settings.visionProfile == VisionProfile.fullyBlind;

    final status = ref.watch(voiceCommandStatusProvider);
    final isVisible = status != VoiceStatus.idle && status != VoiceStatus.error;

    return IgnorePointer(
      ignoring: !isVisible && !isFullyBlind,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isFullyBlind)
            const BlindVoiceUi()
          else
            const VoiceCommandOverlay(),
        ],
      ),
    );
  }
}
