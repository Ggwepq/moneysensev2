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

  // ── Serialised hardware access ─────────────────────────────────────────────
  // All start/stop calls are funnelled through a single mutex so overlapping
  // calls (e.g. a gesture fires while the passive loop is restarting) never race.

  final _opQueue = <_HardwareOp>[];
  bool _opRunning = false;

  // ── Confirmation loop ──────────────────────────────────────────────────────

  VoiceIntent? _pendingIntent;
  bool _isAwaitingConfirmation = false;

  // ── Passive restart timer ─────────────────────────────────────────────────

  Timer? _restartTimer;

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

  /// Triggers an active listening session.
  ///
  /// [persistent]  – auto-restart when the microphone times out (onboarding).
  /// [withPrompt]  – play "I'm listening" before opening the mic.
  Future<void> startActiveListening({
    bool persistent = false,
    bool withPrompt = false,
  }) async {
    _cancelRestartTimer();
    _isStopped = false;
    _isPassiveMode = false;
    _isPersistentActive = persistent;

    if (withPrompt) {
      final settings = ref.read(appSettingsProvider);
      final l10n = AppLocalizations.of(settings.isTagalog);
      ref
          .read(ttsServiceProvider)
          .enqueue(
            TtsMessage.result(
              l10n.voiceListeningFeedback,
              id: 'voice.listening_start',
            ),
            enabled: settings.ttsEnabled,
            currentVerbosity: settings.ttsVerbosity,
          );
    }

    _enqueue(() async {
      await _stopHardware(playEarcon: false);
      await _startHardware(
        listenFor: persistent
            ? const Duration(minutes: 1)
            : const Duration(seconds: 10),
        pauseFor: persistent ? const Duration(seconds: 20) : null,
        cancelOnError: !persistent,
        passive: false,
        playEarcon: true,
      );
    });
  }

  /// Triggers a continuous passive (wake-word) listening session.
  Future<void> startPassiveListening() async {
    if (_isPassiveMode) return;
    _isStopped = false;
    _isPassiveMode = true;
    _isPersistentActive = false;
    _cancelRestartTimer();

    _enqueue(() async {
      await _stopHardware();
      await _startPassiveLoop();
    });
  }

  /// Immediately stops both active and passive listening.
  Future<void> stopListening() async {
    _cancelRestartTimer();
    _isStopped = true;
    _isPassiveMode = false;
    _isPersistentActive = false;
    _isAwaitingConfirmation = false;
    _pendingIntent = null;

    _enqueue(() async {
      await _stopHardware(playEarcon: true);
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Internal hardware helpers
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _stopHardware({bool playEarcon = false}) async {
    ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
    if (playEarcon) EarconService.instance.play(EarconEvent.actionDisabled);
    if (_speech.isListening) {
      await _speech.cancel();
      // Increase delay to give the native SpeechRecognizer ample time to release the mic
      await Future.delayed(const Duration(milliseconds: 350));
    }
  }

  Future<void> _startHardware({
    required Duration listenFor,
    Duration? pauseFor,
    required bool cancelOnError,
    required bool passive,
    bool playEarcon = false,
  }) async {
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
      pauseFor: pauseFor,
      cancelOnError: cancelOnError,
      partialResults: true,
    );

    if (started) {
      ref.read(voiceCommandStatusProvider.notifier).state = passive
          ? VoiceStatus.passiveListening
          : VoiceStatus.activeListening;
    } else {
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
      if (passive) {
        _schedulePassiveRestart(delay: const Duration(seconds: 3));
      }
    }
  }

  Future<void> _startPassiveLoop() async {
    if (!_isPassiveMode) return;
    await _startHardware(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      cancelOnError: false,
      passive: true,
    );
  }

  void _schedulePassiveRestart({
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _cancelRestartTimer();
    if (!_isPassiveMode) return;
    _restartTimer = Timer(delay, () {
      _restartTimer = null;
      if (!_isPassiveMode) return;
      _enqueue(() => _startPassiveLoop());
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
    if (status == 'done' || status == 'notListening') {
      if (_isPassiveMode) {
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
        _schedulePassiveRestart();
      } else if (_isPersistentActive) {
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
        _cancelRestartTimer();
        _restartTimer = Timer(const Duration(milliseconds: 300), () {
          _restartTimer = null;
          if (!_isPersistentActive) return;
          _enqueue(() async {
            await _startHardware(
              listenFor: const Duration(minutes: 1),
              pauseFor: const Duration(seconds: 20),
              cancelOnError: false,
              passive: false,
            );
          });
        });
      } else {
        ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;

        if (!_isStopped && ref.read(appSettingsProvider).voiceNavigation) {
          startPassiveListening();
        } else {
          EarconService.instance.play(EarconEvent.actionDisabled);
        }
      }
    }
  }

  void _onError(SpeechRecognitionError error) {
    final delay = error.errorMsg.contains('network')
        ? const Duration(seconds: 3)
        : const Duration(seconds: 1);

    if (_isPassiveMode) {
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
      _schedulePassiveRestart(delay: delay);
    } else if (_isPersistentActive) {
      ref.read(voiceCommandStatusProvider.notifier).state = VoiceStatus.idle;
      _cancelRestartTimer();
      _restartTimer = Timer(delay, () {
        _restartTimer = null;
        if (!_isPersistentActive) return;
        _enqueue(() async {
          await _startHardware(
            listenFor: const Duration(minutes: 1),
            pauseFor: const Duration(seconds: 20),
            cancelOnError: false,
            passive: false,
          );
        });
      });
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

    // Always update the live-text provider so the UI feels responsive.
    ref.read(voiceCommandTextProvider.notifier).state = recognizedText;

    // ── Wake-word gate (passive mode only) ────────────────────────────────
    if (_isPassiveMode) {
      final wakeWordRegex = RegExp(
        r'(hey|hoy|hay|hi|hello|ok|paki|yo|hame)?\s*(ams|ms|miss|money|monie|moni|monee|mane|mani|many|mona|mone|monay|madison|mannequin)\s*(s[iey]nc[e]?|s[iey]ns[e]?|sc[iey]ns[e]?|sc[iey]nc[e]?|cents|sents|sends|sens|ence|s)?',
        caseSensitive: false,
      );
      if (!wakeWordRegex.hasMatch(recognizedText)) return;
    }

    final intent = VoiceIntentParser.parse(recognizedText);

    // ── Confirmation loop ─────────────────────────────────────────────────
    if (_isAwaitingConfirmation &&
        _pendingIntent != null &&
        result.finalResult) {
      if (intent is SelectionConfirmationIntent) {
        final settings = ref.read(appSettingsProvider);
        final l10n = AppLocalizations.of(settings.isTagalog);
        final tts = ref.read(ttsServiceProvider);

        if (intent.isConfirmed) {
          ref.read(voiceCommandStatusProvider.notifier).state =
              VoiceStatus.processing;
          final success = ref
              .read(voiceCommandExecutorProvider)
              .execute(_pendingIntent!);
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

          if (_isPassiveMode) {
            _schedulePassiveRestart(delay: const Duration(milliseconds: 600));
          } else {
            if (!_isStopped && ref.read(appSettingsProvider).voiceNavigation) {
              Future.delayed(
                const Duration(milliseconds: 600),
                () => startPassiveListening(),
              );
            } else {
              stopListening();
            }
          }
        } else {
          tts.enqueue(
            TtsMessage.result(l10n.voiceActionCancelled, id: 'voice.cancel'),
            enabled: settings.ttsEnabled,
            currentVerbosity: settings.ttsVerbosity,
          );
          _pendingIntent = null;
          _isAwaitingConfirmation = false;

          Future.delayed(const Duration(milliseconds: 600), () {
            startActiveListening();
          });
        }
        return;
      }
    }

    // ── Wake word ─────────────────────────────────────────────────────────
    if (intent is WakeIntent) {
      if (_isPassiveMode) {
        final settings = ref.read(appSettingsProvider);
        final l10n = AppLocalizations.of(settings.isTagalog);
        ref
            .read(ttsServiceProvider)
            .enqueue(
              TtsMessage.result(
                l10n.voicePromptWhatShallIDo,
                id: 'voice.prompt',
              ),
              enabled: settings.ttsEnabled,
              currentVerbosity: settings.ttsVerbosity,
            );
        // Flip out of passive mode BEFORE calling startActiveListening so
        // the flag check inside startPassiveListening doesn't re-enter.
        _isPassiveMode = false;
        Future.delayed(const Duration(milliseconds: 250), () {
          startActiveListening();
        });
      }
      return;
    }

    // ── Instant intents (no confirmation) ────────────────────────────────
    if (intent is StopSpeakingIntent ||
        intent is SelectionConfirmationIntent ||
        intent is SelectionIntent ||
        intent is StartVoiceSetupIntent) {
      ref.read(voiceCommandStatusProvider.notifier).state =
          VoiceStatus.processing;
      ref.read(voiceCommandExecutorProvider).execute(intent);
      _intentController.add(intent);

      if (!_isPassiveMode) {
        if (!_isStopped && ref.read(appSettingsProvider).voiceNavigation) {
          startPassiveListening();
        } else {
          stopListening();
        }
      } else if (intent is! StopSpeakingIntent) {
        _schedulePassiveRestart(delay: const Duration(milliseconds: 600));
      }
      return;
    }

    // ── Standard commands: confirmation loop ──────────────────────────────
    if (intent is! UnknownIntent && result.finalResult) {
      _pendingIntent = intent;
      _isAwaitingConfirmation = true;

      final settings = ref.read(appSettingsProvider);
      final l10n = AppLocalizations.of(settings.isTagalog);
      final tts = ref.read(ttsServiceProvider);

      ref.read(voiceCommandStatusProvider.notifier).state =
          VoiceStatus.processing;
      ref.read(lastDetectedIntentProvider.notifier).state = intent
          .toString()
          .split('(')
          .first;

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

        if (_isPassiveMode) {
          _schedulePassiveRestart(delay: const Duration(milliseconds: 600));
        } else {
          if (!_isStopped && settings.voiceNavigation) {
            Future.delayed(
              const Duration(milliseconds: 600),
              () => startPassiveListening(),
            );
          } else {
            stopListening();
          }
        }
        return;
      }

      tts.enqueue(
        TtsMessage.result(
          '${l10n.voiceConfirmPrefix} $description${l10n.voiceConfirmSuffix}',
          id: 'voice.confirm_prompt',
        ),
        enabled: settings.ttsEnabled,
        currentVerbosity: settings.ttsVerbosity,
      );

      // Give TTS a moment to start, then reopen the mic for Yes/No.
      Future.delayed(const Duration(milliseconds: 400), () {
        startActiveListening();
      });
      return;
    }

    // ── Unknown final result ──────────────────────────────────────────────
    if (!result.finalResult) return;

    ref.read(voiceCommandStatusProvider.notifier).state =
        VoiceStatus.processing;
    ref.read(voiceCommandExecutorProvider).execute(intent);

    if (!_isPassiveMode) {
      EarconService.instance.play(EarconEvent.scanFail);
      if (!_isStopped && ref.read(appSettingsProvider).voiceNavigation) {
        startPassiveListening();
      } else {
        stopListening();
      }
    } else {
      ref.read(voiceCommandTextProvider.notifier).state = '';
      ref.read(voiceCommandStatusProvider.notifier).state =
          VoiceStatus.passiveListening;
    }
  }
}

/// Typedef for a queued hardware operation.
typedef _HardwareOp = Future<void> Function();
