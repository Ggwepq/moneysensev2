import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/scanner_state.dart';
import '../providers/scanner_provider.dart';
import '../widgets/camera_viewfinder.dart';

/// Main scanner / home screen.
///
/// Gesture handling (when [gesturalNavigation] is enabled):
///   swipe left  → Settings
///   swipe right → Tutorial
///   swipe up    → Toggle flash
///   double-tap  → Force scan
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({
    super.key,
    required this.onNavigate,
  });

  /// Called with index 0=settings, 2=tutorial.
  final ValueChanged<int> onNavigate;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  static const double _swipeThreshold = 80.0;
  Offset? _dragStart;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final scannerState = ref.watch(scannerStateProvider);
    final cameraOpen = ref.watch(cameraOpenProvider);
    final l10n = AppLocalizations.of(settings.isTagalog);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String? statusLabel;
    if (scannerState == ScannerState.scanning) {
      statusLabel = l10n.scanning;
    } else if (scannerState == ScannerState.processing) {
      statusLabel = l10n.processing;
    }

    return GestureDetector(
      onTap: () {
        // No-op: double tap is handled by onDoubleTap
      },
      onDoubleTap: settings.gesturalNavigation
          ? () => _handleDoubleTap()
          : null,
      onPanStart: settings.gesturalNavigation
          ? (d) => _dragStart = d.globalPosition
          : null,
      onPanEnd: settings.gesturalNavigation
          ? (d) => _handleSwipe(d.velocity.pixelsPerSecond)
          : null,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: CameraViewfinder(
              scannerState: cameraOpen ? scannerState : ScannerState.idle,
              isDark: isDark,
              statusLabel: statusLabel,
              child: cameraOpen
                  ? _CameraPreviewPlaceholder(isDark: isDark)
                  : _IdlePlaceholder(l10n: l10n, isDark: isDark),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    final scannerNotifier = ref.read(scannerStateProvider.notifier);
    final state = ref.read(scannerStateProvider);
    if (state == ScannerState.previewing) {
      scannerNotifier.startScanning();
      // Simulate processing after 2s (replace with real ML pipeline)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          scannerNotifier.startProcessing();
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) scannerNotifier.showResult();
          });
        }
      });
    }
  }

  void _handleSwipe(Offset velocity) {
    if (velocity.dx.abs() > _swipeThreshold) {
      if (velocity.dx < 0) {
        widget.onNavigate(0); // left → settings
      } else {
        widget.onNavigate(2); // right → tutorial
      }
    } else if (velocity.dy < -_swipeThreshold) {
      // Swipe up → toggle flash
      final notifier = ref.read(appSettingsProvider.notifier);
      final current = ref.read(appSettingsProvider).useFlashlight;
      notifier.toggleFlashlight(!current);
    }
  }
}

// ── Placeholders ─────────────────────────────────────────────────────────────

class _IdlePlaceholder extends StatelessWidget {
  const _IdlePlaceholder({required this.l10n, required this.isDark});
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        l10n.tapToScan,
        style: TextStyle(
          color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA),
          fontSize: 14,
        ),
      ),
    );
  }
}

class _CameraPreviewPlaceholder extends StatelessWidget {
  const _CameraPreviewPlaceholder({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Replace with actual CameraPreview widget when wiring up camera package
    return Container(
      color: isDark ? Colors.black : const Color(0xFFEEEEEE),
      child: Center(
        child: Icon(
          Icons.camera_alt_outlined,
          size: 64,
          color: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
        ),
      ),
    );
  }
}
