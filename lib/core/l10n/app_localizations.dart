import 'en.dart';
import 'tl.dart';

/// Simple localizations helper.
///
/// Usage: `AppLocalizations.of(context).settings`
///
/// For production, replace with `flutter_localizations` ARB-based approach.
/// This implementation keeps things readable while the project is in early
/// development.
class AppLocalizations {
  final bool isTagalog;
  const AppLocalizations({required this.isTagalog});

  // ── Factory ───────────────────────────────────────────────────────────────
  static AppLocalizations of(bool isTagalog) =>
      AppLocalizations(isTagalog: isTagalog);

  // ── String Accessors ──────────────────────────────────────────────────────
  String get appName =>
      isTagalog ? TlStrings.appName : EnStrings.appName;
  String get navSettings =>
      isTagalog ? TlStrings.navSettings : EnStrings.navSettings;
  String get navScan =>
      isTagalog ? TlStrings.navScan : EnStrings.navScan;
  String get navTutorial =>
      isTagalog ? TlStrings.navTutorial : EnStrings.navTutorial;
  String get settings =>
      isTagalog ? TlStrings.settings : EnStrings.settings;

  // Sections
  String get sectionGeneral =>
      isTagalog ? TlStrings.sectionGeneral : EnStrings.sectionGeneral;
  String get sectionScanning =>
      isTagalog ? TlStrings.sectionScanning : EnStrings.sectionScanning;
  String get sectionNavigation =>
      isTagalog ? TlStrings.sectionNavigation : EnStrings.sectionNavigation;
  String get sectionHelpSupport =>
      isTagalog ? TlStrings.sectionHelpSupport : EnStrings.sectionHelpSupport;

  // General
  String get theme => isTagalog ? TlStrings.theme : EnStrings.theme;
  String get themeSystem =>
      isTagalog ? TlStrings.themeSystem : EnStrings.themeSystem;
  String get themeLight =>
      isTagalog ? TlStrings.themeLight : EnStrings.themeLight;
  String get themeDark =>
      isTagalog ? TlStrings.themeDark : EnStrings.themeDark;
  String get language => isTagalog ? TlStrings.language : EnStrings.language;
  String get languageEnglish =>
      isTagalog ? TlStrings.languageEnglish : EnStrings.languageEnglish;
  String get languageTagalog =>
      isTagalog ? TlStrings.languageTagalog : EnStrings.languageTagalog;
  String get fontSize =>
      isTagalog ? TlStrings.fontSize : EnStrings.fontSize;
  String get fontSizeSubtitle =>
      isTagalog ? TlStrings.fontSizeSubtitle : EnStrings.fontSizeSubtitle;

  // Scanning
  String get useFrontCamera =>
      isTagalog ? TlStrings.useFrontCamera : EnStrings.useFrontCamera;
  String get useFlashlight =>
      isTagalog ? TlStrings.useFlashlight : EnStrings.useFlashlight;
  String get denominationVibration =>
      isTagalog ? TlStrings.denominationVibration : EnStrings.denominationVibration;

  // Navigation
  String get shakeToGoBack =>
      isTagalog ? TlStrings.shakeToGoBack : EnStrings.shakeToGoBack;
  String get goBackTimerOnResult =>
      isTagalog ? TlStrings.goBackTimerOnResult : EnStrings.goBackTimerOnResult;
  String get gesturalNavigation =>
      isTagalog ? TlStrings.gesturalNavigation : EnStrings.gesturalNavigation;
  String get inertialNavigation =>
      isTagalog ? TlStrings.inertialNavigation : EnStrings.inertialNavigation;

  // Help & Support
  String get checkForUpdates =>
      isTagalog ? TlStrings.checkForUpdates : EnStrings.checkForUpdates;
  String get playOnboardingSetup =>
      isTagalog ? TlStrings.playOnboardingSetup : EnStrings.playOnboardingSetup;
  String get appInformation =>
      isTagalog ? TlStrings.appInformation : EnStrings.appInformation;
  String get leaveAFeedback =>
      isTagalog ? TlStrings.leaveAFeedback : EnStrings.leaveAFeedback;
  String get termsOfServices =>
      isTagalog ? TlStrings.termsOfServices : EnStrings.termsOfServices;
  String get settingSubtitle =>
      isTagalog ? TlStrings.settingSubtitle : EnStrings.settingSubtitle;

  // Scanner
  String get scanning => isTagalog ? TlStrings.scanning : EnStrings.scanning;
  String get processing =>
      isTagalog ? TlStrings.processing : EnStrings.processing;
  String get tapToScan =>
      isTagalog ? TlStrings.tapToScan : EnStrings.tapToScan;

  // Onboarding
  String get onboardingWelcomeTitle =>
      isTagalog ? TlStrings.onboardingWelcomeTitle : EnStrings.onboardingWelcomeTitle;
  String get onboardingWelcomeSubtitle =>
      isTagalog ? TlStrings.onboardingWelcomeSubtitle : EnStrings.onboardingWelcomeSubtitle;
  String get onboardingVisionTitle =>
      isTagalog ? TlStrings.onboardingVisionTitle : EnStrings.onboardingVisionTitle;
  String get onboardingVisionSubtitle =>
      isTagalog ? TlStrings.onboardingVisionSubtitle : EnStrings.onboardingVisionSubtitle;
  String get visionLowVision =>
      isTagalog ? TlStrings.visionLowVision : EnStrings.visionLowVision;
  String get visionPartiallyBlind =>
      isTagalog ? TlStrings.visionPartiallyBlind : EnStrings.visionPartiallyBlind;
  String get visionFullyBlind =>
      isTagalog ? TlStrings.visionFullyBlind : EnStrings.visionFullyBlind;
  String get next => isTagalog ? TlStrings.next : EnStrings.next;
  String get getStarted =>
      isTagalog ? TlStrings.getStarted : EnStrings.getStarted;
}
