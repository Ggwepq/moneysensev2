import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_localizations.dart';
import '../core/services/inertial_detector_widget.dart';
import '../core/services/speech_scripts.dart';
import '../core/services/tts_service.dart';
import '../features/scanner/presentation/providers/scanner_provider.dart';
import '../features/scanner/presentation/screens/scanner_screen.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/tutorial/presentation/screens/tutorial_screen.dart';
import '../shared/widgets/ms_bottom_nav.dart';

/// Root shell. Owns the Scaffold, bottom nav, and inertial navigation sensor.
///
/// InertialDetectorWidget lives HERE (not in _AppRoot) so its RouteAware
/// subscription sees the same navigator stack as the Settings/Tutorial pushes.
/// When Settings is pushed from this level, didPushNext fires correctly
/// and the sensor pauses, preventing stray tilt callbacks while away.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {

  void _pushSettings() {
    _enqueue(NavSpeech.openedSettings(_l10n));
    Navigator.of(context).push(_slideFromLeft(const SettingsScreen()));
  }

  void _pushTutorial() {
    _enqueue(NavSpeech.openedTutorial(_l10n));
    Navigator.of(context).push(_slideFromRight(const TutorialScreen()));
  }

  void _enqueue(TtsMessage msg) {
    final s = ref.read(appSettingsProvider);
    ref.read(ttsServiceProvider).enqueue(
          msg,
          enabled: s.ttsEnabled,
          currentVerbosity: s.ttsVerbosity,
        );
  }

  AppLocalizations get _l10n =>
      AppLocalizations.of(ref.read(appSettingsProvider).isTagalog);

  void _toggleCamera() {
    final isOpen       = ref.read(cameraOpenProvider);
    final openNotifier = ref.read(cameraOpenProvider.notifier);
    final scanNotifier = ref.read(scannerStateProvider.notifier);
    final camNotifier  = ref.read(cameraControllerProvider.notifier);
    final settings     = ref.read(appSettingsProvider);

    if (isOpen) {
      openNotifier.state = false;
      scanNotifier.closeCamera();
      camNotifier.closeCamera();
    } else {
      openNotifier.state = true;
      scanNotifier.openCamera();
      camNotifier.openCamera(
        useFrontCamera: settings.useFrontCamera,
        useFlash: settings.useFlashlight,
      );
    }
  }

  PageRoute<void> _slideFromLeft(Widget page) => PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      );

  PageRoute<void> _slideFromRight(Widget page) => PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      );

  @override
  Widget build(BuildContext context) {
    final cameraOpen = ref.watch(cameraOpenProvider);

    return InertialDetectorWidget(
      onTiltLeft:  _pushTutorial,
      onTiltRight: _pushSettings,
      child: Scaffold(
        body: ScannerScreen(
          onNavigate: (index) {
            if (index == 0) _pushSettings();
            if (index == 2) _pushTutorial();
          },
        ),
        bottomNavigationBar: MsBottomNav(
          currentIndex: 1,
          isCameraOpen: cameraOpen,
          onTap: (index) {
            if (index == 0) {
              _pushSettings();
            } else if (index == 1) {
              _toggleCamera();
            } else if (index == 2) {
              _pushTutorial();
            }
          },
        ),
      ),
    );
  }
}
