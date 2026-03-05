import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/scanner/presentation/providers/scanner_provider.dart';
import '../../features/scanner/presentation/screens/scanner_screen.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tutorial/presentation/screens/tutorial_screen.dart';
import '../../shared/widgets/ps_bottom_nav.dart';

/// Root shell — owns the single [Scaffold].
///
/// The scanner body fills all space above [PsBottomNav].
/// Settings and Tutorial are pushed as separate routes so:
///   • Bottom nav absent on all non-home screens.
///   • Back button and swipe-back work natively on those screens.
///   • Camera intent is preserved during navigation.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraOpen = ref.watch(cameraOpenProvider);

    return Scaffold(
      body: ScannerScreen(
        onNavigate: (index) {
          if (index == 0) _pushSettings(context);
          if (index == 2) _pushTutorial(context);
        },
      ),
      bottomNavigationBar: PsBottomNav(
        currentIndex: 1,
        isCameraOpen: cameraOpen,
        onTap: (index) {
          if (index == 0) {
            _pushSettings(context);
          } else if (index == 1) {
            _toggleCamera(ref);
          } else if (index == 2) {
            _pushTutorial(context);
          }
        },
      ),
    );
  }

  // ── Camera toggle ──────────────────────────────────────────────────────────

  void _toggleCamera(WidgetRef ref) {
    final isOpen = ref.read(cameraOpenProvider);
    final openNotifier = ref.read(cameraOpenProvider.notifier);
    final scanNotifier = ref.read(scannerStateProvider.notifier);
    final camNotifier = ref.read(cameraControllerProvider.notifier);
    final settings = ref.read(appSettingsProvider);

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

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _pushSettings(BuildContext context) {
    Navigator.of(context).push(_slideFromLeft(const SettingsScreen()));
  }

  void _pushTutorial(BuildContext context) {
    Navigator.of(context).push(_slideFromRight(const TutorialScreen()));
  }

  /// Settings slides in from the left (swipe-right gesture revealed it).
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

  /// Tutorial slides in from the right (swipe-left gesture revealed it).
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
