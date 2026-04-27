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

    // -- 0. Onboarding & Setup Commands --
    if (_matches(sanitized, [
      'start setup',
      'begin setup',
      'voice setup',
      'setup with voice',
      'simulan ang setup',
      'setup sa boses',
      'simulan ang pag-setup',
    ])) {
      return const StartVoiceSetupIntent();
    }

    // Confirmation (Yes / No)
    if (_matches(sanitized, ['yes', 'proceed', 'agree', 'oo', 'sige', 'itutuloy'])) {
      return const SelectionConfirmationIntent(true);
    }
    if (_matches(sanitized, ['no', 'cancel', 'stop setup', 'hindi', 'ayaw', 'itigil'])) {
      return const SelectionConfirmationIntent(false);
    }

    // Vision Profiles
    if (_matches(sanitized, ['low vision', 'malabo ang mata', 'malabo mata'])) {
      return const SelectionIntent('lowVision');
    }
    if (_matches(sanitized, ['partially blind', 'bahagyang bulag'])) {
      return const SelectionIntent('partiallyBlind');
    }
    if (_matches(sanitized, ['fully blind', 'total blindness', 'bulag talaga', 'bulag'])) {
      return const SelectionIntent('fullyBlind');
    }

    // Languages
    if (_matches(sanitized, ['english', 'ingles'])) {
      return const SelectionIntent('english');
    }
    if (_matches(sanitized, ['tagalog', 'filipino'])) {
      return const SelectionIntent('tagalog');
    }

    // Navigation Styles
    if (_matches(sanitized, ['standard', 'buttons', 'bottom bar', 'karaniwan', 'normal'])) {
      return const SelectionIntent('standard');
    }
    if (_matches(sanitized, ['gestural', 'swipe', 'gestures', 'pagswipe', 'pag-swipe'])) {
      return const SelectionIntent('gestural');
    }
    if (_matches(sanitized, ['inertial', 'tilt', 'tilting', 'pag-tilt', 'pagtilt'])) {
      return const SelectionIntent('inertial');
    }
    if (_matches(sanitized, ['voice', 'commands', 'paggamit ng boses', 'pagsasalita'])) {
      return const SelectionIntent('voice');
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
      'skip',
      'bypass',
      'next',
      'jump',
      'proceed anyway',
    ])) {
      return const SkipIntent();
    }

    if (_matches(sanitized, [
      'retry',
      'try again',
      'one more time',
      'repeat',
      'ulit',
      'isa pa',
      'subukan ulit',
      'ulitin',
    ])) {
      return const RetryIntent();
    }

    if (_matches(sanitized, [
      'identify',
      'read bill',
      'what is this',
      'what bill is this',
      'what money is this',
      'identifikahin',
      'anong pera ito',
      'ano ito',
      'basahin ang bill',
      'anong bill ito',
    ])) {
      return const IdentifyIntent();
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

    // -- 4. Settings Modification Commands --
    
    // Language
    if (_matches(sanitized, ['use english', 'set language to english', 'ingles'])) {
      return const ChangeLanguageIntent('english');
    }
    if (_matches(sanitized, ['use tagalog', 'set language to tagalog', 'tagalog'])) {
      return const ChangeLanguageIntent('tagalog');
    }

    // Theme / Dark Mode
    if (_matches(sanitized, ['dark mode', 'set theme to dark', 'itim na tema', 'dark theme'])) {
      return const ChangeThemeIntent('dark');
    }
    if (_matches(sanitized, ['light mode', 'set theme to light', 'puting tema', 'light theme'])) {
      return const ChangeThemeIntent('light');
    }
    if (_matches(sanitized, ['system theme', 'default theme', 'automatic theme'])) {
      return const ChangeThemeIntent('system');
    }

    // Font Size
    if (_matches(sanitized, ['large font', 'big text', 'malaking letra', 'set font to large'])) {
      return const ChangeFontSizeIntent('large');
    }
    if (_matches(sanitized, ['regular font', 'normal text', 'katamtamang letra', 'set font to regular'])) {
      return const ChangeFontSizeIntent('regular');
    }
    if (_matches(sanitized, ['small font', 'small text', 'maliit na letra', 'set font to small'])) {
      return const ChangeFontSizeIntent('small');
    }

    // Speech Rate
    if (_matches(sanitized, ['fast speech', 'speak faster', 'bilisan ang pagsasalita'])) {
      return const ChangeSpeechRateIntent('fast');
    }
    if (_matches(sanitized, ['normal speech', 'regular speech', 'normal na bilis'])) {
      return const ChangeSpeechRateIntent('normal');
    }
    if (_matches(sanitized, ['slow speech', 'speak slower', 'bagalan ang pagsasalita'])) {
      return const ChangeSpeechRateIntent('slow');
    }

    // Verbosity
    if (_matches(sanitized, ['full description', 'high verbosity', 'maraming detalye'])) {
      return const ChangeVerbosityIntent('full');
    }
    if (_matches(sanitized, ['standard description', 'normal verbosity', 'katamtamang detalye'])) {
      return const ChangeVerbosityIntent('standard');
    }
    if (_matches(sanitized, ['concise description', 'minimal verbosity', 'kaunting detalye', 'minimal description'])) {
      return const ChangeVerbosityIntent('minimal');
    }

    // Vision Profile
    if (_matches(sanitized, ['low vision', 'malabo ang mata', 'set profile to low vision'])) {
      return const ChangeVisionProfileIntent('lowVision');
    }
    if (_matches(sanitized, ['partially blind', 'bahagyang bulag', 'set profile to partially blind'])) {
      return const ChangeVisionProfileIntent('partiallyBlind');
    }
    if (_matches(sanitized, ['fully blind', 'total blindness', 'bulag talaga', 'complete blindness', 'set profile to fully blind'])) {
      return const ChangeVisionProfileIntent('fullyBlind');
    }

    // -- 5. Navigation & Shortcuts (Keywords) --
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
    final t = text.toLowerCase().trim();
    for (final kw in keywords) {
      if (t.contains(kw.toLowerCase())) return true;
    }
    return false;
  }
}
