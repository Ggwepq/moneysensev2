import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voice_intent.dart';
import '../speech_scripts.dart';
import '../tts_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../features/settings/presentation/screens/simple_settings_screen.dart';
import '../../../features/tutorial/presentation/screens/tutorial_screen.dart';
import '../../../features/tutorial/presentation/screens/tutorial_navigator.dart';
import '../../../features/tutorial/domain/tutorial_route.dart';
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

      case PauseScanIntent():
        final cameraOpen = ref.read(cameraOpenProvider);
        if (cameraOpen) {
          ref.read(cameraOpenProvider.notifier).state = false;
          ref.read(scannerStateProvider.notifier).closeCamera();
          ref.read(cameraControllerProvider.notifier).closeCamera();
        }
        say(TtsMessage.navigation('Scanner paused', id: 'voice.paused'));
        break;

      case ToggleFlashlightIntent():
        final next = intent.turnOn;
        if (settings.useFlashlight != next) {
          settingsNotifier.toggleFlashlight(next);
          // Directly update the hardware camera if it is open
          if (ref.read(cameraOpenProvider)) {
            ref.read(cameraControllerProvider.notifier).setFlash(next);
          }
        }
        say(SettingsSpeech.toggled(l10n, l10n.useFlashlight, next));
        break;

      case ChangeCameraIntent():
        final toFront = intent.toFront;
        if (settings.useFrontCamera != toFront) {
          settingsNotifier.toggleFrontCamera(toFront);
          // Restart camera with new orientation if currently open
          if (ref.read(cameraOpenProvider)) {
             ref.read(cameraControllerProvider.notifier).closeCamera();
             ref.read(cameraControllerProvider.notifier).openCamera(
                useFrontCamera: toFront,
                useFlash: settings.useFlashlight,
             );
          }
        }
        say(SettingsSpeech.toggled(l10n, l10n.useFrontCamera, toFront));
        break;

      case NavigateIntent():
        final context = navigatorKey.currentContext;
        if (context == null) return;
        
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
        } else if (intent.target == NavTarget.commandList) {
          say(TtsMessage.navigation(l10n.tutorialCardVoiceTitle));
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TutorialScreen()),
          );
          Future.delayed(const Duration(milliseconds: 300), () {
            TutorialNavigator.push(context, TutorialRoute.voice);
          });
        } else if (intent.target == NavTarget.home) {
          say(NavSpeech.returnedHome(l10n));
        }
        break;

      case ExitAppIntent():
        say(TtsMessage.ambient('Closing Money Sense', id: 'voice.exit'));
        Future.delayed(const Duration(milliseconds: 500), () {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
        break;

      case HelpIntent():
        final context = navigatorKey.currentContext;
        if (context != null) {
          say(TtsMessage.navigation(l10n.navTutorial));
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TutorialScreen()),
          );
        }
        break;

      case WakeIntent():
        // Handled directly by the voice_command_service to transition state.
        break;

      case UnknownIntent():
        say(TtsMessage.ambient('Command not recognized', id: 'voice.unknown'));
        break;
    }
  }
}
