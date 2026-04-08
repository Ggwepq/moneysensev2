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

  /// Used to distinguish standard double-tap listening from background passive listening.
  bool _isPassiveMode = false;
  
  /// Track current recognition state manually to handle auto-restart logic for passive mode
  bool _isListeningSessionActive = false;

  /// Lock to prevent concurrent hardware operations (stop vs start)
  bool _isHardwareBusy = false;

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

  /// Triggers a one-time active listening session (e.g. from a double-tap).
  Future<void> startActiveListening() async {
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
      _isListeningSessionActive = true;
      ref.read(voiceCommandTextProvider.notifier).state = '';
      ref.read(lastDetectedIntentProvider.notifier).state = null;

      EarconService.instance.play(EarconEvent.actionEnabled);

      final started = await _speech.listen(
        onResult: _onResult,
        listenFor: const Duration(seconds: 10),
        cancelOnError: true,
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
      if (_isPassiveMode && _isListeningSessionActive) {
        // Clear status but restart quickly
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
        Future.delayed(const Duration(milliseconds: 300), _startContinuousLoop);
      } else if (!_isPassiveMode) {
        _isListeningSessionActive = false;
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
        EarconService.instance.play(EarconEvent.actionDisabled);
      }
    }
  }

  void _onError(SpeechRecognitionError error) {
    if (!_isPassiveMode) {
      _isListeningSessionActive = false;
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.error;
      EarconService.instance.play(EarconEvent.scanFail);
    } else {
      // Passive listening recovery
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
      Future.delayed(const Duration(seconds: 1), _startContinuousLoop);
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
      // WAKE WORD ONLY logic
      if (intent is WakeIntent) {
        if (_isPassiveMode) {
          // Requirement 1: If user just said "Hey MS", ask "What shall I do?"
          final settings = ref.read(appSettingsProvider);
          final l10n = AppLocalizations.of(settings.isTagalog);
          
          ref.read(ttsServiceProvider).enqueue(
            TtsMessage.result(l10n.voicePromptWhatShallIDo, id: 'voice.prompt'),
            enabled: settings.ttsEnabled,
            currentVerbosity: settings.ttsVerbosity,
          );
          
          // Small delay to let TTS start before the active listening earcon happens
          Future.delayed(const Duration(milliseconds: 100), () {
            startActiveListening();
          });
        }
        return;
      }

      // COMMAND DETECTED (could be "Hey MS scan" or just "scan" in active mode)
      ref.read(lastDetectedIntentProvider.notifier).state = intent.toString().split('(').first;

      if (ref.read(voiceTestModeProvider)) {
        if (result.finalResult) {
          EarconService.instance.play(EarconEvent.actionConfirmed);
          ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.processing;
          Future.delayed(const Duration(seconds: 2), () {
            ref.read(voiceCommandStatusProvider.notifier).state = _isPassiveMode ? VoiceStatus.passiveListening : VoiceStatus.idle;
          });
        }
        return;
      }

      // EXECUTE
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.processing;
      ref.read(voiceCommandExecutorProvider).execute(intent);
      EarconService.instance.play(EarconEvent.actionConfirmed);

      if (!_isPassiveMode) {
         stopListening();
      } else {
         // Passive 'All-in-one' command execution.
         // Stop and restart loop to clear recognition bufffer.
         ref.read(voiceCommandTextProvider.notifier).state = '';
         stopListening().then((_) {
           Future.delayed(const Duration(milliseconds: 500), _startContinuousLoop);
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
