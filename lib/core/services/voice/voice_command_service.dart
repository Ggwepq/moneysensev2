import 'dart:async';
import 'package:flutter/foundation.dart';
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
final voiceCommandStatusProvider = StateProvider<VoiceStatus>(
  (ref) => VoiceStatus.idle,
);

/// Exposes the interim parsed text from the voice listener to show it live in the UI.
final voiceCommandTextProvider = StateProvider<String>((ref) => '');

/// If true, detected commands will be shown but NOT executed.
final voiceTestModeProvider = StateProvider<bool>((ref) => false);

/// Shows the name of the last successfully parsed intent.
final lastDetectedIntentProvider = StateProvider<String?>((ref) => null);

/// The primary service that manages microphone access, recognition loops,
/// and dispatches to the executor.
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

  // ── Mode flags ─────────────────────────────────────────────────────────────

  bool _isPassiveMode = false;
  bool _isPersistentActive = false;
  bool _isStopped = true;
  bool _isActiveMode = false;
  bool _isChangingState = false;

  // ── Serialised hardware access ─────────────────────────────────────────────
  final _opQueue = <_HardwareOp>[];
  bool _opRunning = false;

  // ── Confirmation loop ──────────────────────────────────────────────────────
  VoiceIntent? _pendingIntent;
  bool _isAwaitingConfirmation = false;

  // ── Passive restart timer ─────────────────────────────────────────────────
  Timer? _restartTimer;

  // ── Feature Ownership & Silencing ──────────────────────────────────────────
  /// Current owner of the voice service. Locked until released or stolen by high priority.
  Object? _owner;
  
  /// Release the service from current owner.
  void release(Object? owner) {
    if (_owner == owner) _owner = null;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Initialisation
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _initIfNeeded() async {
    if (_isInit) return;
    try {
      _isInit = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: false,
      );
    } catch (_) {
      _isInit = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Serialised operation queue
  // ──────────────────────────────────────────────────────────────────────────

  void _enqueue(_HardwareOp op) {
    _opQueue.add(op);
    _drain();
  }

  Future<void> _drain() async {
    if (_opRunning) return;
    while (_opQueue.isNotEmpty) {
      _opRunning = true;
      final op = _opQueue.removeAt(0);
      try {
        await op();
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 80));
      _opRunning = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _waitForTts() async {
    final tts = ref.read(ttsServiceProvider);
    if (!tts.isSpeakingNotifier.value) return;

    final completer = Completer<void>();
    void listener() {
      if (!tts.isSpeakingNotifier.value) {
        tts.isSpeakingNotifier.removeListener(listener);
        if (!completer.isCompleted) completer.complete();
      }
    }

    tts.isSpeakingNotifier.addListener(listener);
    // Safety timeout: don't wait forever if TTS engine hangs
    await completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      tts.isSpeakingNotifier.removeListener(listener);
    });
  }

  /// Triggers an active listening session.
  ///
  /// [persistent]     – auto-restart when the microphone times out (onboarding).
  /// [withPrompt]     – play "I'm listening" before opening the mic.
  /// [isConfirmation] – whether this is a yes/no confirmation (longer timers).
  /// [owner]          – requester identity to prevent feature fighting.
  Future<void> startActiveListening({
    bool persistent = false,
    bool withPrompt = false,
    bool isConfirmation = false,
    Object? owner,
  }) async {
    // If there is an owner and a new requester (different owner) tries to start,
    // we allow it but log it. Priority logic could be added here.
    if (_owner != null && _owner != owner) {
      debugPrint('[VoiceService] ⚠️ Microhone requested by $owner while owned by $_owner. Overriding.');
    }
    _owner = owner;

    _isChangingState = true;
    _isStopped = false;
    _isPassiveMode = false;
    _isActiveMode = false;
    _isPersistentActive = persistent;

    if (withPrompt) {
      final settings = ref.read(appSettingsProvider);
      final l10n = AppLocalizations.of(settings.isTagalog);
      ref.read(ttsServiceProvider).enqueue(
            TtsMessage.result(
              l10n.voiceListeningFeedback,
              id: 'voice.listening_start',
            ),
            enabled: settings.ttsEnabled,
            currentVerbosity: settings.ttsVerbosity,
          );
    }

    _enqueue(() async {
      // Increase silence window for confirmation sessions
      // This gives the user more time to think or wait for the prompt to finish.
      final listenFor = isConfirmation ? const Duration(seconds: 15) : const Duration(seconds: 10);
      final pauseFor = isConfirmation ? const Duration(seconds: 8) : const Duration(seconds: 5);

      await _stopHardware(playEarcon: false);
      
      // 🚀 CRITICAL FIX: Explicitly wait for TTS to finish before opening mic.
      // This prevents the scanner or tutorial feedback from drowning out the user.
      await _waitForTts();
      
      // Small settle time after TTS stops
      await Future<void>.delayed(const Duration(milliseconds: 200));
      
      await _startHardware(
        listenFor: listenFor,
        pauseFor: pauseFor,
        cancelOnError: !persistent,
        passive: false,
        playEarcon: true,
      );
      _isPassiveMode = false;
      _isActiveMode = true;
      _isChangingState = false;
    });
  }

  /// Triggers a continuous passive (wake-word) listening session.
  Future<void> startPassiveListening() async {
    if (_isPassiveMode) return;
    _isChangingState = true;
    _isStopped = false;
    _isPassiveMode = false;
    _isActiveMode = false;
    _isPersistentActive = false;
    _cancelRestartTimer();

    _enqueue(() async {
      await _stopHardware();
      await _startPassiveLoop();
      _isChangingState = false;
    });
  }

  /// Immediately stops both active and passive listening.
  Future<void> stopListening() async {
    _isChangingState = true;
    _cancelRestartTimer();
    _isStopped = true;
    _isPassiveMode = false;
    _isActiveMode = false;
    _isPersistentActive = false;
    _isAwaitingConfirmation = false;
    _pendingIntent = null;

    _enqueue(() async {
      await _stopHardware(playEarcon: true);
      _isChangingState = false;
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Internal hardware helpers
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _stopHardware({bool playEarcon = false}) async {
    debugPrint('[VoiceService] _stopHardware(playEarcon: $playEarcon)');
    if (playEarcon) EarconService.instance.play(EarconEvent.actionDisabled);
    if (_speech.isListening) {
      await _speech.cancel();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
  }

  Future<void> _startHardware({
    required Duration listenFor,
    Duration? pauseFor,
    required bool cancelOnError,
    required bool passive,
    bool playEarcon = false,
  }) async {
    _cancelRestartTimer();
    debugPrint('[VoiceService] _startHardware(listenFor: $listenFor, passive: $passive, playEarcon: $playEarcon)');
    await _initIfNeeded();
    if (!_isInit) {
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.error;
      return;
    }

    if (playEarcon) EarconService.instance.play(EarconEvent.actionEnabled);
    ref.read(voiceCommandTextProvider.notifier).state = '';
    ref.read(lastDetectedIntentProvider.notifier).state = null;

    final started = await _speech.listen(
      onResult: _onResult,
      listenFor: listenFor,
      pauseFor: pauseFor ?? const Duration(seconds: 5),
      cancelOnError: cancelOnError,
      partialResults: true,
    );

    if (started) {
      if (passive) {
        _isPassiveMode = true;
        _isActiveMode = false;
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.passiveListening;
      } else {
        _isPassiveMode = false;
        _isActiveMode = true;
        _isPersistentActive = !cancelOnError;
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.activeListening;
      }
    } else {
      debugPrint('[VoiceService] _speech.listen failed to start.');
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
      if (passive) {
        _schedulePassiveRestart(delay: const Duration(seconds: 2));
      }
    }
  }

  Future<void> _startPassiveLoop() async {
    _isPassiveMode = true;
    await _startHardware(
      listenFor: const Duration(minutes: 1),
      pauseFor: const Duration(minutes: 1),
      cancelOnError: false,
      passive: true,
    );
  }

  void _schedulePassiveRestart({Duration delay = const Duration(milliseconds: 300)}) {
    _cancelRestartTimer();
    if (!_isPassiveMode && !_isPersistentActive) return;
    _restartTimer = Timer(delay, () {
      _restartTimer = null;
      if (_isPersistentActive) {
        _enqueue(() async {
          await _startHardware(
            listenFor: const Duration(minutes: 1),
            pauseFor: const Duration(seconds: 20),
            cancelOnError: false,
            passive: false,
          );
        });
      } else if (_isPassiveMode) {
        _enqueue(() => _startPassiveLoop());
      }
    });
  }

  void _cancelRestartTimer() {
    _restartTimer?.cancel();
    _restartTimer = null;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // speech_to_text callbacks
  // ──────────────────────────────────────────────────────────────────────────

  void _onStatus(String status) {
    debugPrint('[VoiceService] onStatus: $status (Passive: $_isPassiveMode, Active: $_isActiveMode, Persistent: $_isPersistentActive)');
    
    if (status == 'done' || status == 'notListening') {
      if (_isChangingState) {
        debugPrint('[VoiceService] onStatus: $status (Ignored, changing state)');
        return;
      }
      if (_isPassiveMode || _isPersistentActive) {
        _schedulePassiveRestart(delay: const Duration(milliseconds: 400));
      } else if (_isActiveMode) {
        _isActiveMode = false;
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
        if (!_isStopped && ref.read(appSettingsProvider).voiceNavigation) {
          debugPrint('[VoiceService] Active done. Restoring passive listening.');
          startPassiveListening();
        } else {
          EarconService.instance.play(EarconEvent.actionDisabled);
        }
      }
    } else if (status == 'listening') {
      if (_isPassiveMode) {
        ref.read(voiceCommandStatusProvider.notifier).state =
            VoiceStatus.passiveListening;
      } else {
        ref.read(voiceCommandStatusProvider.notifier).state =
            VoiceStatus.activeListening;
      }
    } else if (status == 'processing') {
      ref.read(voiceCommandStatusProvider.notifier).state =
          VoiceStatus.processing;
    }
  }

  void _onError(SpeechRecognitionError error) {
    debugPrint('[VoiceService] onError: ${error.errorMsg}');
    _isChangingState = false;
    final delay = error.errorMsg.contains('network')
        ? const Duration(seconds: 3)
        : const Duration(seconds: 1);

    if (_isPassiveMode || _isPersistentActive) {
      _schedulePassiveRestart(delay: delay);
    } else {
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.error;
      EarconService.instance.play(EarconEvent.scanFail);
      if (!_isStopped && ref.read(appSettingsProvider).voiceNavigation) {
        startPassiveListening();
      } else {
        EarconService.instance.play(EarconEvent.actionDisabled);
      }
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    final recognizedText = result.recognizedWords.toLowerCase();
    ref.read(voiceCommandTextProvider.notifier).state = recognizedText;

    if (_isPassiveMode) {
      final wakeWordRegex = RegExp(
        r'^(hey|hoy|hay|hi|hello|ok|paki|yo|hame)?\s*(ams|ms|miss|money|monie|moni|monee|mane|mani|many|mona|mone|monay|madison|mannequin)\s*(s[iey]nc[e]?|s[iey]ns[e]?|sc[iey]ns[e]?|sc[iey]nc[e]?|cents|sents|sends|sens|ence|s)?$',
        caseSensitive: false,
      );
      if (!wakeWordRegex.hasMatch(recognizedText.trim())) return;
    }

    final intent = VoiceIntentParser.parse(recognizedText);

    // Confirmation Loop: Handle Yes/No while awaiting confirmation.
    // We allow non-final results here for SNAPPY confirmation feedback.
    if (_isAwaitingConfirmation && _pendingIntent != null) {
      if (intent is SelectionConfirmationIntent) {
        final settings = ref.read(appSettingsProvider);
        final l10n = AppLocalizations.of(settings.isTagalog);
        final tts = ref.read(ttsServiceProvider);

        if (intent.isConfirmed) {
          ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.processing;
          final success = ref.read(voiceCommandExecutorProvider).execute(_pendingIntent!);
          _intentController.add(_pendingIntent!);
          if (success) {
            tts.enqueue(
              TtsMessage.result(l10n.voiceActionSuccess, id: 'voice.success'),
              enabled: settings.ttsEnabled,
              currentVerbosity: settings.ttsVerbosity,
            );
          }
          _pendingIntent = null;
          _isAwaitingConfirmation = false;
          if (settings.voiceNavigation) {
            Future.delayed(const Duration(milliseconds: 800), () => startPassiveListening());
          } else {
            stopListening();
          }
        } else {
          tts.enqueue(
            TtsMessage.result(l10n.voiceActionCancelled, id: 'voice.cancel'),
            enabled: settings.ttsEnabled,
            currentVerbosity: settings.ttsVerbosity,
          );
          _pendingIntent = null;
          _isAwaitingConfirmation = false;
          Future.delayed(const Duration(milliseconds: 800), () {
            startActiveListening();
          });
        }
        return;
      }
    }

    // Standard Intent Processing (Commands)
    // Only process these when FINAL to avoid multi-execution during speech.
    if (!result.finalResult) return;

    if (intent is WakeIntent) {
      final settings = ref.read(appSettingsProvider);
      final l10n = AppLocalizations.of(settings.isTagalog);
      ref.read(ttsServiceProvider).enqueue(
            TtsMessage.result(l10n.voicePromptWhatShallIDo, id: 'voice.prompt'),
            enabled: settings.ttsEnabled,
            currentVerbosity: settings.ttsVerbosity,
          );
      _isPassiveMode = false;
      _isActiveMode = false;
      _isPersistentActive = false;
      
      Future.delayed(const Duration(milliseconds: 800), () {
        startActiveListening();
      });
      return;
    }

    if (intent is StopSpeakingIntent ||
        intent is SelectionConfirmationIntent ||
        intent is SelectionIntent ||
        intent is StartVoiceSetupIntent) {
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.processing;
      ref.read(voiceCommandExecutorProvider).execute(intent);
      _intentController.add(intent);

      if (!_isPassiveMode) {
        if (!_isStopped && ref.read(appSettingsProvider).voiceNavigation) {
          startPassiveListening();
        } else {
          stopListening();
        }
      } else if (intent is! StopSpeakingIntent) {
        _schedulePassiveRestart(delay: const Duration(milliseconds: 800));
      }
      return;
    }

    if (intent is! UnknownIntent) {
      _pendingIntent = intent;
      _isAwaitingConfirmation = true;

      final settings = ref.read(appSettingsProvider);
      final l10n = AppLocalizations.of(settings.isTagalog);
      final tts = ref.read(ttsServiceProvider);

      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.processing;
      ref.read(lastDetectedIntentProvider.notifier).state = intent.toString().split('(').first;
      final description = intent.toDescription(l10n);

      if (!settings.clarifyVoiceCommands) {
        tts.enqueue(
          TtsMessage.result('Executing $description', id: 'voice.executing'),
          enabled: settings.ttsEnabled,
          currentVerbosity: settings.ttsVerbosity,
        );
        _intentController.add(intent);
        ref.read(voiceCommandExecutorProvider).execute(intent);
        _pendingIntent = null;
        _isAwaitingConfirmation = false;
        if (settings.voiceNavigation) {
          Future.delayed(const Duration(milliseconds: 800), () => startPassiveListening());
        } else {
          stopListening();
        }
        return;
      }

      tts.enqueue(
        TtsMessage.result('${l10n.voiceConfirmPrefix} $description${l10n.voiceConfirmSuffix}', id: 'voice.confirm_prompt'),
        enabled: settings.ttsEnabled,
        currentVerbosity: settings.ttsVerbosity,
      );

      // Increase delay to allow confirmation prompt to finish before mic re-opens
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (_isAwaitingConfirmation) {
           startActiveListening(isConfirmation: true);
        }
      });
      return;
    }

    // Default Fallback (Unknown)
    if (_isPassiveMode) {
      ref.read(voiceCommandTextProvider.notifier).state = '';
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.passiveListening;
    } else {
      EarconService.instance.play(EarconEvent.scanFail);
      if (!_isStopped && ref.read(appSettingsProvider).voiceNavigation) {
        startPassiveListening();
      } else {
        stopListening();
      }
    }
  }
}

typedef _HardwareOp = Future<void> Function();
