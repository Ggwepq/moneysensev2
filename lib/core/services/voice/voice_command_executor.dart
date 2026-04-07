import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voice_intent.dart';
import '../speech_scripts.dart';
import '../tts_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../features/settings/presentation/screens/simple_settings_screen.dart';
import '../../../features/tutorial/presentation/screens/tutorial_screen.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../features/scanner/presentation/providers/scanner_provider.dart';

final voiceCommandExecutorProvider = Provider<VoiceCommandExecutor>((ref) {
  return VoiceCommandExecutor(ref);
});

class VoiceCommandExecutor {
  VoiceCommandExecutor(this.ref);
  final Ref ref;

  /// Global navigator key to perform routing outside of widgets
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void execute(VoiceIntent intent) {
    final settings = ref.read(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    final l10n = AppLocalizations.of(settings.isTagalog);
    final tts = ref.read(ttsServiceProvider);

    void say(TtsMessage msg) {
      tts.enqueue(
        msg,
        enabled: settings.ttsEnabled,
        currentVerbosity: settings.ttsVerbosity,
      );
    }

    switch (intent) {
      case ScanIntent():
        final cameraOpen = ref.read(cameraOpenProvider);
        if (!cameraOpen) {
          ref.read(cameraOpenProvider.notifier).state = true;
          ref.read(scannerStateProvider.notifier).openCamera();
          ref.read(cameraControllerProvider.notifier).openCamera(
            useFrontCamera: settings.useFrontCamera,
            useFlash: settings.useFlashlight,
          );
        }
        say(NavSpeech.returnedHome(l10n));
        break;

      case ToggleFlashlightIntent():
        final next = intent.turnOn;
        if (settings.useFlashlight != next) {
          settingsNotifier.toggleFlashlight(next);
        }
        say(SettingsSpeech.toggled(l10n, l10n.useFlashlight, next));
        break;

      case ChangeCameraIntent():
        final toFront = intent.toFront;
        if (settings.useFrontCamera != toFront) {
          settingsNotifier.toggleFrontCamera(toFront);
        }
        say(SettingsSpeech.toggled(l10n, l10n.useFrontCamera, toFront));
        break;

      case NavigateIntent():
        // We use the global navigator key to push/pop
        final context = navigatorKey.currentContext;
        if (context == null) return;
        
        // Pop all dialogues or nested routes safely back to Home shell
        Navigator.of(context).popUntil((route) => route.isFirst);

        if (intent.target == NavTarget.settings) {
          say(NavSpeech.openedSettings(l10n));
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SimpleSettingsScreen()),
          );
        } else if (intent.target == NavTarget.tutorial) {
          say(NavSpeech.openedTutorial(l10n));
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TutorialScreen()),
          );
        } else if (intent.target == NavTarget.home) {
          say(NavSpeech.returnedHome(l10n));
        }
        break;

      case UnknownIntent():
        // In fully blind contexts, it's often better to slightly nudge or ignore.
        // We will just do a small error chime or say "Command not recognized".
        say(TtsMessage.ambient('Command not recognized', id: 'voice.unknown'));
        break;
    }
  }
}
