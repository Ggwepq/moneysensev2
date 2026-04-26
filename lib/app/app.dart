import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/shake_detector_widget.dart';
import '../core/services/tts_service.dart';
import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/scanner/presentation/screens/scanner_screen.dart'
    show routeObserverProvider;
import '../features/settings/domain/entities/vision_config.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import 'home_shell.dart';
import 'startup_splash.dart';
import '../core/services/voice/voice_command_executor.dart';
import '../core/services/voice/voice_command_service.dart';
import 'widgets/global_voice_overlay.dart';

class MoneySenseApp extends ConsumerWidget {
  const MoneySenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings      = ref.watch(appSettingsProvider);
    final visionConfig  = ref.watch(visionConfigProvider);
    final routeObserver = ref.read(routeObserverProvider);

    // ttsInitProvider stays here to re-init TTS on language or verbosity
    // changes mid-session. The first init is awaited by StartupSplash so
    // it is no longer fire-and-forget on launch.
    ref.watch(ttsInitProvider);

    final effectiveScale = visionConfig.effectiveFontScale(settings.fontScale);

    return Builder(
      builder: (outerCtx) {
        return MediaQuery(
          data: MediaQuery.of(outerCtx).copyWith(
            textScaler: TextScaler.linear(effectiveScale),
          ),
          child: MaterialApp(
            title: 'MoneySense',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.flutterThemeMode,
            navigatorKey: VoiceCommandExecutor.navigatorKey,
            navigatorObservers: [routeObserver],
            builder: (context, child) {
              return Stack(
                children: [
                  if (child != null) child,
                  const GlobalVoiceOverlay(),
                ],
              );
            },
            home: _AppRoot(),
          ),
        );
      },
    );
  }
}

class _AppRoot extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  bool _ttsReady        = false;
  bool _launchTutorial  = false;
  bool _passiveStarted  = false;

  @override
  void initState() {
    super.initState();
    // NOTE: Passive listening is intentionally NOT started here.
    // It starts in _onOnboardingComplete (after onboarding finishes) or
    // once the home shell is shown for users who already completed onboarding.
    // Starting it here would activate the microphone during onboarding,
    // which interferes with the onboarding voice flow.
  }

  void _onSplashReady() {
    setState(() => _ttsReady = true);
  }

  void _onOnboardingComplete({bool launchTutorial = false}) {
    _launchTutorial = launchTutorial;
    markOnboardingComplete(ref);
    
    // Explicitly start voice if enabled after onboarding
    final settings = ref.read(appSettingsProvider);
    if (settings.voiceNavigation) {
      ref.read(voiceCommandServiceProvider).startPassiveListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Block everything behind the splash until TTS is fully initialized.
    if (!_ttsReady) {
      return StartupSplash(onReady: _onSplashReady);
    }

    final onboardingDone = ref.watch(onboardingCompleteProvider);

    if (!onboardingDone) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
    }

    // Returning users: kick off passive listening once on first home build.
    if (!_passiveStarted) {
      _passiveStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final s = ref.read(appSettingsProvider);
        if (s.voiceNavigation) {
          ref.read(voiceCommandServiceProvider).startPassiveListening();
        }
      });
    }

    // Manage global voice lifecycle: start/stop when settings change
    ref.listen(appSettingsProvider, (previous, next) {
      final voiceNavChanged = previous?.voiceNavigation != next.voiceNavigation;
      final profileChanged = previous?.visionProfile != next.visionProfile;

      if (voiceNavChanged || profileChanged) {
        if (next.voiceNavigation) {
          ref.read(voiceCommandServiceProvider).startPassiveListening();
        } else {
          ref.read(voiceCommandServiceProvider).stopListening();
        }
      }
    });

    return ShakeDetectorWidget(
      child: HomeShell(launchTutorialOnLoad: _launchTutorial),
    );
  }
}
