import 'voice_intent.dart';

/// Parses raw text strings into modular `VoiceIntent`s.
class VoiceIntentParser {
  /// Parses the recognized [text] and returns the best matching [VoiceIntent].
  static VoiceIntent parse(String text) {
    final lowerStr = text.toLowerCase().trim();

    // Consistent, flexible wake-word regex shared with the service
    final wakeWordRegex = RegExp(
      r'(hey|hoy|hay|hi|hello|ok|paki|yo|hame)?\s*(ams|ms|miss|money|monie|moni|monee|mane|mani|many|mona|mone|monay|madison|mannequin)\s*(s[iey]nc[e]?|s[iey]ns[e]?|sc[iey]ns[e]?|sc[iey]nc[e]?|cents|sents|sends|sens|ence|s)?',
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

    // -- 1. High Priority System Commands (Specific phrases) --
    if (_matches(sanitized, [
      'stop speaking',
      'be quiet',
      'shut up',
      'silence',
      'hush',
      'stop talking',
      'quiet',
      'tumigil ka',
      'tahimik',
      'hinto',
      'ihinto',
      'wag ka na magsalita',
      'ayaw ko na makinig',
    ])) {
      return const StopSpeakingIntent();
    }

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

    // -- 2. Composite Help Commands (Checked before general keywords like "scan" or "voice") --
    if (_matches(sanitized, [
      'help voice',
      'help commands',
      'help say',
      'how to speak',
      'voice tutorial',
      'speech tutorial',
      'tulong sa boses',
      'tulong sa pagsasalita',
      'tulong sa commands',
      'paano magsalita',
    ])) {
      return const HelpIntent(HelpTarget.voice);
    }

    if (_matches(sanitized, [
      'help gestural',
      'help gestures',
      'how to swipe',
      'help swipe',
      'gestural tutorial',
      'tap and swipe',
      'tulong sa pag-swipe',
      'tulong sa pag-tap',
      'tulong sa gestures',
      'paano mag-swipe',
    ])) {
      return const HelpIntent(HelpTarget.gestural);
    }

    if (_matches(sanitized, [
      'help inertial',
      'help tilt',
      'how to move',
      'help with movement',
      'tilt tutorial',
      'tulong sa paggalaw',
      'tulong sa pag-tilt',
      'tulong sa pag-ikot',
      'paano gumalaw',
    ])) {
      return const HelpIntent(HelpTarget.inertial);
    }

    if (_matches(sanitized, [
      'help scanning',
      'help scanner',
      'help scan',
      'how to scan',
      'scan tutorial',
      'camera tutorial',
      'tulong sa pag-scan',
      'tulong sa pag-detect',
      'tulong sa scanner',
      'paano mag-scan',
    ])) {
      return const HelpIntent(HelpTarget.scanning);
    }

    if (_matches(sanitized, [
      'help',
      'what can i say',
      'tulong',
      'tulong po',
      'ano ang sasabihin',
    ])) {
      return const HelpIntent(HelpTarget.general);
    }

    // -- 3. Scanning & Hardware (Multi-word phrases first) --
    if (_matches(sanitized, [
      'stop scan',
      'pause scan',
      'stop camera',
      'patayin ang camera',
    ])) {
      return const PauseScanIntent();
    }

    if (_matches(sanitized, [
      'start scan',
      'begin scan',
      'read money',
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

    // -- 4. Navigation & Shortcuts (Keywords) --
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
    if (_matches(sanitized, [
      'tutorial',
      'open tutorial',
      'paano gamitin',
    ])) {
      return const NavigateIntent(NavTarget.tutorial);
    }

    if (_matches(sanitized, [
      'list commands',
      'command list',
      'show commands',
      'commands',
      'ano ang mga utos',
      'mga utos',
      'lista ng utos',
    ])) {
      return const NavigateIntent(NavTarget.commandList);
    }

    // -- 5. Single Keyword Fallbacks (Last resort) --
    if (_matches(sanitized, ['stop', 'hinto'])) {
      return const PauseScanIntent();
    }
    if (_matches(sanitized, ['scan', 'basahin'])) {
      return const ScanIntent();
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
