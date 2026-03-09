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

class MoneySenseApp extends ConsumerWidget {
  const MoneySenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings      = ref.watch(appSettingsProvider);
    final visionConfig  = ref.watch(visionConfigProvider);
    final routeObserver = ref.read(routeObserverProvider);
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
  @override
  Widget build(BuildContext context) {
    final onboardingDone = ref.watch(onboardingCompleteProvider);

    if (!onboardingDone) {
      return OnboardingScreen(
        onComplete: () => markOnboardingComplete(ref),
      );
    }

    // ShakeDetectorWidget is app-level (shake to go back works from anywhere).
    // InertialDetectorWidget is inside HomeShell so its RouteAware subscription
    // correctly sees Settings/Tutorial pushes.
    return const ShakeDetectorWidget(
      child: HomeShell(),
    );
  }
}
