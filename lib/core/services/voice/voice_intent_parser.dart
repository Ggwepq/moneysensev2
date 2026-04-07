import 'voice_intent.dart';

/// Parses raw text strings into modular `VoiceIntent`s.
class VoiceIntentParser {
  /// Parses the recognized [text] and returns the best matching [VoiceIntent].
  static VoiceIntent parse(String text) {
    final lowerStr = text.toLowerCase().trim();

    // Consistent, flexible wake-word regex shared with the service
    final wakeWordRegex = RegExp(
      r'(hey|hoy|hay|hi|hello|ok|paki|yo)?\s*(money|monie|moni|monee|mane|mani|many|mona|mone|monay)\s*(s[iey]nc[e]?|s[iey]ns[e]?|sc[iey]ns[e]?|sc[iey]nc[e]?|cents|sents|sends|sens|ence)',
      caseSensitive: false,
    );

    // Remove common wake words or polite fillers to extract the bare command.
    final sanitized = lowerStr
        .replaceAll(wakeWordRegex, '')
        .replaceAll('please', '')
        .trim();

    if (sanitized.isEmpty) {
      if (wakeWordRegex.hasMatch(lowerStr)) {
        return const WakeIntent();
      }
      return UnknownIntent(text);
    }

    // ── Scanning ─────────────────────────────────────────────────────────────
    if (_matches(sanitized, [
      'stop scan',
      'pause scan',
      'stop camera',
      'patayin ang camera',
      'hinto',
      'stop',
    ])) {
      return const PauseScanIntent();
    }

    if (_matches(sanitized, [
      'scan',
      'start scan',
      'begin scan',
      'read money',
      'basahin',
      'mag scan',
      'scan pera',
      'open camera',
      'start camera',
      'buksan ang camera',
      'ibukas ang camera',
      'basahin ang pera',
    ])) {
      return const ScanIntent();
    }

    // ── Navigation ───────────────────────────────────────────────────────────
    if (_matches(sanitized, [
      'settings',
      'open settings',
      'go to settings',
      'buksan ang settings',
      'menu',
    ])) {
      return const NavigateIntent(NavTarget.settings);
    }
    if (_matches(sanitized, [
      'home',
      'go home',
      'scanner',
      'open scanner',
      'bumalik sa home',
      'uwi',
    ])) {
      return const NavigateIntent(NavTarget.home);
    }
    if (_matches(sanitized, ['tutorial', 'help', 'tulong', 'open tutorial'])) {
      return const NavigateIntent(NavTarget.tutorial);
    }

    // ── Camera hardware ──────────────────────────────────────────────────────
    if (_matches(sanitized, [
      'front camera',
      'use front camera',
      'harap na camera',
      'selfie camera',
    ])) {
      return const ChangeCameraIntent(toFront: true);
    }
    if (_matches(sanitized, [
      'back camera',
      'use back camera',
      'likod na camera',
      'main camera',
    ])) {
      return const ChangeCameraIntent(toFront: false);
    }

    // ── System ───────────────────────────────────────────────────────────────
    if (_matches(sanitized, [
      'close app',
      'exit',
      'quit',
      'sara ang app',
      'isara',
      'close moneysense',
    ])) {
      return const ExitAppIntent();
    }
    if (_matches(sanitized, [
      'turn on flash',
      'turn on flashlight',
      'flash on',
      'light on',
      'flashlight on',
      'buksan ang ilaw',
      'ilaw on',
    ])) {
      return const ToggleFlashlightIntent(true);
    }
    if (_matches(sanitized, [
      'turn off flash',
      'turn off flashlight',
      'flash off',
      'light off',
      'flashlight off',
      'patayin ang ilaw',
      'ilaw off',
    ])) {
      return const ToggleFlashlightIntent(false);
    }

    // Unmatched
    return UnknownIntent(text);
  }

  /// Helper to check if [text] exactly matches or contains one of the [keywords]
  static bool _matches(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (text.contains(kw)) return true;
    }
    return false;
  }
}
