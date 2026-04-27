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
import '../../../features/settings/domain/entities/app_settings.dart';
import '../../../features/scanner/domain/entities/scanner_state.dart';
import '../../../features/scanner/presentation/providers/scanner_provider.dart';

final voiceCommandExecutorProvider = Provider<VoiceCommandExecutor>((ref) {
  return VoiceCommandExecutor(ref);
});

class VoiceCommandExecutor {
  VoiceCommandExecutor(this.ref);
  final Ref ref;

  /// Global navigator key to perform routing outside of widgets
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool execute(VoiceIntent intent) {
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
        return true;

      case PauseScanIntent():
        final cameraOpen = ref.read(cameraOpenProvider);
        if (cameraOpen) {
          ref.read(cameraOpenProvider.notifier).state = false;
          ref.read(scannerStateProvider.notifier).closeCamera();
          ref.read(cameraControllerProvider.notifier).closeCamera();
        }
        say(TtsMessage.navigation('Scanner paused', id: 'voice.paused'));
        return true;

      case ToggleFlashlightIntent():
        final next = intent.turnOn;
        if (next && settings.useFrontCamera) {
          say(TtsMessage.ambient(l10n.voiceFlashFrontError, id: 'voice.error.flash_front'));
          return false;
        }
        if (settings.useFlashlight != next) {
          settingsNotifier.toggleFlashlight(next);
          if (ref.read(cameraOpenProvider)) {
            ref.read(cameraControllerProvider.notifier).setFlash(next);
          }
        }
        say(SettingsSpeech.toggled(l10n, l10n.useFlashlight, next));
        return true;

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
        return true;

      case NavigateIntent():
        final context = navigatorKey.currentContext;
        if (context == null) return false;
        
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
            final ctx = navigatorKey.currentContext;
            if (ctx != null && ctx.mounted) {
              TutorialNavigator.push(ctx, TutorialRoute.voice);
            }
          });
        } else if (intent.target == NavTarget.home) {
          final scannerState = ref.read(scannerStateProvider);
          if (scannerState == ScannerState.result) {
            ref.read(scannerStateProvider.notifier).reset();
          }
          say(NavSpeech.returnedHome(l10n));
        }
        return true;

      case ExitAppIntent():
        say(TtsMessage.ambient('Closing Money Sense', id: 'voice.exit'));
        Future.delayed(const Duration(milliseconds: 500), () {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
        return true;

      case HelpIntent():
        final context = navigatorKey.currentContext;
        if (context != null) {
          final targetRoute = switch (intent.target) {
            HelpTarget.general => null,
            HelpTarget.inertial => TutorialRoute.inertialNavigation,
            HelpTarget.gestural => TutorialRoute.gesturalNavigation,
            HelpTarget.voice => TutorialRoute.voice,
            HelpTarget.scanning => TutorialRoute.denominationVibration,
          };

          if (targetRoute == null) {
            say(TtsMessage.navigation(l10n.navTutorial));
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TutorialScreen()),
            );
          } else {
            // Mapping for speech
            final title = switch (intent.target) {
              HelpTarget.inertial => l10n.tutorialCardInertialTitle,
              HelpTarget.gestural => l10n.tutorialCardGestureTitle,
              HelpTarget.voice => l10n.tutorialCardVoiceTitle,
              HelpTarget.scanning => l10n.tutorialCardDenomTitle,
              _ => l10n.navTutorial,
            };

            say(TtsMessage.navigation(title));
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TutorialScreen()),
            );
            Future.delayed(const Duration(milliseconds: 300), () {
              final ctx = navigatorKey.currentContext;
              if (ctx != null && ctx.mounted) {
                TutorialNavigator.push(ctx, targetRoute);
              }
            });
          }
        }
        return true;

      case StopSpeakingIntent():
        ref.read(ttsServiceProvider).stop();
        return true;

      case WakeIntent():
        // Handled directly by the voice_command_service to transition state.
        return true;

      case UnknownIntent():
        say(TtsMessage.ambient('Command not recognized', id: 'voice.unknown'));
        return false;

      case SkipIntent():
        // Skip is primarily handled locally in OnboardingScreen.
        // We just return success here so the executor doesn't complain.
        return true;

      case RetryIntent():
        final scannerState = ref.read(scannerStateProvider);
        if (scannerState == ScannerState.result) {
          ref.read(retryTriggerProvider.notifier).state++;
          say(TtsMessage.ambient('Retrying detection', id: 'voice.retry'));
          return true;
        }
        say(TtsMessage.ambient('I can only retry on the result screen', id: 'voice.retry_error'));
        return false;

      case IdentifyIntent():
        final cameraOpen = ref.read(cameraOpenProvider);
        if (!cameraOpen) {
          say(TtsMessage.ambient('Please start the scanner first', id: 'voice.error.not_scanning'));
          return false;
        }
        ref.read(scannerStateProvider.notifier).manualIdentify();
        return true;

      case StartVoiceSetupIntent():
      case SelectionIntent():
      case SelectionConfirmationIntent():
        // These are handled contextually by the Onboarding screen
        return true;

      case ChangeLanguageIntent():
        final lang = intent.language == 'tagalog' ? AppLanguage.tagalog : AppLanguage.english;
        settingsNotifier.setLanguage(lang);
        say(SettingsSpeech.changed(l10n, l10n.language, intent.language));
        return true;

      case ChangeThemeIntent():
        final theme = switch (intent.theme) {
          'dark' => AppThemeMode.dark,
          'light' => AppThemeMode.light,
          _ => AppThemeMode.system,
        };
        settingsNotifier.setThemeMode(theme);
        say(SettingsSpeech.changed(l10n, l10n.theme, intent.theme));
        return true;

      case ChangeFontSizeIntent():
        final scale = switch (intent.size) {
          'large' => 1.5,
          'small' => 0.8,
          _ => 1.0,
        };
        settingsNotifier.setFontScale(scale);
        say(SettingsSpeech.changed(l10n, l10n.fontSize, intent.size));
        return true;

      case ChangeSpeechRateIntent():
        final rate = switch (intent.rate) {
          'fast' => 1.5,
          'slow' => 0.8,
          _ => 1.05,
        };
        settingsNotifier.setSpeechRate(rate);
        say(SettingsSpeech.changed(l10n, l10n.speechRate, intent.rate));
        return true;

      case ChangeVerbosityIntent():
        final verbosity = switch (intent.level) {
          'full' => TextVerbosity.full,
          'minimal' => TextVerbosity.minimal,
          _ => TextVerbosity.standard,
        };
        settingsNotifier.setTextVerbosity(verbosity);
        say(SettingsSpeech.changed(l10n, l10n.textVerbosityTitle, intent.level));
        return true;

      case ChangeVisionProfileIntent():
        final profile = switch (intent.profile) {
          'lowVision' => VisionProfile.lowVision,
          'partiallyBlind' => VisionProfile.partiallyBlind,
          _ => VisionProfile.fullyBlind,
        };
        settingsNotifier.setVisionProfile(profile);
        return true;
    }
  }
}
