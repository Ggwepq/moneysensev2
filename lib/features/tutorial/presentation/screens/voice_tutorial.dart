import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/speech_scripts.dart';
import '../../../../core/services/tts_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/domain/entities/vision_config.dart';
import '../../../../core/services/voice/voice_command_service.dart';
import '../widgets/ms_tutorial_scaffold.dart';

class VoiceTutorial extends ConsumerStatefulWidget {
  const VoiceTutorial({super.key});

  @override
  ConsumerState<VoiceTutorial> createState() => _VoiceTutorialState();
}

class _VoiceTutorialState extends ConsumerState<VoiceTutorial> {
  String? _lastCaptured;
  bool _isListening = false;
  bool _wakeWordDetected = false;

  @override
  void initState() {
    super.initState();
    
    // Speak the guide after a short delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final s = ref.read(appSettingsProvider);
      final l10n = AppLocalizations.of(s.isTagalog);
      ref.read(ttsServiceProvider).enqueue(
        TutorialSpeech.voiceGuide(l10n),
        enabled: s.ttsEnabled,
        currentVerbosity: s.ttsVerbosity,
      );
    });

    _listenToVoice();
  }

  void _listenToVoice() {
    // Listen to status
    ref.listenManual(voiceCommandStatusProvider, (prev, next) {
      if (!mounted) return;
      setState(() {
        _isListening = next == VoiceStatus.activeListening || next == VoiceStatus.passiveListening;
        _wakeWordDetected = next == VoiceStatus.processing;
      });
    });

    // Listen to recognized text
    ref.listenManual(voiceCommandTextProvider, (prev, next) {
      if (!mounted) return;
      setState(() {
        final text = next;
        _lastCaptured = text.isEmpty ? _lastCaptured : text;
      });
    });
  }

  @override
  void dispose() {
    ref.read(voiceCommandServiceProvider).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg = ref.watch(visionConfigProvider);
    final accent = cfg.accentBlue;
    final s = ref.watch(appSettingsProvider);
    final l10n = AppLocalizations.of(s.isTagalog);

    return MsTutorialScaffold(
      title: l10n.tutorialCardVoiceTitle,
      badge: l10n.voiceTutorialBadge,
      description: l10n.voiceTutorialDescription,
      steps: [
        l10n.voiceTutorialStep1,
        l10n.voiceTutorialStep2,
        l10n.voiceTutorialStep3,
        l10n.voiceTutorialStep4,
      ],
      heroSemantic: l10n.voiceHeroSemantic,
      interactiveSemantic: l10n.voicePlaygroundSemantic,
      hero: _VoiceHero(isDark: isDark, isListening: _isListening || _wakeWordDetected),
      accentColor: accent,
      interactive: Column(
        children: [
          GestureDetector(
            onTap: () {
              ref.read(voiceCommandServiceProvider).startActiveListening();
            },
            child: _VoiceDemo(
              lastCaptured: _lastCaptured,
              isListening: _isListening,
              wakeWordDetected: _wakeWordDetected,
              isDark: isDark,
              l10n: l10n,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _CommandList(l10n: l10n, isDark: isDark),
        ],
      ),
    );
  }
}

class _VoiceHero extends StatefulWidget {
  const _VoiceHero({required this.isDark, required this.isListening});
  final bool isDark;
  final bool isListening;

  @override
  State<_VoiceHero> createState() => _VoiceHeroState();
}

class _VoiceHeroState extends State<_VoiceHero> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cfg = ProviderScope.containerOf(context, listen: false).read(visionConfigProvider);
    final accent = cfg.accentBlue;

    return Container(
      color: bg,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Waveforms
                for (int i = 0; i < 3; i++)
                  Transform.scale(
                    scale: 1.0 + (widget.isListening ? math.sin(_controller.value * 2 * math.pi + i) * 0.2 : 0),
                    child: Container(
                      width: 100 + (i * 30),
                      height: 100 + (i * 30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.1 * (3 - i)),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                // Mic Icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: widget.isListening ? accent : accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: widget.isListening ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ] : null,
                  ),
                  child: Icon(
                    widget.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: widget.isListening ? Colors.black : accent,
                    size: 48,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VoiceDemo extends StatelessWidget {
  const _VoiceDemo({
    required this.lastCaptured,
    required this.isListening,
    required this.wakeWordDetected,
    required this.isDark,
    required this.l10n,
  });

  final String? lastCaptured;
  final bool isListening;
  final bool wakeWordDetected;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cfg = ProviderScope.containerOf(context, listen: false).read(visionConfigProvider);
    final accent = cfg.accentBlue;
    final theme = Theme.of(context);
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onVariant = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    final active = isListening || wakeWordDetected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(AppSpacing.xl),
      width: double.infinity,
      decoration: BoxDecoration(
        color: active ? accent.withValues(alpha: isDark ? 0.15 : 0.08) : surface,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        border: Border.all(
          color: active ? accent : border,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            active ? Icons.graphic_eq_rounded : Icons.mic_rounded,
            color: active ? accent : onVariant,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            active 
              ? (wakeWordDetected ? l10n.voiceWakeWordDetectedLabel : l10n.voiceListeningLabel)
              : l10n.voiceTryItHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: active ? accent : onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (lastCaptured != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              '"$lastCaptured"',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onSurface,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.voiceDetectedLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommandList extends StatelessWidget {
  const _CommandList({required this.l10n, required this.isDark});
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.voiceHelpCommandList.split(':').first.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _CategoryGroup(
          label: l10n.voiceCommandCatNav,
          commands: [
            l10n.voiceCmdOpenSettings,
            l10n.voiceCmdGoHome,
            l10n.voiceCmdOpenTutorial,
          ],
          isDark: isDark,
        ),
        _CategoryGroup(
          label: l10n.voiceCommandCatScan,
          commands: [
            l10n.voiceCmdFlashOn,
            l10n.voiceCmdFlashOff,
            l10n.voiceCmdFrontCam,
          ],
          isDark: isDark,
        ),
        _CategoryGroup(
          label: l10n.voiceCommandCatHelp,
          commands: [
            l10n.voiceCmdHelp,
            l10n.voiceCmdCommandList,
            l10n.voiceCmdExit,
          ],
          isDark: isDark,
        ),
      ],
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({
    required this.label,
    required this.commands,
    required this.isDark,
  });
  final String label;
  final List<String> commands;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final accent = ProviderScope.containerOf(context, listen: false).read(visionConfigProvider).accentBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, color: accent),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...commands.map((cmd) => Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4),
            child: Row(
              children: [
                Icon(Icons.chevron_right_rounded, size: 14, color: onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Text(
                  cmd,
                  style: TextStyle(fontSize: 14, color: onSurface, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
