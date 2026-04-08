import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

import 'voice_intent_parser.dart';
import 'voice_intent.dart';
import 'voice_command_executor.dart';
import '../earcon_service.dart';
import '../tts_service.dart';
import '../../l10n/app_localizations.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';

/// Represents the status of the Voice Command Engine.
enum VoiceStatus { idle, activeListening, passiveListening, processing, error }

/// Exposes the current status of the voice command service.
final voiceCommandStatusProvider = StateProvider<VoiceStatus>((ref) => VoiceStatus.idle);

/// Exposes the interim parsed text from the voice listener to show it live in the UI.
final voiceCommandTextProvider = StateProvider<String>((ref) => '');

/// If true, detected commands will be shown but NOT executed.
final voiceTestModeProvider = StateProvider<bool>((ref) => false);

/// Shows the name of the last successfully parsed intent.
final lastDetectedIntentProvider = StateProvider<String?>((ref) => null);

/// The primary service that manages microphone access, recognition loops, and dispatches to the executor.
final voiceCommandServiceProvider = Provider<VoiceCommandService>((ref) {
  return VoiceCommandService(ref);
});

class VoiceCommandService {
  VoiceCommandService(this.ref);

  final Ref ref;
  final SpeechToText _speech = SpeechToText();
  bool _isInit = false;

  /// Exposes intents as they are parsed, allowing contextual listeners
  /// (like onboarding) to react to voice commands.
  final _intentController = StreamController<VoiceIntent>.broadcast();
  Stream<VoiceIntent> get intentStream => _intentController.stream;

  /// Used to distinguish standard double-tap listening from background passive listening.
  bool _isPassiveMode = false;
  
  /// Track current recognition state manually to handle auto-restart logic for passive mode
  bool _isListeningSessionActive = false;
  
  /// If true, the system will auto-restart active listening if it stops 
  /// without an intent (used for onboarding).
  bool _isPersistentActive = false;

  /// Lock to prevent concurrent hardware operations (stop vs start)
  bool _isHardwareBusy = false;

  /// Confirmation Loop State
  VoiceIntent? _pendingIntent;
  bool _isAwaitingConfirmation = false;

  Future<void> _initIfNeeded() async {
    if (_isInit) return;
    try {
      _isInit = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: false,
      );
    } catch (e) {
      _isInit = false;
    }
  }

  /// Safe wrapper to ensure we don't spam start/stop on the hardware
  Future<bool> _runHardwareAction(Future<bool> Function() action) async {
    if (_isHardwareBusy) return false;
    _isHardwareBusy = true;
    try {
      return await action();
    } finally {
      // Small settling time to let the native platform breath
      await Future.delayed(const Duration(milliseconds: 200));
      _isHardwareBusy = false;
    }
  }

  /// Triggers an active listening session.
  /// If [persistent] is true, it will auto-restart if it times out without a result.
  Future<void> startActiveListening({bool persistent = false}) async {
    if (_isHardwareBusy) return;
    
    await _initIfNeeded();
    if (!_isInit) {
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.error;
      return;
    }

    // Stop passive if running and wait for it to clear
    if (_isPassiveMode || _isListeningSessionActive || _speech.isListening) {
      await stopListening();
      // Mandatory wait for unbind
      await Future.delayed(const Duration(milliseconds: 250));
    }

    await _runHardwareAction(() async {
      _isPassiveMode = false;
      _isPersistentActive = persistent;
      _isListeningSessionActive = true;
      ref.read(voiceCommandTextProvider.notifier).state = '';
      ref.read(lastDetectedIntentProvider.notifier).state = null;

      EarconService.instance.play(EarconEvent.actionEnabled);

      final started = await _speech.listen(
        onResult: _onResult,
        listenFor: persistent ? const Duration(minutes: 1) : const Duration(seconds: 10),
        pauseFor: persistent ? const Duration(seconds: 20) : null,
        cancelOnError: !persistent,
        partialResults: true, 
      );

      if (started) {
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.activeListening;
      } else {
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
      }
      return started;
    });
  }

  /// Triggers a continuous passive listening session.
  Future<void> startPassiveListening() async {
    if (_isHardwareBusy) return;
    
    await _initIfNeeded();
    if (!_isInit) return;

    if (_isPassiveMode && _isListeningSessionActive && _speech.isListening) return; 

    _isPassiveMode = true;
    _isListeningSessionActive = true;
    
    _startContinuousLoop();
  }

  void _startContinuousLoop() async {
    if (!_isPassiveMode || !_isListeningSessionActive) return;
    if (_speech.isListening || _isHardwareBusy) return;

    await _runHardwareAction(() async {
      try {
        final started = await _speech.listen(
          onResult: _onResult,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          cancelOnError: false,
          partialResults: true, 
        );
        
        if (started) {
          ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.passiveListening;
        } else {
          ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
          Future.delayed(const Duration(seconds: 3), _startContinuousLoop);
        }
        return started;
      } catch (e) {
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
        Future.delayed(const Duration(seconds: 5), _startContinuousLoop);
        return false;
      }
    });
  }

  /// Immediately stops both active and passive listening.
  Future<void> stopListening() async {
    _isPassiveMode = false;
    _isPersistentActive = false;
    _isListeningSessionActive = false;
    ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
    
    EarconService.instance.play(EarconEvent.actionDisabled);

    if (_speech.isListening) {
      // Use cancel() instead of stop() for faster turnaround during transitions
      await _speech.cancel();
      // Allow settling
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void _onStatus(String status) {
    // If hardware says it's done/notListening but we're supposed to be passive, restart.
    if (status == 'done' || status == 'notListening') {
      if ((_isPassiveMode || _isPersistentActive) && _isListeningSessionActive) {
        // Clear status but restart quickly
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
        final nextCall = _isPassiveMode ? _startContinuousLoop : () => startActiveListening(persistent: true);
        Future.delayed(const Duration(milliseconds: 300), nextCall);
      } else if (!_isPassiveMode && !_isPersistentActive) {
        _isListeningSessionActive = false;
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
        EarconService.instance.play(EarconEvent.actionDisabled);
      }
    }
  }

  void _onError(SpeechRecognitionError error) {
    if (!_isPassiveMode && !_isPersistentActive) {
      _isListeningSessionActive = false;
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.error;
      EarconService.instance.play(EarconEvent.scanFail);
    } else {
      // Recovery for continuous modes
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
      final nextCall = _isPassiveMode ? _startContinuousLoop : () => startActiveListening(persistent: true);
      Future.delayed(const Duration(seconds: 1), nextCall);
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    final recognizedText = result.recognizedWords.toLowerCase();

    // Requirement 2: Always update the text provider so the UI (Blind Mode) doesn't feel static
    ref.read(voiceCommandTextProvider.notifier).state = recognizedText;

    if (_isPassiveMode) {
      final wakeWordRegex = RegExp(
        r'(hey|hoy|hay|hi|hello|ok|paki|yo|hame)?\s*(ams|ms|miss|money|monie|moni|monee|mane|mani|many|mona|mone|monay|madison|mannequin)\s*(s[iey]nc[e]?|s[iey]ns[e]?|sc[iey]ns[e]?|sc[iey]nc[e]?|cents|sents|sends|sens|ence|s)?',
        caseSensitive: false,
      );
      if (!wakeWordRegex.hasMatch(recognizedText)) return; 
    }

    final intent = VoiceIntentParser.parse(recognizedText);

    if (intent is! UnknownIntent) {
      // COMMAND DETECTED
      
      // If we are already waiting for confirmation, check if this is a Yes/No
      if (_isAwaitingConfirmation && _pendingIntent != null) {
        if (intent is SelectionConfirmationIntent) {
          final settings = ref.read(appSettingsProvider);
          final l10n = AppLocalizations.of(settings.isTagalog);
          final tts = ref.read(ttsServiceProvider);

          if (intent.isConfirmed) {
            // YES: EXECUTE
            ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.processing;
            final success = ref.read(voiceCommandExecutorProvider).execute(_pendingIntent!);
            _intentController.add(_pendingIntent!);
            
            // Warm success feedback (only if executor didn't signal an error)
            if (success) {
              tts.enqueue(
                TtsMessage.result(l10n.voiceActionSuccess, id: 'voice.success'),
                enabled: settings.ttsEnabled,
                currentVerbosity: settings.ttsVerbosity,
              );
            }
            
            _pendingIntent = null;
            _isAwaitingConfirmation = false;
            
            if (_isPassiveMode) {
               Future.delayed(const Duration(milliseconds: 500), _startContinuousLoop);
            } else {
               stopListening();
            }
          } else {
            // NO: CANCEL
            tts.enqueue(
              TtsMessage.result(l10n.voiceActionCancelled, id: 'voice.cancel'),
              enabled: settings.ttsEnabled,
              currentVerbosity: settings.ttsVerbosity,
            );
            _pendingIntent = null;
            _isAwaitingConfirmation = false;
            
            // Small delay then start listening for the NEW command
            Future.delayed(const Duration(milliseconds: 500), () {
              startActiveListening();
            });
          }
          return;
        }
      }

      // Handle intents that don't need confirmation (Contextual or Control)
      if (intent is WakeIntent || 
          intent is StopSpeakingIntent || 
          intent is SelectionConfirmationIntent ||
          intent is SelectionIntent ||
          intent is StartVoiceSetupIntent) {
        
        if (intent is WakeIntent) {
          if (_isPassiveMode) {
            final settings = ref.read(appSettingsProvider);
            final l10n = AppLocalizations.of(settings.isTagalog);
            ref.read(ttsServiceProvider).enqueue(
              TtsMessage.result(l10n.voicePromptWhatShallIDo, id: 'voice.prompt'),
              enabled: settings.ttsEnabled,
              currentVerbosity: settings.ttsVerbosity,
            );
            Future.delayed(const Duration(milliseconds: 100), () {
              startActiveListening();
            });
          }
          return;
        }

        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.processing;
        ref.read(voiceCommandExecutorProvider).execute(intent);
        _intentController.add(intent);
        
        if (!_isPassiveMode) {
          stopListening();
        } else if (intent is! StopSpeakingIntent) {
          Future.delayed(const Duration(milliseconds: 500), _startContinuousLoop);
        }
        return;
      }

      // STANDARD COMMANDS: START CONFIRMATION LOOP
      if (result.finalResult) {
        _pendingIntent = intent;
        _isAwaitingConfirmation = true;
        
        final settings = ref.read(appSettingsProvider);
        final l10n = AppLocalizations.of(settings.isTagalog);
        final tts = ref.read(ttsServiceProvider);

        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.processing;
        ref.read(lastDetectedIntentProvider.notifier).state = intent.toString().split('(').first;
        
        // Ask: "Did you say: [description]? Yes or no?"
        final description = intent.toDescription(l10n);
        tts.enqueue(
          TtsMessage.result('${l10n.voiceConfirmPrefix} $description${l10n.voiceConfirmSuffix}', id: 'voice.confirm_prompt'),
          enabled: settings.ttsEnabled,
          currentVerbosity: settings.ttsVerbosity,
        );

        // Small delay to let TTS start, then listen for Yes/No
        Future.delayed(const Duration(milliseconds: 300), () {
          startActiveListening();
        });
      }
      return; 
    }

    if (!result.finalResult) return; 

    // Handle Unknown final results
    ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.processing;
    ref.read(voiceCommandExecutorProvider).execute(intent);

    if (!_isPassiveMode) {
       EarconService.instance.play(EarconEvent.scanFail);
       stopListening();
    } else {
       ref.read(voiceCommandTextProvider.notifier).state = '';
       ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.passiveListening;
    }
  }
}
