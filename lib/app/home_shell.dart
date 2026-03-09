import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_localizations.dart';
import '../core/services/speech_scripts.dart';
import '../core/services/tts_service.dart';
import '../features/scanner/presentation/providers/scanner_provider.dart';
import '../features/scanner/presentation/screens/scanner_screen.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/tutorial/presentation/screens/tutorial_screen.dart';
import '../shared/widgets/ms_bottom_nav.dart';

/// Root shell — owns the single [Scaffold].
///
/// Navigation TTS: each push/pop announces the destination so blind users
/// always know where they are without needing TalkBack to read the AppBar.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraOpen = ref.watch(cameraOpenProvider);

    return Scaffold(
      body: ScannerScreen(
        onNavigate: (index) {
          if (index == 0) _pushSettings(context, ref);
          if (index == 2) _pushTutorial(context, ref);
        },
      ),
      bottomNavigationBar: MsBottomNav(
        currentIndex: 1,
        isCameraOpen: cameraOpen,
        onTap: (index) {
          if (index == 0) {
            _pushSettings(context, ref);
          } else if (index == 1) {
            _toggleCamera(ref);
          } else if (index == 2) {
            _pushTutorial(context, ref);
          }
        },
      ),
    );
  }

  // ── TTS helper ─────────────────────────────────────────────────────────────

  void _enqueue(WidgetRef ref, TtsMessage msg) {
    final s = ref.read(appSettingsProvider);
    ref.read(ttsServiceProvider).enqueue(
          msg,
          enabled: s.ttsEnabled,
          currentVerbosity: s.ttsVerbosity,
        );
  }

  AppLocalizations _l10n(WidgetRef ref) =>
      AppLocalizations.of(ref.read(appSettingsProvider).isTagalog);

  // ── Camera toggle ──────────────────────────────────────────────────────────

  void _toggleCamera(WidgetRef ref) {
    final isOpen     = ref.read(cameraOpenProvider);
    final openNotifier = ref.read(cameraOpenProvider.notifier);
    final scanNotifier = ref.read(scannerStateProvider.notifier);
    final camNotifier  = ref.read(cameraControllerProvider.notifier);
    final settings   = ref.read(appSettingsProvider);

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
    // Camera open/close TTS is handled by scanner_screen's ref.listen
    // on cameraOpenProvider — no double-announce here.
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _pushSettings(BuildContext context, WidgetRef ref) {
    _enqueue(ref, NavSpeech.openedSettings(_l10n(ref)));
    Navigator.of(context).push(_slideFromLeft(const SettingsScreen()));
  }

  void _pushTutorial(BuildContext context, WidgetRef ref) {
    _enqueue(ref, NavSpeech.openedTutorial(_l10n(ref)));
    Navigator.of(context).push(_slideFromRight(const TutorialScreen()));
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
}
