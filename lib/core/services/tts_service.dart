import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/entities/vision_config.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import 'tts_message.dart';

export 'tts_message.dart';

// ---------------------------------------------------------------------------
// TtsService — priority-queued, TalkBack-safe text-to-speech
// ---------------------------------------------------------------------------
//
// TALKBACK COEXISTENCE
//   Android TalkBack and flutter_tts both use the system TextToSpeech engine.
//   They share audio focus but NOT the same TTS channel — so they can talk
//   over each other. We mitigate this by:
//
//   1. setSharedInstance(true)        — tells iOS to share the audio session
//   2. awaitSpeakCompletion(false)    — never block the UI isolate
//   3. _accessibilityDelay           — if TalkBack appears active (checked
//      via accessibility channel), we add a short delay before speaking so
//      TalkBack's utterance has time to finish first
//   4. Priority queue + debounce     — low-priority messages are debounced
//      300 ms so rapid navigation events collapse to one utterance
//
// QUEUE BEHAVIOUR
//   - critical / result:   interrupt current speech immediately, jump queue
//   - navigation:          debounced 300 ms, same-id deduped
//   - ambient:             debounced 600 ms, same-id deduped, drops if a
//                          higher-priority message is already pending
//
// SCALABILITY
//   Callers enqueue a [TtsMessage]. They never touch FlutterTts directly.
//   Adding a new speak site = call ttsService.enqueue(TtsMessage.navigation(…))
//   Adding a new message type = subclass / factory constructor in TtsMessage.
//
// LANGUAGE
//   fil-PH → en-PH → en-US fallback chain for Tagalog.
//   Language is re-applied on every settings change via [ttsInitProvider].

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isSpeaking = false;

  // ── Priority queue ─────────────────────────────────────────────────────────
  // Stored as a list sorted by priority descending.
  // Using a simple list (small N — rarely more than 3–4 items).
  final List<TtsMessage> _queue = [];

  // Debounce timers keyed by message id
  final Map<String, Timer> _debounceTimers = {};

  // ── Accessibility / TalkBack detection ────────────────────────────────────
  static const _accessibilityChannel =
      MethodChannel('flutter/accessibility');
  bool _talkBackActive = false;

  // Delay before speaking when TalkBack is active (ms)
  static const int _talkBackDelayMs = 500;

  // ── Initialisation ─────────────────────────────────────────────────────────

  Future<void> init({
    required AppLanguage language,
    required TtsVerbosity verbosity,
  }) async {
    if (!_initialized) {
      await _tts.setSharedInstance(true);
      await _tts.awaitSpeakCompletion(false);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        _processQueue();
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
      });

      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint('[TtsService] error: $msg');
        _processQueue();
      });

      _initialized = true;
    }

    await _applyLanguage(language);
    await _applyRate(verbosity);
    await _detectTalkBack();
  }

  Future<void> _applyLanguage(AppLanguage language) async {
    if (language == AppLanguage.tagalog) {
      try {
        final langs = await _tts.getLanguages as List?;
        if (langs != null && langs.contains('fil-PH')) {
          await _tts.setLanguage('fil-PH');
          return;
        }
      } catch (_) {}
      await _tts.setLanguage('en-PH');
    } else {
      try {
        final langs = await _tts.getLanguages as List?;
        if (langs != null && langs.contains('en-PH')) {
          await _tts.setLanguage('en-PH');
          return;
        }
      } catch (_) {}
      await _tts.setLanguage('en-US');
    }
  }

  Future<void> _applyRate(TtsVerbosity verbosity) async {
    final rate = switch (verbosity) {
      TtsVerbosity.minimal  => 0.55,
      TtsVerbosity.standard => 0.50,
      TtsVerbosity.full     => 0.44,
    };
    await _tts.setSpeechRate(rate);
  }

  /// Detects whether TalkBack / VoiceOver is likely active.
  /// We use the Flutter accessibility channel — if it throws or returns null
  /// we assume not active and proceed normally.
  Future<void> _detectTalkBack() async {
    try {
      final result = await _accessibilityChannel
          .invokeMethod<bool>('isAccessibilityServiceEnabled');
      _talkBackActive = result ?? false;
    } catch (_) {
      _talkBackActive = false;
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Enqueue a [TtsMessage] for speech.
  ///
  /// [enabled]          — from appSettings.ttsEnabled
  /// [currentVerbosity] — from appSettings.ttsVerbosity
  ///
  /// The message is silently dropped if:
  ///   • TTS is disabled
  ///   • currentVerbosity < message.requiredVerbosity
  ///
  /// critical and result messages interrupt current speech immediately.
  /// navigation messages are debounced 300 ms (same-id dedup).
  /// ambient messages are debounced 600 ms and dropped if a higher-priority
  /// item is already queued.
  void enqueue(
    TtsMessage message, {
    required bool enabled,
    required TtsVerbosity currentVerbosity,
  }) {
    if (!enabled) return;
    if (!_verbosityAllows(currentVerbosity, message.requiredVerbosity)) return;

    switch (message.priority) {
      case TtsPriority.critical:
      case TtsPriority.result:
        // Cancel any pending debounce for this id
        if (message.id != null) _debounceTimers.remove(message.id)?.cancel();
        _interruptAndSpeak(message);

      case TtsPriority.navigation:
        _debounceEnqueue(message, delay: const Duration(milliseconds: 300));

      case TtsPriority.ambient:
        // Drop ambient if a result/critical is already pending
        final hasHigher = _queue.any((m) =>
            m.priority.index >= TtsPriority.result.index);
        if (hasHigher) return;
        _debounceEnqueue(message, delay: const Duration(milliseconds: 600));
    }
  }

  /// Stop all speech and clear the queue.
  Future<void> stop() async {
    for (final t in _debounceTimers.values) {
      t.cancel();
    }
    _debounceTimers.clear();
    _queue.clear();
    _isSpeaking = false;
    await _tts.stop();
  }

  // ── Internal queue management ──────────────────────────────────────────────

  void _interruptAndSpeak(TtsMessage message) {
    // Replace existing item with same id, or insert at front
    if (message.id != null) {
      _queue.removeWhere((m) => m.id == message.id);
    }
    // Insert at front (highest priority wins immediately)
    _queue.insert(0, message);
    _tts.stop().then((_) {
      _isSpeaking = false;
      _processQueue();
    });
  }

  void _debounceEnqueue(TtsMessage message, {required Duration delay}) {
    final key = message.id ?? _uniqueKey(message);

    // Cancel previous timer for same key (dedup)
    _debounceTimers.remove(key)?.cancel();

    _debounceTimers[key] = Timer(delay, () {
      _debounceTimers.remove(key);
      // Remove stale item with same id from queue before re-adding
      if (message.id != null) {
        _queue.removeWhere((m) => m.id == message.id);
      }
      // Insert in priority order
      _insertSorted(message);
      if (!_isSpeaking) _processQueue();
    });
  }

  void _insertSorted(TtsMessage message) {
    // Find first item with lower priority and insert before it
    final idx = _queue.indexWhere(
        (m) => m.priority.index < message.priority.index);
    if (idx == -1) {
      _queue.add(message);
    } else {
      _queue.insert(idx, message);
    }
  }

  void _processQueue() {
    if (_queue.isEmpty || _isSpeaking) return;
    final next = _queue.removeAt(0);
    _speak(next.text);
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    _isSpeaking = true;

    // If TalkBack is active, add a brief pause so we don't speak over it
    if (_talkBackActive) {
      await Future.delayed(Duration(milliseconds: _talkBackDelayMs));
    }

    try {
      await _tts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      debugPrint('[TtsService] speak error: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _verbosityAllows(TtsVerbosity current, TtsVerbosity required) =>
      current.index >= required.index;

  String _uniqueKey(TtsMessage m) =>
      '${m.priority.name}.${m.text.hashCode}';
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final ttsServiceProvider = Provider<TtsService>((_) => TtsService.instance);

/// Watches settings and re-initialises TTS whenever language or verbosity
/// changes.  Mount once at app root — already done in app.dart.
final ttsInitProvider = Provider<void>((ref) {
  final settings = ref.watch(appSettingsProvider);
  ref.watch(visionConfigProvider); // re-init if profile changes verbosity

  TtsService.instance.init(
    language:  settings.language,
    verbosity: settings.ttsVerbosity,
  );
});
