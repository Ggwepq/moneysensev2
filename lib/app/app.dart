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
            navigatorObservers: [routeObserver],
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
  bool _ttsReady       = false;
  bool _launchTutorial = false;

  void _onSplashReady() {
    setState(() => _ttsReady = true);
  }

  void _onOnboardingComplete({bool launchTutorial = false}) {
    _launchTutorial = launchTutorial;
    markOnboardingComplete(ref);
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

    // ShakeDetectorWidget is app-level so shake-to-go-back works everywhere.
    // InertialDetectorWidget lives inside HomeShell so its RouteAware
    // subscription correctly sees Settings/Tutorial pushes.
    return ShakeDetectorWidget(
      child: HomeShell(launchTutorialOnLoad: _launchTutorial),
    );
  }
}
