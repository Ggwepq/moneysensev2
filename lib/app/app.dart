import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/scanner/presentation/screens/scanner_screen.dart'
    show routeObserverProvider;
import '../features/settings/presentation/providers/settings_provider.dart';
import 'home_shell.dart';

class PesoSenseApp extends ConsumerWidget {
  const PesoSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final routeObserver = ref.read(routeObserverProvider);

    // WCAG 1.4.4 — text must be resizable up to 200% without loss of content.
    // We honour the user's chosen scale (0.8–2.0) and clamp system scale to
    // a minimum of 0.85 so text never becomes unreadably tiny.
    final effectiveScale = settings.fontScale;

    return Builder(
      builder: (outerCtx) {
        return MediaQuery(
          data: MediaQuery.of(
            outerCtx,
          ).copyWith(textScaler: TextScaler.linear(effectiveScale)),
          child: MaterialApp(
            title: 'PesoSense',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.flutterThemeMode,
            navigatorObservers: [routeObserver],
            home: const HomeShell(),
          ),
        );
      },
    );
  }
}
