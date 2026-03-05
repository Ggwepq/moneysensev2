import 'package:flutter_test/flutter_test.dart';
import 'package:moneysensev2/core/l10n/app_localizations.dart';
import 'package:moneysensev2/core/l10n/en.dart';
import 'package:moneysensev2/core/l10n/tl.dart';

void main() {
  group('AppLocalizations', () {
    test('returns correct strings for English', () {
      final l10n = AppLocalizations.of(false);
      expect(l10n.isTagalog, false);
      expect(l10n.appName, EnStrings.appName);
      expect(l10n.settings, EnStrings.settings);
      expect(l10n.language, EnStrings.language);
      expect(l10n.languageEnglish, EnStrings.languageEnglish);
    });

    test('returns correct strings for Tagalog', () {
      final l10n = AppLocalizations.of(true);
      expect(l10n.isTagalog, true);
      expect(l10n.appName, TlStrings.appName);
      expect(l10n.settings, TlStrings.settings);
      expect(l10n.language, TlStrings.language);
      expect(l10n.languageEnglish, TlStrings.languageEnglish);
    });

    test('returns consistent strings for all keys', () {
      final en = AppLocalizations.of(false);
      final tl = AppLocalizations.of(true);

      expect(en.navSettings, isNotNull);
      expect(tl.navSettings, isNotNull);
      expect(en.navScan, isNotNull);
      expect(tl.navScan, isNotNull);
      expect(en.navTutorial, isNotNull);
      expect(tl.navTutorial, isNotNull);
      
      expect(en.sectionGeneral, isNotNull);
      expect(tl.sectionGeneral, isNotNull);
      expect(en.sectionScanning, isNotNull);
      expect(tl.sectionScanning, isNotNull);
      expect(en.sectionNavigation, isNotNull);
      expect(tl.sectionNavigation, isNotNull);
      expect(en.sectionHelpSupport, isNotNull);
      expect(tl.sectionHelpSupport, isNotNull);
    });
  });
}
