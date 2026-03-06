import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/shake_detector_widget.dart';
import '../core/theme/app_theme.dart';
import '../features/scanner/presentation/screens/scanner_screen.dart'
    show routeObserverProvider;
import '../features/settings/presentation/providers/settings_provider.dart';
import 'home_shell.dart';

class MoneySenseApp extends ConsumerWidget {
  const MoneySenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final routeObserver = ref.read(routeObserverProvider);

    return Builder(
      builder: (outerCtx) {
        // WCAG 1.4.4 — honour the user's font scale (0.8–2.0).
        // The outer MediaQuery supplies the physical screen dimensions;
        // we override only textScaler.
        return MediaQuery(
          data: MediaQuery.of(outerCtx).copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: MaterialApp(
            title: 'MoneySense',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.flutterThemeMode,
            navigatorObservers: [routeObserver],
            // ShakeDetectorWidget wraps the home widget so it has access to
            // the Navigator context.  It starts/stops the accelerometer based
            // on the shakeToGoBack setting and handles app lifecycle events.
            home: ShakeDetectorWidget(
              child: const HomeShell(),
            ),
          ),
        );
      },
    );
  }
}
