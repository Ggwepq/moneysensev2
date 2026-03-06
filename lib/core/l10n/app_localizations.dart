import 'en.dart';
import 'tl.dart';

/// Simple localizations helper.
///
/// Usage: `AppLocalizations.of(settings.isTagalog).someKey`
///
/// For production, replace with `flutter_localizations` ARB-based approach.
/// This keeps things readable while the project is in early development.
class AppLocalizations {
  final bool isTagalog;
  const AppLocalizations({required this.isTagalog});

  static AppLocalizations of(bool isTagalog) =>
      AppLocalizations(isTagalog: isTagalog);

  // ── App ───────────────────────────────────────────────────────────────────
  String get appName =>
      isTagalog ? TlStrings.appName : EnStrings.appName;

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  String get navSettings =>
      isTagalog ? TlStrings.navSettings : EnStrings.navSettings;
  String get navScan =>
      isTagalog ? TlStrings.navScan : EnStrings.navScan;
  String get navTutorial =>
      isTagalog ? TlStrings.navTutorial : EnStrings.navTutorial;

  // ── Settings ──────────────────────────────────────────────────────────────
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

  // General — titles
  String get theme => isTagalog ? TlStrings.theme : EnStrings.theme;
  String get themeSystem =>
      isTagalog ? TlStrings.themeSystem : EnStrings.themeSystem;
  String get themeLight =>
      isTagalog ? TlStrings.themeLight : EnStrings.themeLight;
  String get themeDark =>
      isTagalog ? TlStrings.themeDark : EnStrings.themeDark;
  String get language =>
      isTagalog ? TlStrings.language : EnStrings.language;
  String get languageEnglish =>
      isTagalog ? TlStrings.languageEnglish : EnStrings.languageEnglish;
  String get languageTagalog =>
      isTagalog ? TlStrings.languageTagalog : EnStrings.languageTagalog;
  String get fontSize =>
      isTagalog ? TlStrings.fontSize : EnStrings.fontSize;

  // General — subtitles
  String get themeSubtitle =>
      isTagalog ? TlStrings.themeSubtitle : EnStrings.themeSubtitle;
  String get languageSubtitle =>
      isTagalog ? TlStrings.languageSubtitle : EnStrings.languageSubtitle;
  String get fontSizeSubtitle =>
      isTagalog ? TlStrings.fontSizeSubtitle : EnStrings.fontSizeSubtitle;

  // Scanning — titles
  String get useFrontCamera =>
      isTagalog ? TlStrings.useFrontCamera : EnStrings.useFrontCamera;
  String get useFlashlight =>
      isTagalog ? TlStrings.useFlashlight : EnStrings.useFlashlight;
  String get denominationVibration =>
      isTagalog ? TlStrings.denominationVibration : EnStrings.denominationVibration;

  // Scanning — subtitles
  String get useFrontCameraSubtitle =>
      isTagalog ? TlStrings.useFrontCameraSubtitle : EnStrings.useFrontCameraSubtitle;
  String get useFlashlightSubtitle =>
      isTagalog ? TlStrings.useFlashlightSubtitle : EnStrings.useFlashlightSubtitle;
  String get denominationVibrationSubtitle =>
      isTagalog ? TlStrings.denominationVibrationSubtitle : EnStrings.denominationVibrationSubtitle;

  // Navigation — titles
  String get shakeToGoBack =>
      isTagalog ? TlStrings.shakeToGoBack : EnStrings.shakeToGoBack;
  String get goBackTimerOnResult =>
      isTagalog ? TlStrings.goBackTimerOnResult : EnStrings.goBackTimerOnResult;
  String get gesturalNavigation =>
      isTagalog ? TlStrings.gesturalNavigation : EnStrings.gesturalNavigation;
  String get inertialNavigation =>
      isTagalog ? TlStrings.inertialNavigation : EnStrings.inertialNavigation;

  // Navigation — subtitles
  String get shakeToGoBackSubtitle =>
      isTagalog ? TlStrings.shakeToGoBackSubtitle : EnStrings.shakeToGoBackSubtitle;
  String get goBackTimerSubtitle =>
      isTagalog ? TlStrings.goBackTimerSubtitle : EnStrings.goBackTimerSubtitle;
  String get gesturalNavigationSubtitle =>
      isTagalog ? TlStrings.gesturalNavigationSubtitle : EnStrings.gesturalNavigationSubtitle;
  String get inertialNavigationSubtitle =>
      isTagalog ? TlStrings.inertialNavigationSubtitle : EnStrings.inertialNavigationSubtitle;

  // Help & Support — titles
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

  // Help & Support — subtitles
  String get checkForUpdatesSubtitle =>
      isTagalog ? TlStrings.checkForUpdatesSubtitle : EnStrings.checkForUpdatesSubtitle;
  String get playOnboardingSubtitle =>
      isTagalog ? TlStrings.playOnboardingSubtitle : EnStrings.playOnboardingSubtitle;
  String get appInformationSubtitle =>
      isTagalog ? TlStrings.appInformationSubtitle : EnStrings.appInformationSubtitle;
  String get leaveAFeedbackSubtitle =>
      isTagalog ? TlStrings.leaveAFeedbackSubtitle : EnStrings.leaveAFeedbackSubtitle;
  String get termsOfServicesSubtitle =>
      isTagalog ? TlStrings.termsOfServicesSubtitle : EnStrings.termsOfServicesSubtitle;

  // Inertial dialog
  String get inertialDialogBody =>
      isTagalog ? TlStrings.inertialDialogBody : EnStrings.inertialDialogBody;
  String get gotIt =>
      isTagalog ? TlStrings.gotIt : EnStrings.gotIt;

  // ── Scanner ───────────────────────────────────────────────────────────────
  String get scanning =>
      isTagalog ? TlStrings.scanning : EnStrings.scanning;
  String get processing =>
      isTagalog ? TlStrings.processing : EnStrings.processing;
  String get tapToScan =>
      isTagalog ? TlStrings.tapToScan : EnStrings.tapToScan;
  String get paused =>
      isTagalog ? TlStrings.paused : EnStrings.paused;
  String get doubleTapToResume =>
      isTagalog ? TlStrings.doubleTapToResume : EnStrings.doubleTapToResume;

  // ── Tutorial screen ───────────────────────────────────────────────────────
  String get tutorialScreenTitle =>
      isTagalog ? TlStrings.tutorialScreenTitle : EnStrings.tutorialScreenTitle;
  String get tutorialScreenSubtitle =>
      isTagalog ? TlStrings.tutorialScreenSubtitle : EnStrings.tutorialScreenSubtitle;
  String get tutorialSectionScanning =>
      isTagalog ? TlStrings.tutorialSectionScanning : EnStrings.tutorialSectionScanning;
  String get tutorialSectionNavigation =>
      isTagalog ? TlStrings.tutorialSectionNavigation : EnStrings.tutorialSectionNavigation;

  // Tutorial cards
  String get tutorialCardDenomTitle =>
      isTagalog ? TlStrings.tutorialCardDenomTitle : EnStrings.tutorialCardDenomTitle;
  String get tutorialCardDenomDesc =>
      isTagalog ? TlStrings.tutorialCardDenomDesc : EnStrings.tutorialCardDenomDesc;
  String get tutorialCardShakeTitle =>
      isTagalog ? TlStrings.tutorialCardShakeTitle : EnStrings.tutorialCardShakeTitle;
  String get tutorialCardShakeDesc =>
      isTagalog ? TlStrings.tutorialCardShakeDesc : EnStrings.tutorialCardShakeDesc;
  String get tutorialCardGestureTitle =>
      isTagalog ? TlStrings.tutorialCardGestureTitle : EnStrings.tutorialCardGestureTitle;
  String get tutorialCardGestureDesc =>
      isTagalog ? TlStrings.tutorialCardGestureDesc : EnStrings.tutorialCardGestureDesc;

  // ── Tutorial: Denomination Vibration ─────────────────────────────────────
  String get denomTutorialBadge =>
      isTagalog ? TlStrings.denomTutorialBadge : EnStrings.denomTutorialBadge;
  String get denomTutorialDescription =>
      isTagalog ? TlStrings.denomTutorialDescription : EnStrings.denomTutorialDescription;
  String get denomTutorialStep1 =>
      isTagalog ? TlStrings.denomTutorialStep1 : EnStrings.denomTutorialStep1;
  String get denomTutorialStep2 =>
      isTagalog ? TlStrings.denomTutorialStep2 : EnStrings.denomTutorialStep2;
  String get denomTutorialStep3 =>
      isTagalog ? TlStrings.denomTutorialStep3 : EnStrings.denomTutorialStep3;
  String get denomTutorialStep4 =>
      isTagalog ? TlStrings.denomTutorialStep4 : EnStrings.denomTutorialStep4;
  String get denomPlayDemoLabel =>
      isTagalog ? TlStrings.denomPlayDemoLabel : EnStrings.denomPlayDemoLabel;
  String get denomPlayDemoSub =>
      isTagalog ? TlStrings.denomPlayDemoSub : EnStrings.denomPlayDemoSub;
  String get denomPatternsLabel =>
      isTagalog ? TlStrings.denomPatternsLabel : EnStrings.denomPatternsLabel;

  // ── Tutorial: Shake to Go Back ────────────────────────────────────────────
  String get shakeTutorialBadge =>
      isTagalog ? TlStrings.shakeTutorialBadge : EnStrings.shakeTutorialBadge;
  String get shakeTutorialDescription =>
      isTagalog ? TlStrings.shakeTutorialDescription : EnStrings.shakeTutorialDescription;
  String get shakeTutorialStep1 =>
      isTagalog ? TlStrings.shakeTutorialStep1 : EnStrings.shakeTutorialStep1;
  String get shakeTutorialStep2 =>
      isTagalog ? TlStrings.shakeTutorialStep2 : EnStrings.shakeTutorialStep2;
  String get shakeTutorialStep3 =>
      isTagalog ? TlStrings.shakeTutorialStep3 : EnStrings.shakeTutorialStep3;
  String get shakeTutorialStep4 =>
      isTagalog ? TlStrings.shakeTutorialStep4 : EnStrings.shakeTutorialStep4;
  String get shakeTryItTitle =>
      isTagalog ? TlStrings.shakeTryItTitle : EnStrings.shakeTryItTitle;
  String get shakeTryItHint =>
      isTagalog ? TlStrings.shakeTryItHint : EnStrings.shakeTryItHint;
  String get shakeDetected =>
      isTagalog ? TlStrings.shakeDetected : EnStrings.shakeDetected;
  String shakeCount(int n) => n == 1
      ? (isTagalog ? TlStrings.shakeCountSingle : EnStrings.shakeCountSingle)
      : (isTagalog ? TlStrings.shakeCountMultiple(n) : EnStrings.shakeCountMultiple(n));

  // ── Tutorial: Gestural Navigation ─────────────────────────────────────────
  String get gestureTutorialBadge =>
      isTagalog ? TlStrings.gestureTutorialBadge : EnStrings.gestureTutorialBadge;
  String get gestureTutorialDescription =>
      isTagalog ? TlStrings.gestureTutorialDescription : EnStrings.gestureTutorialDescription;
  String get gestureTutorialStep1 =>
      isTagalog ? TlStrings.gestureTutorialStep1 : EnStrings.gestureTutorialStep1;
  String get gestureTutorialStep2 =>
      isTagalog ? TlStrings.gestureTutorialStep2 : EnStrings.gestureTutorialStep2;
  String get gestureTutorialStep3 =>
      isTagalog ? TlStrings.gestureTutorialStep3 : EnStrings.gestureTutorialStep3;
  String get gestureTutorialStep4 =>
      isTagalog ? TlStrings.gestureTutorialStep4 : EnStrings.gestureTutorialStep4;
  String get gestureTutorialStep5 =>
      isTagalog ? TlStrings.gestureTutorialStep5 : EnStrings.gestureTutorialStep5;
  String get gestureTryHint =>
      isTagalog ? TlStrings.gestureTryHint : EnStrings.gestureTryHint;
  String get gestureSwipeRight =>
      isTagalog ? TlStrings.gestureSwipeRight : EnStrings.gestureSwipeRight;
  String get gestureSwipeLeft =>
      isTagalog ? TlStrings.gestureSwipeLeft : EnStrings.gestureSwipeLeft;
  String get gestureSwipeUp =>
      isTagalog ? TlStrings.gestureSwipeUp : EnStrings.gestureSwipeUp;
  String get gestureDoubleTap =>
      isTagalog ? TlStrings.gestureDoubleTap : EnStrings.gestureDoubleTap;
  String get gestureOpensSettings =>
      isTagalog ? TlStrings.gestureOpensSettings : EnStrings.gestureOpensSettings;
  String get gestureOpensTutorial =>
      isTagalog ? TlStrings.gestureOpensTutorial : EnStrings.gestureOpensTutorial;
  String get gestureTogglesFlash =>
      isTagalog ? TlStrings.gestureTogglesFlash : EnStrings.gestureTogglesFlash;
  String get gestureFreezesPreview =>
      isTagalog ? TlStrings.gestureFreezesPreview : EnStrings.gestureFreezesPreview;
  String get gestureLabelRight =>
      isTagalog ? TlStrings.gestureLabelRight : EnStrings.gestureLabelRight;
  String get gestureLabelLeft =>
      isTagalog ? TlStrings.gestureLabelLeft : EnStrings.gestureLabelLeft;
  String get gestureLabelUp =>
      isTagalog ? TlStrings.gestureLabelUp : EnStrings.gestureLabelUp;
  String get gestureLabelTap =>
      isTagalog ? TlStrings.gestureLabelTap : EnStrings.gestureLabelTap;

  // ── Onboarding ────────────────────────────────────────────────────────────
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
  String get next =>
      isTagalog ? TlStrings.next : EnStrings.next;
  String get getStarted =>
      isTagalog ? TlStrings.getStarted : EnStrings.getStarted;
}
