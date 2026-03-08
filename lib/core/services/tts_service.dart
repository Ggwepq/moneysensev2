import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/entities/vision_config.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

// ---------------------------------------------------------------------------
// TtsService — text-to-speech wrapper
// ---------------------------------------------------------------------------
//
// VERBOSITY GATE
// Every speak method carries a [TtsVerbosity] requirement.  The service only
// speaks if the user's current verbosity level is >= the requirement:
//
//   minimal  → only speaks if called with TtsVerbosity.minimal
//   standard → speaks for minimal + standard calls
//   full     → speaks for minimal + standard + full calls
//
// USAGE
// Callers never build speech strings here.  They call named semantic methods:
//
//   tts.result('₱100')                  // scan result — always minimal
//   tts.navigation('Settings opened')   // nav event   — standard+
//   tts.system('Scanner is idle')       // system info — full only
//   tts.speak('anything', TtsVerbosity.standard)  // raw escape hatch
//
// LANGUAGE
// Filipino (Tagalog) uses the same TTS engine — we set language to 'fil-PH'
// when available and fall back to 'en-PH' then 'en-US'.

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  // ── Initialisation ─────────────────────────────────────────────────────────

  Future<void> init({required AppLanguage language}) async {
    if (_initialized) {
      await _applyLanguage(language);
      return;
    }

    await _tts.setSharedInstance(true);        // iOS: share audio session
    await _tts.awaitSpeakCompletion(false);    // never block the UI thread
    await _tts.setSpeechRate(0.5);             // comfortable for all profiles
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _applyLanguage(language);

    _initialized = true;
  }

  Future<void> _applyLanguage(AppLanguage language) async {
    if (language == AppLanguage.tagalog) {
      final langs = await _tts.getLanguages as List?;
      if (langs != null && langs.contains('fil-PH')) {
        await _tts.setLanguage('fil-PH');
      } else {
        await _tts.setLanguage('en-PH');       // Filipino accent fallback
      }
    } else {
      await _tts.setLanguage('en-PH');
    }
  }

  // ── Core speak ─────────────────────────────────────────────────────────────

  /// Speak [text] if TTS is enabled and [requiredVerbosity] is satisfied.
  Future<void> speak(
    String text, {
    required bool ttsEnabled,
    required TtsVerbosity currentVerbosity,
    required TtsVerbosity requiredVerbosity,
  }) async {
    if (!ttsEnabled) return;
    if (!_verbosityAllows(currentVerbosity, requiredVerbosity)) return;
    await _tts.stop();   // interrupt any in-progress speech
    await _tts.speak(text);
  }

  /// Stop any currently playing speech immediately.
  Future<void> stop() => _tts.stop();

  // ── Named semantic speak methods ───────────────────────────────────────────
  // Each method signals its verbosity requirement at the call site.

  /// Speak a scan result.  Always fires at [TtsVerbosity.minimal].
  Future<void> result(
    String text, {
    required bool ttsEnabled,
    required TtsVerbosity currentVerbosity,
  }) =>
      speak(
        text,
        ttsEnabled: ttsEnabled,
        currentVerbosity: currentVerbosity,
        requiredVerbosity: TtsVerbosity.minimal,
      );

  /// Speak a navigation event (screen push/pop, section change).
  /// Fires at [TtsVerbosity.standard] and above.
  Future<void> navigation(
    String text, {
    required bool ttsEnabled,
    required TtsVerbosity currentVerbosity,
  }) =>
      speak(
        text,
        ttsEnabled: ttsEnabled,
        currentVerbosity: currentVerbosity,
        requiredVerbosity: TtsVerbosity.standard,
      );

  /// Speak a system / ambient event (idle prompt, scanner state).
  /// Only fires at [TtsVerbosity.full].
  Future<void> system(
    String text, {
    required bool ttsEnabled,
    required TtsVerbosity currentVerbosity,
  }) =>
      speak(
        text,
        ttsEnabled: ttsEnabled,
        currentVerbosity: currentVerbosity,
        requiredVerbosity: TtsVerbosity.full,
      );

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns true if [current] verbosity level allows speaking at [required].
  ///
  /// Verbosity levels are ordered: minimal < standard < full.
  /// A higher level (fuller) allows speaking all lower-requirement content.
  bool _verbosityAllows(TtsVerbosity current, TtsVerbosity required) {
    return current.index >= required.index;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// App-scoped [TtsService] singleton.
///
/// Initialised lazily on first use; re-initialises language when settings
/// change (handled by [TtsServiceNotifier]).
final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService.instance;
});

/// Watches settings and re-applies language + speech rate when they change.
/// Mount this once at the app root (e.g. in MoneySenseApp build).
final ttsInitProvider = Provider<void>((ref) {
  final settings = ref.watch(appSettingsProvider);
  final config   = ref.watch(visionConfigProvider);

  TtsService.instance.init(language: settings.language).then((_) {
    // Adjust speech rate based on verbosity — faster for minimal (less speech
    // overall so each utterance can be brisker), slower for full (lots of
    // speech; slower is less overwhelming).
    final rate = switch (settings.ttsVerbosity) {
      TtsVerbosity.minimal  => 0.55,
      TtsVerbosity.standard => 0.50,
      TtsVerbosity.full     => 0.44,
    };
    TtsService.instance._tts.setSpeechRate(rate);
  });
});
