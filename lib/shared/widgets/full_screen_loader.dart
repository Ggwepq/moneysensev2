import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../features/settings/domain/entities/vision_config.dart';

/// Full-screen blocking overlay shown during long async operations.
///
/// BEHAVIOUR
///   Covers the entire screen (including status bar) with a semi-opaque
///   scrim so the content behind is dimmed but still visible.
///   All pointer input is absorbed — taps, swipes, and back gestures are
///   all blocked until [FullScreenLoader.hide] is called.
///
/// USAGE (language change example)
///   FullScreenLoader.show(context, message: 'Changing audio to Filipino...');
///   await tts.changeLanguage(...);
///   FullScreenLoader.hide(context);
///
/// The caller is responsible for calling hide() exactly once after show().

class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({super.key, required this.message});

  final String message;

  // ── Static show / hide ────────────────────────────────────────────────────

  static OverlayEntry? _entry;

  static void show(BuildContext context, {required String message}) {
    if (_entry != null) return; // already showing
    _entry = OverlayEntry(
      builder: (_) => FullScreenLoader(message: message),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  static void hide(BuildContext context) {
    _entry?.remove();
    _entry = null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final fg     = isDark ? AppColors.darkOnSurface   : AppColors.lightOnSurface;
    final cfg    = ProviderScope.containerOf(context, listen: false)
        .read(visionConfigProvider);
    final accent = cfg.accent(isDark);

    return PopScope(
      canPop: false, // block Android back button
      child: IgnorePointer(
        ignoring: false, // we DO want to capture (and swallow) all events
        child: AbsorbPointer(
          child: Semantics(
            label: message,
            liveRegion: true,
            child: Material(
              color: bg.withValues(alpha: 0.92),
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App icon stand-in
                        Icon(
                          Icons.currency_exchange_rounded,
                          size: 56,
                          color: accent,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Spinner
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Status message
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: fg,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
