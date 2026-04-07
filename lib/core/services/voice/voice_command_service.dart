import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

import 'voice_intent_parser.dart';
import 'voice_command_executor.dart';
import '../earcon_service.dart';

/// Represents the status of the Voice Command Engine.
enum VoiceStatus { idle, activeListening, passiveListening, processing, error }

/// Exposes the current status of the voice command service.
final voiceCommandStatusProvider = StateProvider<VoiceStatus>((ref) => VoiceStatus.idle);

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

  Future<void> _initIfNeeded() async {
    if (_isInit) return;
    _isInit = await _speech.initialize(
      onError: _onError,
      onStatus: _onStatus,
      debugLogging: true,
    );
  }

  /// Triggers a one-time active listening session (e.g. from a double-tap).
  Future<void> startActiveListening() async {
    await _initIfNeeded();
    if (!_isInit) {
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.error;
      return;
    }

    // Stop passive if running
    if (_isListeningSessionActive) {
      await stopListening();
    }

    _isPassiveMode = false;
    _isListeningSessionActive = true;
    ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.activeListening;

    EarconService.instance.play(EarconEvent.actionEnabled); // Chime to indicate active listening

    await _speech.listen(
      onResult: _onResult,
      listenFor: const Duration(seconds: 10),
      cancelOnError: true,
      partialResults: false, // We only care about the final sentence
    );
  }

  /// Triggers a continuous passive listening session.
  Future<void> startPassiveListening() async {
    await _initIfNeeded();
    if (!_isInit) return;

    if (_isListeningSessionActive) return; // Already going

    _isPassiveMode = true;
    _isListeningSessionActive = true;
    ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.passiveListening;

    _startContinuousLoop();
  }

  void _startContinuousLoop() async {
    if (!_isPassiveMode || !_isListeningSessionActive) return;
    if (_speech.isListening) return;

    try {
      await _speech.listen(
        onResult: _onResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3), // Stops listening if silence for 3s
        cancelOnError: false,
        partialResults: false, 
      );
    } catch (e) {
      // Ignore start errors and try again later
    }
  }

  /// Immediately stops both active and passive listening.
  Future<void> stopListening() async {
    _isPassiveMode = false;
    _isListeningSessionActive = false;
    ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
    
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      // If we are in active mode, a 'done' means the explicit command session ended.
      if (!_isPassiveMode) {
        _isListeningSessionActive = false;
        if (ref.read(voiceCommandStatusProvider) == VoiceStatus.activeListening) {
          ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
          EarconService.instance.play(EarconEvent.actionDisabled); // Mic off chime
        }
      } 
      // If passive mode, we instantly restart it to keep continuous listening alive
      else if (_isPassiveMode && _isListeningSessionActive) {
        Future.delayed(const Duration(milliseconds: 100), _startContinuousLoop);
      }
    }
  }

  void _onError(SpeechRecognitionError error) {
    // If active listening, we stop and optionally fail.
    if (!_isPassiveMode) {
      _isListeningSessionActive = false;
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.error;
      EarconService.instance.play(EarconEvent.scanFail);
    } else {
      // Passive listening automatically restarts on error 
      Future.delayed(const Duration(milliseconds: 500), _startContinuousLoop);
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!result.finalResult) return; // Only process complete sentences

    final recognizedText = result.recognizedWords.toLowerCase();
    
    // In passive mode, we require the wake word "moneysense" to exist in the sentence
    if (_isPassiveMode) {
      if (!recognizedText.contains('moneysense')) {
        // Did not mention the wake word, ignore and let auto-restart loop continue
        return; 
      }
    }

    // Process the text
    ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.processing;

    final intent = VoiceIntentParser.parse(recognizedText);
    
    // Execute intent
    ref.read(voiceCommandExecutorProvider).execute(intent);

    // Active mode finishes after one command.
    if (!_isPassiveMode) {
       EarconService.instance.play(EarconEvent.actionConfirmed);
       stopListening();
    } else {
       ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.passiveListening;
    }
  }
}
