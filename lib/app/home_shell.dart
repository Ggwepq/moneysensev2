import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../features/scanner/presentation/providers/scanner_provider.dart';
import '../../features/scanner/presentation/screens/scanner_screen.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tutorial/presentation/screens/tutorial_screen.dart';
import '../../shared/widgets/ps_bottom_nav.dart';

/// Shell that hosts the three main tabs:
///   0 → Settings
///   1 → Scanner (home)
///   2 → Tutorial
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  // Start on Scanner tab (index 1)
  int _currentIndex = 1;

  final List<Widget> _screens = const [
    SettingsScreen(),
    _ScannerTab(),
    TutorialScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cameraOpen = ref.watch(cameraOpenProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: PsBottomNav(
        currentIndex: _currentIndex,
        isCameraOpen: cameraOpen,
        onTap: (index) {
          if (index == 1) {
            // Toggle camera
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
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}

// Wraps ScannerScreen so we can inject the navigate callback
class _ScannerTab extends ConsumerStatefulWidget {
  const _ScannerTab();

  @override
  ConsumerState<_ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends ConsumerState<_ScannerTab> {
  @override
  Widget build(BuildContext context) {
    return ScannerScreen(
      onNavigate: (index) {
        // Bubble up — requires access to parent state. Using a simple
        // provider-based approach here via a separate provider.
        ref.read(_shellIndexProvider.notifier).state = index;
      },
    );
  }
}

/// Mini provider just to allow child tabs to request a tab change.
final _shellIndexProvider = StateProvider<int>((ref) => 1);
