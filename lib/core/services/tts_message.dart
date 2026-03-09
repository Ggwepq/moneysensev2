// ---------------------------------------------------------------------------
// TtsMessage — typed speech messages
// ---------------------------------------------------------------------------
//
// Every piece of speech the app produces is modelled as a [TtsMessage].
// This keeps the "what to say" completely separate from the "how to say it".
//
// ADDING A NEW MESSAGE TYPE
// 1. Create a subclass of [TtsMessage] (or reuse an existing one).
// 2. Give it the appropriate [TtsPriority] and [TtsVerbosity].
// 3. Build the text in a *SpeechScript file using AppLocalizations.
//    Never hardcode strings inside TtsService or callers.
//
// PRIORITY ORDER (highest first)
//   critical   — must be heard, interrupts everything (e.g. error states)
//   result     — scan/detection result
//   navigation — screen transitions, setting confirmations
//   ambient    — idle prompts, hints, background context
//
// The queue processes messages in priority order.
// Within the same priority, LIFO: the newest message wins (older ones dropped).
// This is the right behaviour for navigation and ambient — if the user
// navigates quickly, only the final destination matters.

import '../../features/settings/domain/entities/app_settings.dart';

// ── Priority ────────────────────────────────────────────────────────────────

/// Speech priority. Higher ordinal = higher priority.
/// When a higher-priority message arrives mid-speech, the current utterance
/// is interrupted.
enum TtsPriority {
  ambient,    // lowest  — idle prompts, background info
  navigation, // medium  — screen transitions, toggle confirmations
  result,     // high    — scan results
  critical,   // highest — errors, camera failures, blocking warnings
}

// ── Base class ───────────────────────────────────────────────────────────────

/// A single speech request.
///
/// [text]             — The string to speak.
/// [priority]         — Determines interrupt behaviour.
/// [requiredVerbosity]— Minimum verbosity setting for this to be spoken.
/// [id]               — Optional dedup key. If a message with the same id is
///                      already in the queue, the older one is replaced.
class TtsMessage {
  const TtsMessage({
    required this.text,
    required this.priority,
    required this.requiredVerbosity,
    this.id,
  });

  final String text;
  final TtsPriority priority;
  final TtsVerbosity requiredVerbosity;

  /// Dedup / replace key. Same id = same "slot" in the queue — only the
  /// latest survives. Use a stable string per event type:
  ///   'nav.settings', 'scanner.idle', 'result.denomination'
  final String? id;

  // ── Named constructors for the three semantic tiers ───────────────────────

  /// A scan or detection result. Always fires at minimal verbosity.
  /// High priority — interrupts navigation/ambient speech.
  const TtsMessage.result(String text, {String? id})
      : this(
          text: text,
          priority: TtsPriority.result,
          requiredVerbosity: TtsVerbosity.minimal,
          id: id ?? 'result',
        );

  /// A navigation event (screen push, section focus, toggle confirmed).
  /// Fires at standard verbosity and above.
  const TtsMessage.navigation(String text, {String? id})
      : this(
          text: text,
          priority: TtsPriority.navigation,
          requiredVerbosity: TtsVerbosity.standard,
          id: id,
        );

  /// An ambient / system event (idle prompt, scanner hint, background state).
  /// Only fires at full verbosity.
  const TtsMessage.ambient(String text, {String? id})
      : this(
          text: text,
          priority: TtsPriority.ambient,
          requiredVerbosity: TtsVerbosity.full,
          id: id,
        );

  /// A critical message that always fires regardless of verbosity — use only
  /// for blocking errors (camera denied, scan failure after retries).
  const TtsMessage.critical(String text, {String? id})
      : this(
          text: text,
          priority: TtsPriority.critical,
          requiredVerbosity: TtsVerbosity.minimal,
          id: id ?? 'critical',
        );
}
