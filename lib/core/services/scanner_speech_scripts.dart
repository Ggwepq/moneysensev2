// TTS messages specific to the scanner: results, idle hints, and errors.
// All text comes from AppLocalizations. To add a new message, add a static
// method here, add its strings to en.dart and tl.dart, then call it via ttsService.enqueue().

import '../../core/l10n/app_localizations.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import 'tts_message.dart';

abstract final class ScannerSpeech {

  // ── Results ──────────────────────────────────────────────────────────────

  /// The main denomination result: always spoken at minimal verbosity.
  ///
  /// At [minimal]: just the denomination, e.g. "One hundred pesos"
  /// At [standard/full]: denomination + type, e.g. "One hundred peso bill"
  /// At [full] only: also includes confidence hint if below 80%
  static TtsMessage denominationResult({
    required AppLocalizations l10n,
    required String denomination,
    required String type,         // "bill" or "coin"
    required double confidence,
    required TtsVerbosity verbosity,
  }) {
    final String text;

    if (verbosity == TtsVerbosity.minimal) {
      // Short and clean: just say the amount
      text = l10n.ttsScanResult(denomination);
    } else if (verbosity == TtsVerbosity.standard) {
      // Denomination + type
      text = l10n.ttsScanResultWithType(denomination, type);
    } else {
      // Full: denomination + type + confidence warning if low
      if (confidence < 0.80) {
        text = l10n.ttsScanResultLowConfidence(denomination, type);
      } else {
        text = l10n.ttsScanResultWithType(denomination, type);
      }
    }

    return TtsMessage.result(text, id: 'scanner.result');
  }

  // ── Camera state ─────────────────────────────────────────────────────────

  /// Camera opened: spoken at standard+ verbosity.
  static TtsMessage cameraOpened(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsCameraOpened, id: 'scanner.cameraOpened');

  /// Camera closed: spoken at standard+ verbosity.
  static TtsMessage cameraClosed(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsCameraClosed, id: 'scanner.cameraClosed');

  /// Preview frozen (double-tap): spoken at standard+ verbosity.
  static TtsMessage previewFrozen(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsPreviewFrozen, id: 'scanner.frozen');

  /// Preview resumed: spoken at standard+ verbosity.
  static TtsMessage previewResumed(AppLocalizations l10n) =>
      TtsMessage.navigation(l10n.ttsPreviewResumed, id: 'scanner.resumed');

  /// Flashlight toggled.
  static TtsMessage flashToggled(AppLocalizations l10n, bool isOn) =>
      TtsMessage.navigation(
        isOn ? l10n.ttsFlashOn : l10n.ttsFlashOff,
        id: 'scanner.flash',
      );

  // ── Scanning hints (ambient: only at full verbosity) ────────────────────

  /// Spoken after the scanner has been idle for several seconds.
  static TtsMessage idleHint(AppLocalizations l10n) =>
      TtsMessage.ambient(l10n.ttsScannerIdle, id: 'scanner.idle');

  /// Spoken when scanning starts.
  static TtsMessage scanStarted(AppLocalizations l10n) =>
      TtsMessage.ambient(l10n.ttsScanStarted, id: 'scanner.scanning');

  /// Spoken while processing (ML inference running).
  static TtsMessage processing(AppLocalizations l10n) =>
      TtsMessage.ambient(l10n.ttsProcessing, id: 'scanner.processing');

  // ── Errors ───────────────────────────────────────────────────────────────

  /// Camera permission denied.
  static TtsMessage cameraPermissionDenied(AppLocalizations l10n) =>
      TtsMessage.critical(l10n.ttsCameraPermissionDenied,
          id: 'scanner.permDenied');

  /// Scanner failed to identify after multiple attempts.
  static TtsMessage scanFailed(AppLocalizations l10n) =>
      TtsMessage.critical(l10n.ttsScanFailed, id: 'scanner.failed');

  /// General camera error.
  static TtsMessage cameraError(AppLocalizations l10n) =>
      TtsMessage.critical(l10n.ttsCameraError, id: 'scanner.cameraError');
}
