
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/earcon_service.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/speech_scripts.dart';
import '../../../../core/services/tts_service.dart';

import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/domain/entities/vision_config.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/services/voice/voice_command_service.dart';
import '../../../../core/services/voice/voice_intent.dart';
import '../widgets/voice_onboarding_orb.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final void Function({bool launchTutorial}) onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _total = 5;

  int _page = 0;

  VisionProfile _profile  = VisionProfile.lowVision;
  AppLanguage   _language = AppLanguage.english;

  bool _isVoiceActive = true;
  bool _isSpeaking    = false;
  bool _isListening   = false;
  bool _isAdvancing   = false;
  bool _launchFinalTutorial = false;
  StreamSubscription? _voiceSub;

  @override
  void initState() {
    super.initState();
    ref.read(ttsServiceProvider).isSpeakingNotifier.addListener(_onTtsStatusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure the wake-word passive loop (if already running) is stopped
      // before we open the mic for onboarding — the two would fight otherwise.
      await ref.read(voiceCommandServiceProvider).stopListening();
      await Permission.microphone.request();
      _startVoiceMode();
    });

    _voiceSub = ref.read(voiceCommandServiceProvider).intentStream.listen(_onVoiceIntent);
  }

  AppLocalizations get l10n => AppLocalizations.of(_language == AppLanguage.tagalog);

  void _say(TtsMessage message) {
    ref.read(ttsServiceProvider).enqueue(
      message,
      enabled: true,
      currentVerbosity: ref.read(appSettingsProvider).ttsVerbosity,
    );
  }

  void _narrate(int page) {
    final msg = switch (page) {
      0 => OnboardingSpeech.welcome(l10n),
      1 => OnboardingSpeech.visionStep(l10n),
      2 => OnboardingSpeech.languageStep(l10n),
      3 => OnboardingSpeech.permStep(l10n),
      4 => OnboardingSpeech.finish(l10n),
      _ => null,
    };
    if (msg != null) _say(msg);
  }

  void _onTtsStatusChanged() {
    if (!mounted) return;
    final speaking = ref.read(ttsServiceProvider).isSpeakingNotifier.value;
    if (_isSpeaking != speaking) {
      setState(() => _isSpeaking = speaking);
      if (!speaking) {
        if (_isAdvancing) {
          _isAdvancing = false;
          if (_page == 4) {
            _finish(launchTutorial: _launchFinalTutorial);
          } else {
            _next();
          }
          return;
        }
        if (_isVoiceActive && !_isListening) {
          _startListening();
        }
      }
    }
  }

  void _startVoiceMode() {
    setState(() => _isVoiceActive = true);
    _narrate(_page);
  }

  Future<void> _startListening() async {
    if (!_isVoiceActive || _isSpeaking || _isAdvancing) return;
    setState(() => _isListening = true);
    await ref.read(voiceCommandServiceProvider).startActiveListening(persistent: true);
    
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isListening && _isVoiceActive && !_isSpeaking && !_isAdvancing) {
        _isListening = false;
        _say(TtsMessage.ambient('I didn\'t hear anything. Would you like to continue or do you need help with this step?'));
      }
    });
  }

  void _onVoiceIntent(VoiceIntent intent) {
    if (!_isVoiceActive) return;
    if (!mounted) return;

    setState(() => _isListening = false);

    if (intent is SkipIntent) {
      _skip();
      return;
    }

    if (intent is SelectionConfirmationIntent) {
      if (intent.isConfirmed) {
        if (_page == 0) {
          _isAdvancing = true;
          _say(TtsMessage.navigation(l10n.onboardingWelcomeConfirm));
        } else if (_page == 3) {
          _requestPerm().then((alreadyGranted) {
            _isAdvancing = true;
            if (alreadyGranted) {
              _say(TtsMessage.navigation(l10n.onboardingConfirmPermAlready));
            } else {
              _say(TtsMessage.navigation(l10n.onboardingConfirmPerm));
            }
          });
        } else if (_page == 4) {
          _isAdvancing = true;
          _launchFinalTutorial = true;
          _say(OnboardingSpeech.exitToTour(l10n));
        }
      } else {
        if (_page == 4) {
          _isAdvancing = true;
          _launchFinalTutorial = false;
          _say(OnboardingSpeech.exitToScanner(l10n));
        } else {
          _say(TtsMessage.ambient('No problem. What would you like to choose instead?'));
        }
      }
      return;
    }

    if (intent is SelectionIntent) {
      _handleSelection(intent.value);
      return;
    }
    
    if (intent is StopSpeakingIntent) {
      _say(TtsMessage.ambient('Stop command recognized. Switching to manual mode.'));
      setState(() => _isVoiceActive = false);
      return;
    }
    
    if (intent is UnknownIntent) {
      _say(TtsMessage.ambient('Sorry, I didn\'t catch that. Can you say it again?'));
    }
  }

  void _handleSelection(String value) {
    if (_isAdvancing) return;

    switch (value) {
      case 'lowVision': setState(() => _profile = VisionProfile.lowVision);
      case 'partiallyBlind': setState(() => _profile = VisionProfile.partiallyBlind);
      case 'fullyBlind': setState(() => _profile = VisionProfile.fullyBlind);
      case 'english': setState(() => _language = AppLanguage.english);
      case 'tagalog': setState(() => _language = AppLanguage.tagalog);
    }
    
    _isAdvancing = true;

    if (!ref.read(appSettingsProvider).clarifyVoiceCommands) {
       _next();
       return;
    }

    final confirmMsg = _page == 1 
        ? l10n.onboardingConfirmVision 
        : l10n.onboardingConfirmLanguage;
    _say(TtsMessage.navigation(confirmMsg));
  }

  @override
  void dispose() {
    ref.read(ttsServiceProvider).stop();
    ref.read(ttsServiceProvider).isSpeakingNotifier.removeListener(_onTtsStatusChanged);
    _voiceSub?.cancel();
    ref.read(voiceCommandServiceProvider).stopListening();
    super.dispose();
  }

  void _goTo(int page) {
    if (page < 0 || page >= _total) return;
    ref.read(ttsServiceProvider).stop();
    setState(() => _page = page);
    _narrate(page);
  }

  void _next() {
    EarconService.instance.play(EarconEvent.onboardingNext);
    _goTo(_page + 1);
  }

  void _skip() {
    _isAdvancing = false;
    _voiceSub?.cancel();
    ref.read(voiceCommandServiceProvider).stopListening();
    ref.read(ttsServiceProvider).stop();
    EarconService.instance.play(EarconEvent.actionDisabled);
    
    final n = ref.read(appSettingsProvider.notifier);
    n.setVisionProfile(VisionProfile.partiallyBlind);
    n.toggleGesturalNavigation(true);
    n.toggleVoiceNavigation(false);
    
    _profile = VisionProfile.partiallyBlind;
    
    widget.onComplete(launchTutorial: false);
  }

  void _finish({required bool launchTutorial}) {
    ref.read(ttsServiceProvider).stop();
    final n = ref.read(appSettingsProvider.notifier);
    n.setVisionProfile(_profile);
    n.setLanguage(_language);
    
    final cfg = VisionConfig.from(_profile);
    if (cfg.preferAudioPrimary) {
      n.toggleTts(true);
      n.setTtsVerbosity(cfg.defaultTtsVerbosity);
    }
    widget.onComplete(launchTutorial: launchTutorial);
  }

  Future<bool> _requestPerm() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    if (cameraStatus.isGranted && micStatus.isGranted) {
      return true;
    }

    await [
      Permission.camera,
      Permission.microphone,
    ].request();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cfg    = VisionConfig.from(_profile);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = cfg.accent(isDark);
    final onBg   = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final bg     = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: Semantics(
                label: 'Skip onboarding and use default settings',
                button: true,
                child: TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(foregroundColor: onBg.withValues(alpha: 0.6)),
                  child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Step ${_page + 1} of $_total',
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Text(
                        _getStepTitle(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: onBg,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 48),

                      SizedBox(
                        width: 260,
                        height: 260,
                        child: Center(
                          child: VoiceOnboardingOrb(
                            isListening: _isListening,
                            isSpeaking: _isSpeaking,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),

                      SizedBox(
                        height: 32,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _isSpeaking 
                                ? 'MoneySense is speaking...' 
                                : (_isListening ? 'Listening for your response...' : 'Thinking...'),
                            key: ValueKey(_isSpeaking ? 1 : (_isListening ? 2 : 3)),
                            style: TextStyle(
                              color: onBg,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      SizedBox(
                        height: 54,
                        child: Text(
                          _getStepPrompt(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      _buildChoiceButtons(accent, onBg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButtons(Color accent, Color onBg) {
    final List<Widget> buttons = [];
    
    switch (_page) {
      case 0:
        buttons.add(_OnboardingButton(
          label: 'Proceed',
          onPressed: () {
            _isAdvancing = true;
            _say(TtsMessage.navigation(l10n.onboardingWelcomeConfirm));
          },
          accent: accent,
        ));
      case 1:
        for (final p in VisionProfile.values) {
          buttons.add(_OnboardingButton(
            label: _getProfileLabel(p),
            isSelected: _profile == p,
            onPressed: () => _handleSelection(p.name),
            accent: accent,
          ));
        }
      case 2:
        buttons.add(_OnboardingButton(
          label: 'English',
          isSelected: _language == AppLanguage.english,
          onPressed: () => _handleSelection('english'),
          accent: accent,
        ));
        buttons.add(_OnboardingButton(
          label: 'Tagalog',
          isSelected: _language == AppLanguage.tagalog,
          onPressed: () => _handleSelection('tagalog'),
          accent: accent,
        ));
      case 3:
        buttons.add(_OnboardingButton(
          label: 'Grant Permissions',
          onPressed: () => _requestPerm().then((alreadyGranted) {
            _isAdvancing = true;
            if (alreadyGranted) {
               _say(TtsMessage.navigation(l10n.onboardingConfirmPermAlready));
            } else {
               _say(TtsMessage.navigation(l10n.onboardingConfirmPerm));
            }
          }),
          accent: accent,
        ));
      case 4:
        buttons.add(_OnboardingButton(
          label: 'Start Now',
          onPressed: () {
            _isAdvancing = true;
            _launchFinalTutorial = false;
            _say(OnboardingSpeech.exitToScanner(l10n));
          },
          accent: accent,
        ));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: buttons,
    );
  }

  String _getProfileLabel(VisionProfile p) {
    switch (p) {
      case VisionProfile.lowVision: return 'Low Vision';
      case VisionProfile.partiallyBlind: return 'Partially Blind';
      case VisionProfile.fullyBlind: return 'Fully Blind';
    }
  }

  String _getStepTitle() {
    switch (_page) {
      case 0: return 'Welcome';
      case 1: return 'Vision Profile';
      case 2: return 'Language';
      case 3: return 'Permissions';
      case 4: return 'Ready to Go';
      default: return '';
    }
  }

  String _getStepPrompt() {
    if (_isSpeaking) return 'Listen carefully to the instructions.';
    switch (_page) {
      case 0: return 'Say "Proceed", "Yes", or "Skip" to begin.';
      case 1: return 'Say "Low Vision", "Partially Blind", or "Fully Blind".';
      case 2: return 'Say "English" or "Tagalog".';
      case 3: return 'Say "Proceed" to grant camera access.';
      case 4: return 'Say "Start" to begin using MoneySense.';
      default: return '';
    }
  }
}

class _OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color accent;
  final bool isSelected;

  const _OnboardingButton({
    required this.label,
    required this.onPressed,
    required this.accent,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isSelected ? 'Selected: $label' : label,
      button: true,
      selected: isSelected,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isSelected ? Colors.black : accent,
          backgroundColor: isSelected ? accent : Colors.transparent,
          side: BorderSide(color: accent, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
    );
  }
}
