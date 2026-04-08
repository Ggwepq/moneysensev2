
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

// 6-page onboarding flow shown on first launch. The user picks their vision
// profile, language, and navigation preferences before entering the app.
// Accent colors update live as the profile is selected on page 1.

enum _NavStyle { standard, gestural, inertial, voice }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final void Function({bool launchTutorial}) onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _total = 6;

  int _page = 0;

  VisionProfile _profile  = VisionProfile.lowVision;
  AppLanguage   _language = AppLanguage.english;
  _NavStyle     _nav      = _NavStyle.standard;

  // ── Voice Setup Mode ──────────────────────────────────────────────────────
  bool _isVoiceActive = true;
  bool _isSpeaking    = false;
  bool _isListening   = false;
  bool _isAdvancing   = false;
  bool _launchFinalTutorial = false;
  StreamSubscription? _voiceSub;

  // ── TTS ───────────────────────────────────────────────────────────────────

  // TTS and Localization helpers are defined below.

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    
    // Sync with speaker state for timing
    ref.read(ttsServiceProvider).isSpeakingNotifier.addListener(_onTtsStatusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Always request mic on start for voice onboarding
      await Permission.microphone.request();
      _startVoiceMode();
    });

    // Listen for intents
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
      3 => OnboardingSpeech.navStep(l10n),
      4 => OnboardingSpeech.permStep(l10n),
      5 => OnboardingSpeech.finish(l10n),
      _ => null,
    };
    if (msg != null) _say(msg);
  }

  void _onTtsStatusChanged() {
    final speaking = ref.read(ttsServiceProvider).isSpeakingNotifier.value;
    if (mounted && _isSpeaking != speaking) {
      setState(() => _isSpeaking = speaking);
      
      // If we just finished speaking:
      if (!speaking) {
        // 1. If we were waiting to move to the next step, do it now
        if (_isAdvancing) {
          _isAdvancing = false;
          if (_page == 5) {
            _finish(launchTutorial: _launchFinalTutorial);
          } else {
            _next();
          }
          return;
        }

        // 2. Otherwise start listening for a response
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
    
    // Safety timeout: if no response in 30s, gently re-prompt
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isListening && _isVoiceActive && !_isSpeaking && !_isAdvancing) {
        _isListening = false;
        _say(TtsMessage.ambient('I didn\'t hear anything. Would you like to continue or do you need help with this step?'));
      }
    });
  }

  void _onVoiceIntent(VoiceIntent intent) {
    if (!_isVoiceActive) return;

    setState(() => _isListening = false);

    if (intent is SelectionConfirmationIntent) {
      if (intent.isConfirmed) {
        if (_page == 0) {
          _isAdvancing = true;
          _say(TtsMessage.navigation(l10n.onboardingWelcomeConfirm));
        } else if (_page == 4) {
          _requestPerm().then((alreadyGranted) {
            _isAdvancing = true;
            if (alreadyGranted) {
              _say(TtsMessage.navigation(l10n.onboardingConfirmPermAlready));
            } else {
              _say(TtsMessage.navigation(l10n.onboardingConfirmPerm));
            }
          });
        } else if (_page == 5) {
          _isAdvancing = true;
          _launchFinalTutorial = true;
          _say(OnboardingSpeech.exitToTour(l10n));
        }
      } else {
        if (_page == 5) {
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
      _say(TtsMessage.ambient('Manual mode is disabled for this test. Please continue using voice commands.'));
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
      case 'standard': setState(() => _nav = _NavStyle.standard);
      case 'gestural': setState(() => _nav = _NavStyle.gestural);
      case 'inertial': setState(() => _nav = _NavStyle.inertial);
      case 'voice': setState(() => _nav = _NavStyle.voice);
    }
    
    // Confirm the choice then move on
    _isAdvancing = true;
    final confirmMsg = _page == 1 
        ? l10n.onboardingConfirmVision 
        : (_page == 2 ? l10n.onboardingConfirmLanguage : l10n.onboardingConfirmNav);
    _say(TtsMessage.navigation(confirmMsg));
  }

  @override
  void dispose() {
    ref.read(ttsServiceProvider).isSpeakingNotifier.removeListener(_onTtsStatusChanged);
    _voiceSub?.cancel();
    super.dispose();
  }

  // ── Page navigation ───────────────────────────────────────────────────────

  void _goTo(int page) {
    if (page < 0 || page >= _total) return;
    setState(() => _page = page);
    _narrate(page);
  }

  void _next() {
    EarconService.instance.play(EarconEvent.onboardingNext);
    _goTo(_page + 1);
  }

  void _finish({required bool launchTutorial}) {
    final n = ref.read(appSettingsProvider.notifier);
    n.setVisionProfile(_profile);
    n.setLanguage(_language);
    switch (_nav) {
      case _NavStyle.standard:
        n.toggleGesturalNavigation(false);
        n.toggleInertialNavigation(false);
        n.toggleVoiceNavigation(false);
      case _NavStyle.gestural:
        n.toggleGesturalNavigation(true);
        n.toggleInertialNavigation(false);
        n.toggleVoiceNavigation(false);
      case _NavStyle.inertial:
        n.toggleGesturalNavigation(false);
        n.toggleInertialNavigation(true);
        n.toggleVoiceNavigation(false);
      case _NavStyle.voice:
        // Voice mode also leaves standard touch enabled
        n.toggleGesturalNavigation(false);
        n.toggleInertialNavigation(false);
        n.toggleVoiceNavigation(true);
    }
    final cfg = VisionConfig.from(_profile);
    if (cfg.preferAudioPrimary) {
      n.toggleTts(true);
      n.setTtsVerbosity(cfg.defaultTtsVerbosity);
    }
    widget.onComplete(launchTutorial: launchTutorial);
  }

  // ── Camera permission ─────────────────────────────────────────────────────

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

  // ── Build ─────────────────────────────────────────────────────────────────

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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Step Indicator
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
                
                // Active Title
                Text(
                  _getStepTitle(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: onBg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 60),

                // Central Voice Orb
                VoiceOnboardingOrb(
                  isListening: _isListening,
                  isSpeaking: _isSpeaking,
                ),
                
                const SizedBox(height: 60),

                // Status Text
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
                  height: 48,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_page) {
      case 0: return 'Welcome';
      case 1: return 'Vision Profile';
      case 2: return 'Language';
      case 3: return 'Navigation Style';
      case 4: return 'Permissions';
      case 5: return 'Ready to Go';
      default: return '';
    }
  }

  String _getStepPrompt() {
    if (_isSpeaking) return 'Listen carefully to the instructions.';
    switch (_page) {
      case 0: return 'Say "Proceed" or "Yes" to begin setup.';
      case 1: return 'Say "Low Vision", "Partially Blind", or "Fully Blind".';
      case 2: return 'Say "English" or "Tagalog".';
      case 3: return 'Say "Standard", "Gestural", "Inertial", or "Voice".';
      case 4: return 'Say "Proceed" to grant camera access.';
      case 5: return 'Say "Start" to begin using MoneySense.';
      default: return '';
    }
  }
}



// Private widgets for manual onboarding removed as this is now voice-only.
