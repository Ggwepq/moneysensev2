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
/// Layout (top to bottom):
///   ┌─────────────────────────────┐
///   │                             │
///   │   CameraViewfinder (flex)   │
///   │                             │
///   └─────────────────────────────┘
///
/// The bottom navigation bar lives in [HomeShell]'s Scaffold so it is
/// never part of this widget tree. This screen only owns the viewfinder body.
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

  final ValueChanged<int> onNavigate;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
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
      onDoubleTap: settings.gesturalNavigation ? _handleDoubleTap : null,
      onPanEnd: settings.gesturalNavigation
          ? (d) => _handleSwipe(d.velocity.pixelsPerSecond)
          : null,
      // SafeArea is handled by HomeShell's Scaffold, but we add top here
      // so the viewfinder doesn't bleed under the status bar.
      child: SafeArea(
        bottom: false, // bottom safe area is handled by HomeShell + PsBottomNav
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.base,
          ),
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
    );
  }

  void _handleDoubleTap() {
    final scannerNotifier = ref.read(scannerStateProvider.notifier);
    final state = ref.read(scannerStateProvider);
    if (state == ScannerState.previewing) {
      scannerNotifier.startScanning();
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
    const threshold = 300.0;
    if (velocity.dx.abs() > threshold) {
      if (velocity.dx < 0) {
        widget.onNavigate(0); // swipe left → settings
      } else {
        widget.onNavigate(2); // swipe right → tutorial
      }
    } else if (velocity.dy < -threshold) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.currency_exchange_rounded,
            size: 56,
            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tapToScan,
            style: TextStyle(
              color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPreviewPlaceholder extends StatelessWidget {
  const _CameraPreviewPlaceholder({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Replace with actual CameraPreview widget from the camera package.
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
