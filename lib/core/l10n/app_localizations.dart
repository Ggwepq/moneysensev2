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
  String get sectionAccessibility =>
      isTagalog ? TlStrings.sectionAccessibility : EnStrings.sectionAccessibility;
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
  String get themeSubtitleFull =>
      isTagalog ? TlStrings.themeSubtitleFull : EnStrings.themeSubtitleFull;
  String get languageSubtitle =>
      isTagalog ? TlStrings.languageSubtitle : EnStrings.languageSubtitle;
  String get languageSubtitleFull =>
      isTagalog ? TlStrings.languageSubtitleFull : EnStrings.languageSubtitleFull;
  String get fontSizeSubtitle =>
      isTagalog ? TlStrings.fontSizeSubtitle : EnStrings.fontSizeSubtitle;
  String get fontSizeSubtitleFull =>
      isTagalog ? TlStrings.fontSizeSubtitleFull : EnStrings.fontSizeSubtitleFull;

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
  String get useFrontCameraSubtitleFull =>
      isTagalog ? TlStrings.useFrontCameraSubtitleFull : EnStrings.useFrontCameraSubtitleFull;
  String get useFlashlightSubtitle =>
      isTagalog ? TlStrings.useFlashlightSubtitle : EnStrings.useFlashlightSubtitle;
  String get useFlashlightSubtitleFull =>
      isTagalog ? TlStrings.useFlashlightSubtitleFull : EnStrings.useFlashlightSubtitleFull;
  String get denominationVibrationSubtitle =>
      isTagalog ? TlStrings.denominationVibrationSubtitle : EnStrings.denominationVibrationSubtitle;
  String get denominationVibrationSubtitleFull =>
      isTagalog ? TlStrings.denominationVibrationSubtitleFull : EnStrings.denominationVibrationSubtitleFull;

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
  String get shakeToGoBackSubtitleFull =>
      isTagalog ? TlStrings.shakeToGoBackSubtitleFull : EnStrings.shakeToGoBackSubtitleFull;
  String get goBackTimerSubtitle =>
      isTagalog ? TlStrings.goBackTimerSubtitle : EnStrings.goBackTimerSubtitle;
  String get goBackTimerSubtitleFull =>
      isTagalog ? TlStrings.goBackTimerSubtitleFull : EnStrings.goBackTimerSubtitleFull;
  String get gesturalNavigationSubtitle =>
      isTagalog ? TlStrings.gesturalNavigationSubtitle : EnStrings.gesturalNavigationSubtitle;
  String get gesturalNavigationSubtitleFull =>
      isTagalog ? TlStrings.gesturalNavigationSubtitleFull : EnStrings.gesturalNavigationSubtitleFull;
  String get inertialNavigationSubtitle =>
      isTagalog ? TlStrings.inertialNavigationSubtitle : EnStrings.inertialNavigationSubtitle;
  String get inertialNavigationSubtitleFull =>
      isTagalog ? TlStrings.inertialNavigationSubtitleFull : EnStrings.inertialNavigationSubtitleFull;

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

  // Tutorial card — Inertial Navigation
  String get tutorialCardInertialTitle =>
      isTagalog ? TlStrings.tutorialCardInertialTitle : EnStrings.tutorialCardInertialTitle;
  String get tutorialCardInertialDesc =>
      isTagalog ? TlStrings.tutorialCardInertialDesc : EnStrings.tutorialCardInertialDesc;

  // ── Tutorial: Inertial Navigation ─────────────────────────────────────────
  String get inertialTutorialBadge =>
      isTagalog ? TlStrings.inertialTutorialBadge : EnStrings.inertialTutorialBadge;
  String get inertialTutorialDescription =>
      isTagalog ? TlStrings.inertialTutorialDescription : EnStrings.inertialTutorialDescription;
  String get inertialTutorialStep1 =>
      isTagalog ? TlStrings.inertialTutorialStep1 : EnStrings.inertialTutorialStep1;
  String get inertialTutorialStep2 =>
      isTagalog ? TlStrings.inertialTutorialStep2 : EnStrings.inertialTutorialStep2;
  String get inertialTutorialStep3 =>
      isTagalog ? TlStrings.inertialTutorialStep3 : EnStrings.inertialTutorialStep3;
  String get inertialTutorialStep4 =>
      isTagalog ? TlStrings.inertialTutorialStep4 : EnStrings.inertialTutorialStep4;
  String get inertialTutorialStep5 =>
      isTagalog ? TlStrings.inertialTutorialStep5 : EnStrings.inertialTutorialStep5;
  String get inertialTiltRight =>
      isTagalog ? TlStrings.inertialTiltRight : EnStrings.inertialTiltRight;
  String get inertialTiltLeft =>
      isTagalog ? TlStrings.inertialTiltLeft : EnStrings.inertialTiltLeft;
  String get inertialTiltBack =>
      isTagalog ? TlStrings.inertialTiltBack : EnStrings.inertialTiltBack;
  String get inertialTryItHint =>
      isTagalog ? TlStrings.inertialTryItHint : EnStrings.inertialTryItHint;
  String get inertialTiltDetected =>
      isTagalog ? TlStrings.inertialTiltDetected : EnStrings.inertialTiltDetected;
  String get inertialFlatWarning =>
      isTagalog ? TlStrings.inertialFlatWarning : EnStrings.inertialFlatWarning;
  String get inertialLegendRight =>
      isTagalog ? TlStrings.inertialLegendRight : EnStrings.inertialLegendRight;
  String get inertialLegendLeft =>
      isTagalog ? TlStrings.inertialLegendLeft : EnStrings.inertialLegendLeft;
  String get inertialLegendOpensSettings =>
      isTagalog ? TlStrings.inertialLegendOpensSettings : EnStrings.inertialLegendOpensSettings;
  String get inertialLegendOpensTutorial =>
      isTagalog ? TlStrings.inertialLegendOpensTutorial : EnStrings.inertialLegendOpensTutorial;
  String get inertialLegendGoBack =>
      isTagalog ? TlStrings.inertialLegendGoBack : EnStrings.inertialLegendGoBack;

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

  // ── Accessibility settings ────────────────────────────────────────────────
  String get visionProfileTitle =>
      isTagalog ? TlStrings.visionProfileTitle : EnStrings.visionProfileTitle;
  String get visionProfileSubtitle =>
      isTagalog ? TlStrings.visionProfileSubtitle : EnStrings.visionProfileSubtitle;
  String get visionProfileSubtitleFull =>
      isTagalog ? TlStrings.visionProfileSubtitleFull : EnStrings.visionProfileSubtitleFull;
  String get visionLowVisionDesc =>
      isTagalog ? TlStrings.visionLowVisionDesc : EnStrings.visionLowVisionDesc;
  String get visionPartiallyBlindDesc =>
      isTagalog ? TlStrings.visionPartiallyBlindDesc : EnStrings.visionPartiallyBlindDesc;
  String get visionFullyBlindDesc =>
      isTagalog ? TlStrings.visionFullyBlindDesc : EnStrings.visionFullyBlindDesc;

  String get ttsTitle =>
      isTagalog ? TlStrings.ttsTitle : EnStrings.ttsTitle;
  String get ttsSubtitle =>
      isTagalog ? TlStrings.ttsSubtitle : EnStrings.ttsSubtitle;
  String get ttsSubtitleFull =>
      isTagalog ? TlStrings.ttsSubtitleFull : EnStrings.ttsSubtitleFull;
  String get ttsVerbosityTitle =>
      isTagalog ? TlStrings.ttsVerbosityTitle : EnStrings.ttsVerbosityTitle;
  String get ttsVerbositySubtitle =>
      isTagalog ? TlStrings.ttsVerbositySubtitle : EnStrings.ttsVerbositySubtitle;
  String get ttsVerbositySubtitleFull =>
      isTagalog ? TlStrings.ttsVerbositySubtitleFull : EnStrings.ttsVerbositySubtitleFull;
  String get ttsVerbosityMinimal =>
      isTagalog ? TlStrings.ttsVerbosityMinimal : EnStrings.ttsVerbosityMinimal;
  String get ttsVerbosityStandard =>
      isTagalog ? TlStrings.ttsVerbosityStandard : EnStrings.ttsVerbosityStandard;
  String get ttsVerbosityFull =>
      isTagalog ? TlStrings.ttsVerbosityFull : EnStrings.ttsVerbosityFull;

  String get hapticTitle =>
      isTagalog ? TlStrings.hapticTitle : EnStrings.hapticTitle;
  String get hapticSubtitle =>
      isTagalog ? TlStrings.hapticSubtitle : EnStrings.hapticSubtitle;
  String get hapticSubtitleFull =>
      isTagalog ? TlStrings.hapticSubtitleFull : EnStrings.hapticSubtitleFull;
  String get hapticIntensityTitle =>
      isTagalog ? TlStrings.hapticIntensityTitle : EnStrings.hapticIntensityTitle;
  String get hapticIntensitySubtitle =>
      isTagalog ? TlStrings.hapticIntensitySubtitle : EnStrings.hapticIntensitySubtitle;
  String get hapticIntensitySubtitleFull =>
      isTagalog ? TlStrings.hapticIntensitySubtitleFull : EnStrings.hapticIntensitySubtitleFull;
  String get hapticIntensitySubtle =>
      isTagalog ? TlStrings.hapticIntensitySubtle : EnStrings.hapticIntensitySubtle;
  String get hapticIntensityMedium =>
      isTagalog ? TlStrings.hapticIntensityMedium : EnStrings.hapticIntensityMedium;
  String get hapticIntensityStrong =>
      isTagalog ? TlStrings.hapticIntensityStrong : EnStrings.hapticIntensityStrong;
  String get next =>
      isTagalog ? TlStrings.next : EnStrings.next;
  String get getStarted =>
      isTagalog ? TlStrings.getStarted : EnStrings.getStarted;

  // Onboarding: navigation style
  String get onboardingNavTitle =>
      isTagalog ? TlStrings.onboardingNavTitle : EnStrings.onboardingNavTitle;
  String get onboardingNavSubtitle =>
      isTagalog ? TlStrings.onboardingNavSubtitle : EnStrings.onboardingNavSubtitle;
  String get onboardingNavNormal =>
      isTagalog ? TlStrings.onboardingNavNormal : EnStrings.onboardingNavNormal;
  String get onboardingNavNormalDesc =>
      isTagalog ? TlStrings.onboardingNavNormalDesc : EnStrings.onboardingNavNormalDesc;
  String get onboardingNavGestural =>
      isTagalog ? TlStrings.onboardingNavGestural : EnStrings.onboardingNavGestural;
  String get onboardingNavGesturalDesc =>
      isTagalog ? TlStrings.onboardingNavGesturalDesc : EnStrings.onboardingNavGesturalDesc;
  String get onboardingNavInertial =>
      isTagalog ? TlStrings.onboardingNavInertial : EnStrings.onboardingNavInertial;
  String get onboardingNavInertialDesc =>
      isTagalog ? TlStrings.onboardingNavInertialDesc : EnStrings.onboardingNavInertialDesc;

  // Onboarding: permissions
  String get onboardingPermissionTitle =>
      isTagalog ? TlStrings.onboardingPermissionTitle : EnStrings.onboardingPermissionTitle;
  String get onboardingPermissionSubtitle =>
      isTagalog ? TlStrings.onboardingPermissionSubtitle : EnStrings.onboardingPermissionSubtitle;
  String get onboardingPermissionGrant =>
      isTagalog ? TlStrings.onboardingPermissionGrant : EnStrings.onboardingPermissionGrant;
  String get onboardingPermissionGranted =>
      isTagalog ? TlStrings.onboardingPermissionGranted : EnStrings.onboardingPermissionGranted;
  String get onboardingPermissionDenied =>
      isTagalog ? TlStrings.onboardingPermissionDenied : EnStrings.onboardingPermissionDenied;
  String get onboardingPermissionSkip =>
      isTagalog ? TlStrings.onboardingPermissionSkip : EnStrings.onboardingPermissionSkip;

  // Onboarding: finish
  String get onboardingFinishTitle =>
      isTagalog ? TlStrings.onboardingFinishTitle : EnStrings.onboardingFinishTitle;
  String get onboardingFinishSubtitle =>
      isTagalog ? TlStrings.onboardingFinishSubtitle : EnStrings.onboardingFinishSubtitle;
  String get onboardingFinishTour =>
      isTagalog ? TlStrings.onboardingFinishTour : EnStrings.onboardingFinishTour;
  String get onboardingFinishSkip =>
      isTagalog ? TlStrings.onboardingFinishSkip : EnStrings.onboardingFinishSkip;

  // Tutorial: App Navigation
  String get tutorialCardAppNavTitle =>
      isTagalog ? TlStrings.tutorialCardAppNavTitle : EnStrings.tutorialCardAppNavTitle;
  String get tutorialCardAppNavDesc =>
      isTagalog ? TlStrings.tutorialCardAppNavDesc : EnStrings.tutorialCardAppNavDesc;

  // ── TTS speech strings ──────────────────────────────────────────────────

  // App-level
  String get ttsSpeechEnabled =>
      isTagalog ? TlStrings.ttsSpeechEnabled : EnStrings.ttsSpeechEnabled;
  String get ttsSpeechDisabling =>
      isTagalog ? TlStrings.ttsSpeechDisabling : EnStrings.ttsSpeechDisabling;

  // Navigation
  String get ttsNavSettings =>
      isTagalog ? TlStrings.ttsNavSettings : EnStrings.ttsNavSettings;
  String get ttsNavTutorial =>
      isTagalog ? TlStrings.ttsNavTutorial : EnStrings.ttsNavTutorial;
  String get ttsNavHome =>
      isTagalog ? TlStrings.ttsNavHome : EnStrings.ttsNavHome;

  // Language-change loading messages
  String ttsLangChanging(String langName) =>
      isTagalog
          ? TlStrings.ttsLangChanging(langName)
          : EnStrings.ttsLangChanging(langName);
  String ttsLangChanged(String langName) =>
      isTagalog
          ? TlStrings.ttsLangChanged(langName)
          : EnStrings.ttsLangChanged(langName);

  // Short visible label beside the spinner
  String get ttsLangChangingLabel =>
      isTagalog
          ? TlStrings.ttsLangChangingLabel
          : EnStrings.ttsLangChangingLabel;

  // Settings confirmations — parametric (not stored as const strings)
  String ttsSettingEnabled(String settingName) =>
      isTagalog ? '$settingName naka-on.' : '$settingName enabled.';
  String ttsSettingDisabled(String settingName) =>
      isTagalog ? '$settingName naka-off.' : '$settingName disabled.';
  String ttsSettingChanged(String settingName, String newValue) =>
      isTagalog ? '$settingName: $newValue.' : '$settingName set to $newValue.';

  // Scanner — results
  String ttsScanResult(String denomination) =>
      isTagalog
          ? TlStrings.ttsScanResult(denomination)
          : EnStrings.ttsScanResult(denomination);
  String ttsScanResultWithType(String denomination, String type) =>
      isTagalog
          ? TlStrings.ttsScanResultWithType(denomination, type)
          : EnStrings.ttsScanResultWithType(denomination, type);
  String ttsScanResultLowConfidence(String denomination, String type) =>
      isTagalog
          ? TlStrings.ttsScanResultLowConfidence(denomination, type)
          : EnStrings.ttsScanResultLowConfidence(denomination, type);

  // Scanner — camera state
  String get ttsCameraOpened =>
      isTagalog ? TlStrings.ttsCameraOpened : EnStrings.ttsCameraOpened;
  String get ttsCameraClosed =>
      isTagalog ? TlStrings.ttsCameraClosed : EnStrings.ttsCameraClosed;
  String get ttsPreviewFrozen =>
      isTagalog ? TlStrings.ttsPreviewFrozen : EnStrings.ttsPreviewFrozen;
  String get ttsPreviewResumed =>
      isTagalog ? TlStrings.ttsPreviewResumed : EnStrings.ttsPreviewResumed;
  String get ttsFlashOn =>
      isTagalog ? TlStrings.ttsFlashOn : EnStrings.ttsFlashOn;
  String get ttsFlashOff =>
      isTagalog ? TlStrings.ttsFlashOff : EnStrings.ttsFlashOff;

  // Scanner — ambient hints
  String get ttsScannerIdle =>
      isTagalog ? TlStrings.ttsScannerIdle : EnStrings.ttsScannerIdle;
  String get ttsScanStarted =>
      isTagalog ? TlStrings.ttsScanStarted : EnStrings.ttsScanStarted;
  String get ttsProcessing =>
      isTagalog ? TlStrings.ttsProcessing : EnStrings.ttsProcessing;

  // Scanner — errors
  String get ttsCameraPermissionDenied =>
      isTagalog
          ? TlStrings.ttsCameraPermissionDenied
          : EnStrings.ttsCameraPermissionDenied;
  String get ttsScanFailed =>
      isTagalog ? TlStrings.ttsScanFailed : EnStrings.ttsScanFailed;
  String get ttsCameraError =>
      isTagalog ? TlStrings.ttsCameraError : EnStrings.ttsCameraError;

  // ── Scanner Semantics labels ───────────────────────────────────────────────
  String get scannerSemanticIdle =>
      isTagalog ? TlStrings.scannerSemanticIdle : EnStrings.scannerSemanticIdle;
  String get scannerSemanticReady =>
      isTagalog ? TlStrings.scannerSemanticReady : EnStrings.scannerSemanticReady;
  String get scannerSemanticScanning =>
      isTagalog ? TlStrings.scannerSemanticScanning : EnStrings.scannerSemanticScanning;
  String get scannerSemanticProcessing =>
      isTagalog ? TlStrings.scannerSemanticProcessing : EnStrings.scannerSemanticProcessing;
  String get scannerSemanticPaused =>
      isTagalog ? TlStrings.scannerSemanticPaused : EnStrings.scannerSemanticPaused;
  String get scannerSemanticResult =>
      isTagalog ? TlStrings.scannerSemanticResult : EnStrings.scannerSemanticResult;

  // ── Onboarding TTS ────────────────────────────────────────────────────────
  String get ttsOnboardingWelcome =>
      isTagalog ? TlStrings.ttsOnboardingWelcome : EnStrings.ttsOnboardingWelcome;
  String get ttsOnboardingVision =>
      isTagalog ? TlStrings.ttsOnboardingVision : EnStrings.ttsOnboardingVision;
  String get ttsOnboardingLanguage =>
      isTagalog ? TlStrings.ttsOnboardingLanguage : EnStrings.ttsOnboardingLanguage;
  String get ttsOnboardingProfileSelected =>
      isTagalog
          ? TlStrings.ttsOnboardingProfileSelected
          : EnStrings.ttsOnboardingProfileSelected;
}
