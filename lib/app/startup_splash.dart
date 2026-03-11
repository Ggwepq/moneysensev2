import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/l10n/app_localizations.dart';
import '../core/services/earcon_service.dart';
import '../core/services/tts_service.dart';
import '../features/settings/presentation/providers/settings_provider.dart';

// Shown on every launch while TTS initializes.
// The app is fully usable the moment this screen disappears — no more
// queued audio playing over screens the user has already left.

enum _StartupPhase { loading, ready }

class StartupSplash extends ConsumerStatefulWidget {
  const StartupSplash({super.key, required this.onReady});

  /// Called once TTS (and any other async startup) is complete.
  final VoidCallback onReady;

  @override
  ConsumerState<StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends ConsumerState<StartupSplash>
    with SingleTickerProviderStateMixin {
  _StartupPhase _phase = _StartupPhase.loading;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulse = Tween(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _runStartup();
  }

  Future<void> _runStartup() async {
    final settings = ref.read(appSettingsProvider);

    // Await TTS initialization fully before proceeding.
    await TtsService.instance.init(
      language: settings.language,
      verbosity: settings.ttsVerbosity,
    );

    // Sync EarconService with persisted settings and TalkBack state.
    // TalkBack detection runs inside TTS init; we refresh earcon after so
    // both services share the same accessibility knowledge.
    EarconService.instance.setEnabled(settings.earconEnabled);
    await EarconService.instance.refreshTalkBackState();

    if (!mounted) return;
    setState(() => _phase = _StartupPhase.ready);

    // Earcon fires the instant "ready" is shown — while the checkmark is
    // visible and before the screen hands off. This gives audio confirmation
    // that startup completed without relying on TTS.
    EarconService.instance.play(EarconEvent.actionConfirmed);

    // Brief pause so "Ready" state is visible, then hand off.
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) widget.onReady();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final l10n = AppLocalizations.of(settings.isTagalog);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onBg = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final subtle = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final isReady = _phase == _StartupPhase.ready;
    final statusText = isReady
        ? l10n.splashReadyToScan
        : l10n.splashLoadingVoice;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo mark
              Image.asset(
                'assets/images/moneysense-favicon.png',
                width: 96,
                height: 96,
                semanticLabel: 'MoneySense',
              ),
              const SizedBox(height: 20),
              // Wordmark
              Text(
                'MoneySense',
                style: TextStyle(
                  color: onBg,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.splashGettingReady,
                style: TextStyle(
                  color: subtle,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 48),

              // Status indicator
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isReady
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('check'),
                        color: AppColors.accentYellow,
                        size: 32,
                      )
                    : FadeTransition(
                        key: const ValueKey('pulse'),
                        opacity: _pulse,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.accentBlue,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Status label
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  statusText,
                  key: ValueKey(statusText),
                  style: TextStyle(
                    color: isReady ? AppColors.accentYellow : subtle,
                    fontSize: 13,
                    fontWeight: isReady ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
