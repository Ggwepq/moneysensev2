import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/scanner/presentation/providers/scanner_provider.dart';
import '../../features/scanner/presentation/screens/scanner_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tutorial/presentation/screens/tutorial_screen.dart';
import '../../shared/widgets/ps_bottom_nav.dart';

/// Home shell — owns the single root [Scaffold].
///
/// Structure:
///   Scaffold
///   ├── body: ScannerScreen  (fills all space above the nav bar)
///   └── bottomNavigationBar: PsBottomNav
///
/// Settings and Tutorial are pushed onto the Navigator stack so:
///   • The bottom nav only ever appears on the scanner / home screen.
///   • The AppBar back button on pushed screens works automatically.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraOpen = ref.watch(cameraOpenProvider);

    return Scaffold(
      // The scanner screen fills the entire body space above the nav bar.
      // It has no inner Scaffold — it renders directly into this body.
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
            final notifier = ref.read(cameraOpenProvider.notifier);
            final scanNotifier = ref.read(scannerStateProvider.notifier);
            final isOpen = ref.read(cameraOpenProvider);
            if (isOpen) {
              notifier.state = false;
              scanNotifier.closeCamera();
            } else {
              notifier.state = true;
              scanNotifier.openCamera();
            }
          } else if (index == 2) {
            _pushTutorial(context);
          }
        },
      ),
    );
  }

  void _pushSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  void _pushTutorial(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const TutorialScreen()));
  }
}
