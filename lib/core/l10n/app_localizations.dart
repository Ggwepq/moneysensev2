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
  String get appName => isTagalog ? TlStrings.appName : EnStrings.appName;

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  String get navSettings =>
      isTagalog ? TlStrings.navSettings : EnStrings.navSettings;
  String get navScan => isTagalog ? TlStrings.navScan : EnStrings.navScan;
  String get navTutorial =>
      isTagalog ? TlStrings.navTutorial : EnStrings.navTutorial;

  // ── Settings ──────────────────────────────────────────────────────────────
  String get settings => isTagalog ? TlStrings.settings : EnStrings.settings;
  String get simpleMode => isTagalog ? TlStrings.simpleMode : EnStrings.simpleMode;
  String get advancedMode => isTagalog ? TlStrings.advancedMode : EnStrings.advancedMode;

  // Sections
  String get sectionGeneral =>
      isTagalog ? TlStrings.sectionGeneral : EnStrings.sectionGeneral;
  String get sectionScanning =>
      isTagalog ? TlStrings.sectionScanning : EnStrings.sectionScanning;
  String get sectionNavigation =>
      isTagalog ? TlStrings.sectionNavigation : EnStrings.sectionNavigation;
  String get sectionAccessibility => isTagalog
      ? TlStrings.sectionAccessibility
      : EnStrings.sectionAccessibility;
  String get sectionHelpSupport =>
      isTagalog ? TlStrings.sectionHelpSupport : EnStrings.sectionHelpSupport;

  // General: titles
  String get theme => isTagalog ? TlStrings.theme : EnStrings.theme;
  String get themeSystem =>
      isTagalog ? TlStrings.themeSystem : EnStrings.themeSystem;
  String get themeLight =>
      isTagalog ? TlStrings.themeLight : EnStrings.themeLight;
  String get themeDark => isTagalog ? TlStrings.themeDark : EnStrings.themeDark;
  String get language => isTagalog ? TlStrings.language : EnStrings.language;
  String get languageEnglish =>
      isTagalog ? TlStrings.languageEnglish : EnStrings.languageEnglish;
  String get languageTagalog =>
      isTagalog ? TlStrings.languageTagalog : EnStrings.languageTagalog;
  String get fontSize => isTagalog ? TlStrings.fontSize : EnStrings.fontSize;

  // General: subtitles
  String get themeSubtitle =>
      isTagalog ? TlStrings.themeSubtitle : EnStrings.themeSubtitle;
  String get themeSubtitleFull =>
      isTagalog ? TlStrings.themeSubtitleFull : EnStrings.themeSubtitleFull;
  String get languageSubtitle =>
      isTagalog ? TlStrings.languageSubtitle : EnStrings.languageSubtitle;
  String get languageSubtitleFull => isTagalog
      ? TlStrings.languageSubtitleFull
      : EnStrings.languageSubtitleFull;
  String get fontSizeSubtitle =>
      isTagalog ? TlStrings.fontSizeSubtitle : EnStrings.fontSizeSubtitle;
  String get fontSizeSubtitleFull => isTagalog
      ? TlStrings.fontSizeSubtitleFull
      : EnStrings.fontSizeSubtitleFull;

  // Scanning: titles
  String get useFrontCamera =>
      isTagalog ? TlStrings.useFrontCamera : EnStrings.useFrontCamera;
  String get useFlashlight =>
      isTagalog ? TlStrings.useFlashlight : EnStrings.useFlashlight;
  String get denominationVibration => isTagalog
      ? TlStrings.denominationVibration
      : EnStrings.denominationVibration;

  // Scanning: subtitles
  String get useFrontCameraSubtitle => isTagalog
      ? TlStrings.useFrontCameraSubtitle
      : EnStrings.useFrontCameraSubtitle;
  String get useFrontCameraSubtitleFull => isTagalog
      ? TlStrings.useFrontCameraSubtitleFull
      : EnStrings.useFrontCameraSubtitleFull;
  String get useFlashlightSubtitle => isTagalog
      ? TlStrings.useFlashlightSubtitle
      : EnStrings.useFlashlightSubtitle;
  String get useFlashlightSubtitleFull => isTagalog
      ? TlStrings.useFlashlightSubtitleFull
      : EnStrings.useFlashlightSubtitleFull;
  String get denominationVibrationSubtitle => isTagalog
      ? TlStrings.denominationVibrationSubtitle
      : EnStrings.denominationVibrationSubtitle;
  String get denominationVibrationSubtitleFull => isTagalog
      ? TlStrings.denominationVibrationSubtitleFull
      : EnStrings.denominationVibrationSubtitleFull;

  // Navigation: titles
  String get shakeToGoBack =>
      isTagalog ? TlStrings.shakeToGoBack : EnStrings.shakeToGoBack;
  String get goBackTimerOnResult =>
      isTagalog ? TlStrings.goBackTimerOnResult : EnStrings.goBackTimerOnResult;
  String get gesturalNavigation =>
      isTagalog ? TlStrings.gesturalNavigation : EnStrings.gesturalNavigation;
  String get inertialNavigation =>
      isTagalog ? TlStrings.inertialNavigation : EnStrings.inertialNavigation;

  // Navigation: subtitles
  String get shakeToGoBackSubtitle => isTagalog
      ? TlStrings.shakeToGoBackSubtitle
      : EnStrings.shakeToGoBackSubtitle;
  String get shakeToGoBackSubtitleFull => isTagalog
      ? TlStrings.shakeToGoBackSubtitleFull
      : EnStrings.shakeToGoBackSubtitleFull;
  String get goBackTimerSubtitle =>
      isTagalog ? TlStrings.goBackTimerSubtitle : EnStrings.goBackTimerSubtitle;
  String get goBackTimerSubtitleFull => isTagalog
      ? TlStrings.goBackTimerSubtitleFull
      : EnStrings.goBackTimerSubtitleFull;
  String get gesturalNavigationSubtitle => isTagalog
      ? TlStrings.gesturalNavigationSubtitle
      : EnStrings.gesturalNavigationSubtitle;
  String get gesturalNavigationSubtitleFull => isTagalog
      ? TlStrings.gesturalNavigationSubtitleFull
      : EnStrings.gesturalNavigationSubtitleFull;
  String get inertialNavigationSubtitle => isTagalog
      ? TlStrings.inertialNavigationSubtitle
      : EnStrings.inertialNavigationSubtitle;
  String get inertialNavigationSubtitleFull => isTagalog
      ? TlStrings.inertialNavigationSubtitleFull
      : EnStrings.inertialNavigationSubtitleFull;

  // Help & Support: titles
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

  // Help & Support: subtitles
  String get checkForUpdatesSubtitle => isTagalog
      ? TlStrings.checkForUpdatesSubtitle
      : EnStrings.checkForUpdatesSubtitle;
  String get playOnboardingSubtitle => isTagalog
      ? TlStrings.playOnboardingSubtitle
      : EnStrings.playOnboardingSubtitle;
  String get appInformationSubtitle => isTagalog
      ? TlStrings.appInformationSubtitle
      : EnStrings.appInformationSubtitle;
  String get leaveAFeedbackSubtitle => isTagalog
      ? TlStrings.leaveAFeedbackSubtitle
      : EnStrings.leaveAFeedbackSubtitle;
  String get termsOfServicesSubtitle => isTagalog
      ? TlStrings.termsOfServicesSubtitle
      : EnStrings.termsOfServicesSubtitle;

  // Inertial dialog
  String get inertialDialogBody =>
      isTagalog ? TlStrings.inertialDialogBody : EnStrings.inertialDialogBody;
  String get gotIt => isTagalog ? TlStrings.gotIt : EnStrings.gotIt;

  // Tutorial card: Inertial Navigation
  String get tutorialCardInertialTitle => isTagalog
      ? TlStrings.tutorialCardInertialTitle
      : EnStrings.tutorialCardInertialTitle;
  String get tutorialCardInertialDesc => isTagalog
      ? TlStrings.tutorialCardInertialDesc
      : EnStrings.tutorialCardInertialDesc;

  // ── Tutorial: Inertial Navigation ─────────────────────────────────────────
  String get inertialTutorialBadge => isTagalog
      ? TlStrings.inertialTutorialBadge
      : EnStrings.inertialTutorialBadge;
  String get inertialTutorialDescription => isTagalog
      ? TlStrings.inertialTutorialDescription
      : EnStrings.inertialTutorialDescription;
  String get inertialTutorialStep1 => isTagalog
      ? TlStrings.inertialTutorialStep1
      : EnStrings.inertialTutorialStep1;
  String get inertialTutorialStep2 => isTagalog
      ? TlStrings.inertialTutorialStep2
      : EnStrings.inertialTutorialStep2;
  String get inertialTutorialStep3 => isTagalog
      ? TlStrings.inertialTutorialStep3
      : EnStrings.inertialTutorialStep3;
  String get inertialTutorialStep4 => isTagalog
      ? TlStrings.inertialTutorialStep4
      : EnStrings.inertialTutorialStep4;
  String get inertialTutorialStep5 => isTagalog
      ? TlStrings.inertialTutorialStep5
      : EnStrings.inertialTutorialStep5;
  String get inertialTiltRight =>
      isTagalog ? TlStrings.inertialTiltRight : EnStrings.inertialTiltRight;
  String get inertialTiltLeft =>
      isTagalog ? TlStrings.inertialTiltLeft : EnStrings.inertialTiltLeft;
  String get inertialTiltBack =>
      isTagalog ? TlStrings.inertialTiltBack : EnStrings.inertialTiltBack;
  String get inertialTryItHint =>
      isTagalog ? TlStrings.inertialTryItHint : EnStrings.inertialTryItHint;
  String get inertialTiltDetected => isTagalog
      ? TlStrings.inertialTiltDetected
      : EnStrings.inertialTiltDetected;
  String get inertialFlatWarning =>
      isTagalog ? TlStrings.inertialFlatWarning : EnStrings.inertialFlatWarning;
  String get inertialLegendRight =>
      isTagalog ? TlStrings.inertialLegendRight : EnStrings.inertialLegendRight;
  String get inertialLegendLeft =>
      isTagalog ? TlStrings.inertialLegendLeft : EnStrings.inertialLegendLeft;
  String get inertialLegendOpensSettings => isTagalog
      ? TlStrings.inertialLegendOpensSettings
      : EnStrings.inertialLegendOpensSettings;
  String get inertialLegendOpensTutorial => isTagalog
      ? TlStrings.inertialLegendOpensTutorial
      : EnStrings.inertialLegendOpensTutorial;
  String get inertialLegendGoBack => isTagalog
      ? TlStrings.inertialLegendGoBack
      : EnStrings.inertialLegendGoBack;

  // ── Scanner ───────────────────────────────────────────────────────────────
  String get scanning => isTagalog ? TlStrings.scanning : EnStrings.scanning;
  String get processing =>
      isTagalog ? TlStrings.processing : EnStrings.processing;
  String get tapToScan => isTagalog ? TlStrings.tapToScan : EnStrings.tapToScan;
  String get paused => isTagalog ? TlStrings.paused : EnStrings.paused;
  String get doubleTapToResume =>
      isTagalog ? TlStrings.doubleTapToResume : EnStrings.doubleTapToResume;

  // ── Tutorial screen ───────────────────────────────────────────────────────
  String get tutorialScreenTitle =>
      isTagalog ? TlStrings.tutorialScreenTitle : EnStrings.tutorialScreenTitle;
  String get tutorialScreenSubtitle => isTagalog
      ? TlStrings.tutorialScreenSubtitle
      : EnStrings.tutorialScreenSubtitle;
  String get tutorialSectionScanning => isTagalog
      ? TlStrings.tutorialSectionScanning
      : EnStrings.tutorialSectionScanning;
  String get tutorialSectionNavigation => isTagalog
      ? TlStrings.tutorialSectionNavigation
      : EnStrings.tutorialSectionNavigation;

  // Tutorial cards
  String get tutorialCardDenomTitle => isTagalog
      ? TlStrings.tutorialCardDenomTitle
      : EnStrings.tutorialCardDenomTitle;
  String get tutorialCardDenomDesc => isTagalog
      ? TlStrings.tutorialCardDenomDesc
      : EnStrings.tutorialCardDenomDesc;
  String get tutorialCardShakeTitle => isTagalog
      ? TlStrings.tutorialCardShakeTitle
      : EnStrings.tutorialCardShakeTitle;
  String get tutorialCardShakeDesc => isTagalog
      ? TlStrings.tutorialCardShakeDesc
      : EnStrings.tutorialCardShakeDesc;
  String get tutorialCardGestureTitle => isTagalog
      ? TlStrings.tutorialCardGestureTitle
      : EnStrings.tutorialCardGestureTitle;
  String get tutorialCardGestureDesc => isTagalog
      ? TlStrings.tutorialCardGestureDesc
      : EnStrings.tutorialCardGestureDesc;

  // ── Tutorial: Denomination Vibration ─────────────────────────────────────
  String get denomTutorialBadge =>
      isTagalog ? TlStrings.denomTutorialBadge : EnStrings.denomTutorialBadge;
  String get denomTutorialDescription => isTagalog
      ? TlStrings.denomTutorialDescription
      : EnStrings.denomTutorialDescription;
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
  String get shakeTutorialDescription => isTagalog
      ? TlStrings.shakeTutorialDescription
      : EnStrings.shakeTutorialDescription;
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
      : (isTagalog
            ? TlStrings.shakeCountMultiple(n)
            : EnStrings.shakeCountMultiple(n));

  // ── Tutorial: Gestural Navigation ─────────────────────────────────────────
  String get gestureTutorialBadge => isTagalog
      ? TlStrings.gestureTutorialBadge
      : EnStrings.gestureTutorialBadge;
  String get gestureTutorialDescription => isTagalog
      ? TlStrings.gestureTutorialDescription
      : EnStrings.gestureTutorialDescription;
  String get gestureTutorialStep1 => isTagalog
      ? TlStrings.gestureTutorialStep1
      : EnStrings.gestureTutorialStep1;
  String get gestureTutorialStep2 => isTagalog
      ? TlStrings.gestureTutorialStep2
      : EnStrings.gestureTutorialStep2;
  String get gestureTutorialStep3 => isTagalog
      ? TlStrings.gestureTutorialStep3
      : EnStrings.gestureTutorialStep3;
  String get gestureTutorialStep4 => isTagalog
      ? TlStrings.gestureTutorialStep4
      : EnStrings.gestureTutorialStep4;
  String get gestureTutorialStep5 => isTagalog
      ? TlStrings.gestureTutorialStep5
      : EnStrings.gestureTutorialStep5;
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
  String get gestureOpensSettings => isTagalog
      ? TlStrings.gestureOpensSettings
      : EnStrings.gestureOpensSettings;
  String get gestureOpensTutorial => isTagalog
      ? TlStrings.gestureOpensTutorial
      : EnStrings.gestureOpensTutorial;
  String get gestureTogglesFlash =>
      isTagalog ? TlStrings.gestureTogglesFlash : EnStrings.gestureTogglesFlash;
  String get gestureFreezesPreview => isTagalog
      ? TlStrings.gestureFreezesPreview
      : EnStrings.gestureFreezesPreview;
  String get gestureLabelRight =>
      isTagalog ? TlStrings.gestureLabelRight : EnStrings.gestureLabelRight;
  String get gestureLabelLeft =>
      isTagalog ? TlStrings.gestureLabelLeft : EnStrings.gestureLabelLeft;
  String get gestureLabelUp =>
      isTagalog ? TlStrings.gestureLabelUp : EnStrings.gestureLabelUp;
  String get gestureLabelTap =>
      isTagalog ? TlStrings.gestureLabelTap : EnStrings.gestureLabelTap;

  // ── Onboarding ────────────────────────────────────────────────────────────
  String get onboardingWelcomeTitle => isTagalog
      ? TlStrings.onboardingWelcomeTitle
      : EnStrings.onboardingWelcomeTitle;
  String get onboardingWelcomeSubtitle => isTagalog
      ? TlStrings.onboardingWelcomeSubtitle
      : EnStrings.onboardingWelcomeSubtitle;
  String get onboardingVisionTitle => isTagalog
      ? TlStrings.onboardingVisionTitle
      : EnStrings.onboardingVisionTitle;
  String get onboardingVisionSubtitle => isTagalog
      ? TlStrings.onboardingVisionSubtitle
      : EnStrings.onboardingVisionSubtitle;
  String get visionLowVision =>
      isTagalog ? TlStrings.visionLowVision : EnStrings.visionLowVision;
  String get visionPartiallyBlind => isTagalog
      ? TlStrings.visionPartiallyBlind
      : EnStrings.visionPartiallyBlind;
  String get visionFullyBlind =>
      isTagalog ? TlStrings.visionFullyBlind : EnStrings.visionFullyBlind;
  String get onboardingVisionOptions =>
      isTagalog ? TlStrings.onboardingVisionOptions : EnStrings.onboardingVisionOptions;

  // ── Accessibility settings ────────────────────────────────────────────────
  String get visionProfileTitle =>
      isTagalog ? TlStrings.visionProfileTitle : EnStrings.visionProfileTitle;
  String get visionProfileSubtitle => isTagalog
      ? TlStrings.visionProfileSubtitle
      : EnStrings.visionProfileSubtitle;
  String get visionProfileSubtitleFull => isTagalog
      ? TlStrings.visionProfileSubtitleFull
      : EnStrings.visionProfileSubtitleFull;
  String get visionLowVisionDesc =>
      isTagalog ? TlStrings.visionLowVisionDesc : EnStrings.visionLowVisionDesc;
  String get visionPartiallyBlindDesc => isTagalog
      ? TlStrings.visionPartiallyBlindDesc
      : EnStrings.visionPartiallyBlindDesc;
  String get visionFullyBlindDesc => isTagalog
      ? TlStrings.visionFullyBlindDesc
      : EnStrings.visionFullyBlindDesc;

  String get ttsTitle => isTagalog ? TlStrings.ttsTitle : EnStrings.ttsTitle;
  String get ttsSubtitle =>
      isTagalog ? TlStrings.ttsSubtitle : EnStrings.ttsSubtitle;
  String get ttsSubtitleFull =>
      isTagalog ? TlStrings.ttsSubtitleFull : EnStrings.ttsSubtitleFull;
  String get ttsVerbosityTitle =>
      isTagalog ? TlStrings.ttsVerbosityTitle : EnStrings.ttsVerbosityTitle;
  String get ttsVerbositySubtitle => isTagalog
      ? TlStrings.ttsVerbositySubtitle
      : EnStrings.ttsVerbositySubtitle;
  String get ttsVerbositySubtitleFull => isTagalog
      ? TlStrings.ttsVerbositySubtitleFull
      : EnStrings.ttsVerbositySubtitleFull;
  String get ttsVerbosityMinimal =>
      isTagalog ? TlStrings.ttsVerbosityMinimal : EnStrings.ttsVerbosityMinimal;
  String get ttsVerbosityStandard => isTagalog
      ? TlStrings.ttsVerbosityStandard
      : EnStrings.ttsVerbosityStandard;
  String get ttsVerbosityFull =>
      isTagalog ? TlStrings.ttsVerbosityFull : EnStrings.ttsVerbosityFull;

  String get hapticTitle =>
      isTagalog ? TlStrings.hapticTitle : EnStrings.hapticTitle;
  String get hapticSubtitle =>
      isTagalog ? TlStrings.hapticSubtitle : EnStrings.hapticSubtitle;
  String get hapticSubtitleFull =>
      isTagalog ? TlStrings.hapticSubtitleFull : EnStrings.hapticSubtitleFull;
  String get hapticIntensityTitle => isTagalog
      ? TlStrings.hapticIntensityTitle
      : EnStrings.hapticIntensityTitle;
  String get hapticIntensitySubtitle => isTagalog
      ? TlStrings.hapticIntensitySubtitle
      : EnStrings.hapticIntensitySubtitle;
  String get hapticIntensitySubtitleFull => isTagalog
      ? TlStrings.hapticIntensitySubtitleFull
      : EnStrings.hapticIntensitySubtitleFull;
  String get hapticIntensitySubtle => isTagalog
      ? TlStrings.hapticIntensitySubtle
      : EnStrings.hapticIntensitySubtle;
  String get hapticIntensityMedium => isTagalog
      ? TlStrings.hapticIntensityMedium
      : EnStrings.hapticIntensityMedium;
  String get hapticIntensityStrong => isTagalog
      ? TlStrings.hapticIntensityStrong
      : EnStrings.hapticIntensityStrong;
  String get next => isTagalog ? TlStrings.next : EnStrings.next;
  String get getStarted =>
      isTagalog ? TlStrings.getStarted : EnStrings.getStarted;

  String get voiceNavigation =>
      isTagalog ? TlStrings.voiceNavigation : EnStrings.voiceNavigation;
  String get voiceNavigationDesc => isTagalog 
      ? TlStrings.voiceNavigationDesc
      : EnStrings.voiceNavigationDesc;
  String get onboardingLanguageOptions => isTagalog
      ? TlStrings.onboardingLanguageOptions
      : EnStrings.onboardingLanguageOptions;

  // Onboarding: permissions
  String get onboardingPermissionTitle => isTagalog
      ? TlStrings.onboardingPermissionTitle
      : EnStrings.onboardingPermissionTitle;
  String get onboardingPermissionSubtitle => isTagalog
      ? TlStrings.onboardingPermissionSubtitle
      : EnStrings.onboardingPermissionSubtitle;
  String get onboardingPermissionGrant => isTagalog
      ? TlStrings.onboardingPermissionGrant
      : EnStrings.onboardingPermissionGrant;
  String get onboardingPermissionGranted => isTagalog
      ? TlStrings.onboardingPermissionGranted
      : EnStrings.onboardingPermissionGranted;
  String get onboardingPermissionDenied => isTagalog
      ? TlStrings.onboardingPermissionDenied
      : EnStrings.onboardingPermissionDenied;
  String get onboardingPermissionSkip => isTagalog
      ? TlStrings.onboardingPermissionSkip
      : EnStrings.onboardingPermissionSkip;

  // Onboarding: finish
  String get onboardingFinishTitle => isTagalog
      ? TlStrings.onboardingFinishTitle
      : EnStrings.onboardingFinishTitle;
  String get onboardingFinishSubtitle => isTagalog
      ? TlStrings.onboardingFinishSubtitle
      : EnStrings.onboardingFinishSubtitle;
  String get onboardingFinishTour => isTagalog
      ? TlStrings.onboardingFinishTour
      : EnStrings.onboardingFinishTour;
  String get onboardingFinishOptions => isTagalog
      ? TlStrings.onboardingFinishOptions
      : EnStrings.onboardingFinishOptions;
  String get onboardingExitToScanner => isTagalog
      ? TlStrings.onboardingExitToScanner
      : EnStrings.onboardingExitToScanner;
  String get onboardingExitToTour => isTagalog
      ? TlStrings.onboardingExitToTour
      : EnStrings.onboardingExitToTour;
  String get onboardingWelcomeConfirm => isTagalog
      ? TlStrings.onboardingWelcomeConfirm
      : EnStrings.onboardingWelcomeConfirm;
  String get onboardingConfirmVision => isTagalog
      ? TlStrings.onboardingConfirmVision
      : EnStrings.onboardingConfirmVision;
  String get onboardingConfirmLanguage => isTagalog
      ? TlStrings.onboardingConfirmLanguage
      : EnStrings.onboardingConfirmLanguage;
  String get onboardingConfirmPerm => isTagalog
      ? TlStrings.onboardingConfirmPerm
      : EnStrings.onboardingConfirmPerm;
  String get onboardingConfirmPermAlready => isTagalog
      ? TlStrings.onboardingConfirmPermAlready
      : EnStrings.onboardingConfirmPermAlready;

  // Tutorial: App Navigation
  String get tutorialCardAppNavTitle => isTagalog
      ? TlStrings.tutorialCardAppNavTitle
      : EnStrings.tutorialCardAppNavTitle;
  String get tutorialCardAppNavDesc => isTagalog
      ? TlStrings.tutorialCardAppNavDesc
      : EnStrings.tutorialCardAppNavDesc;

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
  String ttsLangChanging(String langName) => isTagalog
      ? TlStrings.ttsLangChanging(langName)
      : EnStrings.ttsLangChanging(langName);
  String ttsLangChanged(String langName) => isTagalog
      ? TlStrings.ttsLangChanged(langName)
      : EnStrings.ttsLangChanged(langName);

  // Short visible label beside the spinner
  String get ttsLangChangingLabel => isTagalog
      ? TlStrings.ttsLangChangingLabel
      : EnStrings.ttsLangChangingLabel;

  // Settings confirmations: parametric (not stored as const strings)
  String ttsSettingEnabled(String settingName) => isTagalog
      ? 'Siyempre. Binuksan ko na ang $settingName para sa iyo.'
      : 'Certainly. I\'ve turned on $settingName for you.';
  String ttsSettingDisabled(String settingName) => isTagalog
      ? 'Naintindihan ko. Kasalukuyan nang naka-off ang $settingName.'
      : 'Understood. $settingName is now off.';
  String ttsSettingChanged(String settingName, String newValue) => isTagalog
      ? 'Sige! Binago ko na ang $settingName sa $newValue.'
      : 'Got it! I\'ve updated $settingName to $newValue.';

  // Scanner: results
  String ttsScanResult(String denomination) => isTagalog
      ? TlStrings.ttsScanResult(denomination)
      : EnStrings.ttsScanResult(denomination);
  String ttsScanResultWithType(String denomination, String type) => isTagalog
      ? TlStrings.ttsScanResultWithType(denomination, type)
      : EnStrings.ttsScanResultWithType(denomination, type);
  String ttsScanResultLowConfidence(String denomination, String type) =>
      isTagalog
      ? TlStrings.ttsScanResultLowConfidence(denomination, type)
      : EnStrings.ttsScanResultLowConfidence(denomination, type);

  // Scanner: camera state
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

  // Scanner: ambient hints
  String get ttsScannerIdle =>
      isTagalog ? TlStrings.ttsScannerIdle : EnStrings.ttsScannerIdle;
  String get ttsScanStarted =>
      isTagalog ? TlStrings.ttsScanStarted : EnStrings.ttsScanStarted;
  String get ttsProcessing =>
      isTagalog ? TlStrings.ttsProcessing : EnStrings.ttsProcessing;

  // Scanner: errors
  String get ttsCameraPermissionDenied => isTagalog
      ? TlStrings.ttsCameraPermissionDenied
      : EnStrings.ttsCameraPermissionDenied;
  String get ttsScanFailed =>
      isTagalog ? TlStrings.ttsScanFailed : EnStrings.ttsScanFailed;
  String get ttsCameraError =>
      isTagalog ? TlStrings.ttsCameraError : EnStrings.ttsCameraError;

  // ── Scanner Semantics labels ───────────────────────────────────────────────
  String get scannerSemanticIdle =>
      isTagalog ? TlStrings.scannerSemanticIdle : EnStrings.scannerSemanticIdle;
  String get scannerSemanticReady => isTagalog
      ? TlStrings.scannerSemanticReady
      : EnStrings.scannerSemanticReady;
  String get scannerSemanticScanning => isTagalog
      ? TlStrings.scannerSemanticScanning
      : EnStrings.scannerSemanticScanning;
  String get scannerSemanticProcessing => isTagalog
      ? TlStrings.scannerSemanticProcessing
      : EnStrings.scannerSemanticProcessing;
  String get scannerSemanticPaused => isTagalog
      ? TlStrings.scannerSemanticPaused
      : EnStrings.scannerSemanticPaused;
  String get scannerSemanticResult => isTagalog
      ? TlStrings.scannerSemanticResult
      : EnStrings.scannerSemanticResult;

  // ── Onboarding TTS ────────────────────────────────────────────────────────
  String get ttsOnboardingWelcome => isTagalog
      ? TlStrings.ttsOnboardingWelcome
      : EnStrings.ttsOnboardingWelcome;
  String get ttsOnboardingVision =>
      isTagalog ? TlStrings.ttsOnboardingVision : EnStrings.ttsOnboardingVision;
  String get ttsOnboardingLanguage => isTagalog
      ? TlStrings.ttsOnboardingLanguage
      : EnStrings.ttsOnboardingLanguage;
  String get ttsOnboardingProfileSelected => isTagalog
      ? TlStrings.ttsOnboardingProfileSelected
      : EnStrings.ttsOnboardingProfileSelected;

  // App Navigation Tutorial
  String get appNavTutorialTitle =>
      isTagalog ? TlStrings.appNavTutorialTitle : EnStrings.appNavTutorialTitle;
  String get appNavTutorialClose =>
      isTagalog ? TlStrings.appNavTutorialClose : EnStrings.appNavTutorialClose;
  String get appNavTutorialBack =>
      isTagalog ? TlStrings.appNavTutorialBack : EnStrings.appNavTutorialBack;
  String get appNavTutorialNext =>
      isTagalog ? TlStrings.appNavTutorialNext : EnStrings.appNavTutorialNext;
  String get appNavTutorialDone =>
      isTagalog ? TlStrings.appNavTutorialDone : EnStrings.appNavTutorialDone;
  String get appNavPage1Title =>
      isTagalog ? TlStrings.appNavPage1Title : EnStrings.appNavPage1Title;
  String get appNavPage1Body =>
      isTagalog ? TlStrings.appNavPage1Body : EnStrings.appNavPage1Body;
  String get appNavScannerLabel =>
      isTagalog ? TlStrings.appNavScannerLabel : EnStrings.appNavScannerLabel;
  String get appNavScannerDesc =>
      isTagalog ? TlStrings.appNavScannerDesc : EnStrings.appNavScannerDesc;
  String get appNavSettingsLabel =>
      isTagalog ? TlStrings.appNavSettingsLabel : EnStrings.appNavSettingsLabel;
  String get appNavSettingsDesc =>
      isTagalog ? TlStrings.appNavSettingsDesc : EnStrings.appNavSettingsDesc;
  String get appNavTutorialLabel =>
      isTagalog ? TlStrings.appNavTutorialLabel : EnStrings.appNavTutorialLabel;
  String get appNavTutorialDesc =>
      isTagalog ? TlStrings.appNavTutorialDesc : EnStrings.appNavTutorialDesc;
  String get appNavPage2Title =>
      isTagalog ? TlStrings.appNavPage2Title : EnStrings.appNavPage2Title;
  String get appNavPage2Body =>
      isTagalog ? TlStrings.appNavPage2Body : EnStrings.appNavPage2Body;
  String get appNavPage2Note =>
      isTagalog ? TlStrings.appNavPage2Note : EnStrings.appNavPage2Note;
  String get appNavPage3Title =>
      isTagalog ? TlStrings.appNavPage3Title : EnStrings.appNavPage3Title;
  String get appNavPage3Body =>
      isTagalog ? TlStrings.appNavPage3Body : EnStrings.appNavPage3Body;
  String get appNavPage3Note =>
      isTagalog ? TlStrings.appNavPage3Note : EnStrings.appNavPage3Note;
  String get appNavPage4Title =>
      isTagalog ? TlStrings.appNavPage4Title : EnStrings.appNavPage4Title;
  String get appNavPage4Body =>
      isTagalog ? TlStrings.appNavPage4Body : EnStrings.appNavPage4Body;
  String get appNavPage4Note =>
      isTagalog ? TlStrings.appNavPage4Note : EnStrings.appNavPage4Note;
  String get appNavPage5Title =>
      isTagalog ? TlStrings.appNavPage5Title : EnStrings.appNavPage5Title;
  String get appNavPage5Body =>
      isTagalog ? TlStrings.appNavPage5Body : EnStrings.appNavPage5Body;
  String get appNavPage5Note =>
      isTagalog ? TlStrings.appNavPage5Note : EnStrings.appNavPage5Note;
  String get appNavNavBottomBar =>
      isTagalog ? TlStrings.appNavNavBottomBar : EnStrings.appNavNavBottomBar;
  String get appNavNavGestural =>
      isTagalog ? TlStrings.appNavNavGestural : EnStrings.appNavNavGestural;
  String get appNavNavInertial =>
      isTagalog ? TlStrings.appNavNavInertial : EnStrings.appNavNavInertial;

  // Splash / startup screen
  String get splashGettingReady =>
      isTagalog ? TlStrings.splashGettingReady : EnStrings.splashGettingReady;
  String get splashLoadingVoice =>
      isTagalog ? TlStrings.splashLoadingVoice : EnStrings.splashLoadingVoice;
  String get splashReadyToScan =>
      isTagalog ? TlStrings.splashReadyToScan : EnStrings.splashReadyToScan;

  // Reset Settings
  String get resetSettingsTitle =>
      isTagalog ? TlStrings.resetSettingsTitle : EnStrings.resetSettingsTitle;
  String get resetSettingsSubtitle => isTagalog
      ? TlStrings.resetSettingsSubtitle
      : EnStrings.resetSettingsSubtitle;
  String get resetDialogTitle =>
      isTagalog ? TlStrings.resetDialogTitle : EnStrings.resetDialogTitle;
  String get resetDialogBody =>
      isTagalog ? TlStrings.resetDialogBody : EnStrings.resetDialogBody;
  String get resetDialogRunOnboarding => isTagalog
      ? TlStrings.resetDialogRunOnboarding
      : EnStrings.resetDialogRunOnboarding;
  String get resetDialogYesOnboarding => isTagalog
      ? TlStrings.resetDialogYesOnboarding
      : EnStrings.resetDialogYesOnboarding;
  String get resetDialogNoOnboarding => isTagalog
      ? TlStrings.resetDialogNoOnboarding
      : EnStrings.resetDialogNoOnboarding;
  String get resetDialogCancel =>
      isTagalog ? TlStrings.resetDialogCancel : EnStrings.resetDialogCancel;

  // Tutorial audio guides
  String get ttsInertialGuide =>
      isTagalog ? TlStrings.ttsInertialGuide : EnStrings.ttsInertialGuide;
  String get ttsGesturalGuide =>
      isTagalog ? TlStrings.ttsGesturalGuide : EnStrings.ttsGesturalGuide;
  String get ttsShakeGuide =>
      isTagalog ? TlStrings.ttsShakeGuide : EnStrings.ttsShakeGuide;
  String get ttsHapticGuide =>
      isTagalog ? TlStrings.ttsHapticGuide : EnStrings.ttsHapticGuide;

  // Tutorial hero semantics
  String get inertialHeroSemantic => isTagalog
      ? TlStrings.inertialHeroSemantic
      : EnStrings.inertialHeroSemantic;
  String get gesturalHeroSemantic => isTagalog
      ? TlStrings.gesturalHeroSemantic
      : EnStrings.gesturalHeroSemantic;
  String get shakeHeroSemantic =>
      isTagalog ? TlStrings.shakeHeroSemantic : EnStrings.shakeHeroSemantic;
  String get hapticHeroSemantic =>
      isTagalog ? TlStrings.hapticHeroSemantic : EnStrings.hapticHeroSemantic;

  // Tutorial interactive zone semantics
  String get inertialPlaygroundSemantic => isTagalog
      ? TlStrings.inertialPlaygroundSemantic
      : EnStrings.inertialPlaygroundSemantic;
  String get gesturalPlaygroundSemantic => isTagalog
      ? TlStrings.gesturalPlaygroundSemantic
      : EnStrings.gesturalPlaygroundSemantic;
  String get shakePlaygroundSemantic => isTagalog
      ? TlStrings.shakePlaygroundSemantic
      : EnStrings.shakePlaygroundSemantic;

  // Earcon setting
  String get earconTitle =>
      isTagalog ? TlStrings.earconTitle : EnStrings.earconTitle;
  String get earconSubtitle =>
      isTagalog ? TlStrings.earconSubtitle : EnStrings.earconSubtitle;
  String get earconSubtitleFull =>
      isTagalog ? TlStrings.earconSubtitleFull : EnStrings.earconSubtitleFull;

  // Result screen
  String get resultUncertainLabel => isTagalog
      ? TlStrings.resultUncertainLabel
      : EnStrings.resultUncertainLabel;
  String get resultTypeCoin =>
      isTagalog ? TlStrings.resultTypeCoin : EnStrings.resultTypeCoin;
  String get resultTypeBill =>
      isTagalog ? TlStrings.resultTypeBill : EnStrings.resultTypeBill;
  String get confidenceVeryConfident => isTagalog
      ? TlStrings.confidenceVeryConfident
      : EnStrings.confidenceVeryConfident;
  String get confidenceConfident =>
      isTagalog ? TlStrings.confidenceConfident : EnStrings.confidenceConfident;
  String get confidenceUncertain =>
      isTagalog ? TlStrings.confidenceUncertain : EnStrings.confidenceUncertain;
  String get resultConfidencePre =>
      isTagalog ? TlStrings.resultConfidencePre : EnStrings.resultConfidencePre;
  String get resultUncertainSuffix => isTagalog
      ? TlStrings.resultUncertainSuffix
      : EnStrings.resultUncertainSuffix;
  String resultConfidentSuffix(String d, String t) => isTagalog
      ? TlStrings.resultConfidentSuffix(d, t)
      : EnStrings.resultConfidentSuffix(d, t);
  String resultGoBackHintPre(String s) => isTagalog
      ? TlStrings.resultGoBackHintPre(s)
      : EnStrings.resultGoBackHintPre(s);
  String get resultGoBackLink =>
      isTagalog ? TlStrings.resultGoBackLink : EnStrings.resultGoBackLink;
  String get resultDismissLabel =>
      isTagalog ? TlStrings.resultDismissLabel : EnStrings.resultDismissLabel;
  String get resultConfirmLabel =>
      isTagalog ? TlStrings.resultConfirmLabel : EnStrings.resultConfirmLabel;
  String get resultSemanticUncertain => isTagalog
      ? TlStrings.resultSemanticUncertain
      : EnStrings.resultSemanticUncertain;
  String resultSemanticConfident(String d, String t, String l) => isTagalog
      ? TlStrings.resultSemanticConfident(d, t, l)
      : EnStrings.resultSemanticConfident(d, t, l);
  String resultGoBackHintSemantic(String s) => isTagalog
      ? TlStrings.resultGoBackHintSemantic(s)
      : EnStrings.resultGoBackHintSemantic(s);

  // ── Voice Tutorial ──
  String get tutorialCardVoiceTitle => isTagalog
      ? TlStrings.tutorialCardVoiceTitle
      : EnStrings.tutorialCardVoiceTitle;
  String get tutorialCardVoiceDesc => isTagalog
      ? TlStrings.tutorialCardVoiceDesc
      : EnStrings.tutorialCardVoiceDesc;
  String get voiceTutorialBadge =>
      isTagalog ? TlStrings.voiceTutorialBadge : EnStrings.voiceTutorialBadge;
  String get voiceTutorialDescription => isTagalog
      ? TlStrings.voiceTutorialDescription
      : EnStrings.voiceTutorialDescription;
  String get voiceTutorialStep1 =>
      isTagalog ? TlStrings.voiceTutorialStep1 : EnStrings.voiceTutorialStep1;
  String get voiceTutorialStep2 =>
      isTagalog ? TlStrings.voiceTutorialStep2 : EnStrings.voiceTutorialStep2;
  String get voiceTutorialStep3 =>
      isTagalog ? TlStrings.voiceTutorialStep3 : EnStrings.voiceTutorialStep3;
  String get voiceTutorialStep4 =>
      isTagalog ? TlStrings.voiceTutorialStep4 : EnStrings.voiceTutorialStep4;
  String get ttsVoiceGuide =>
      isTagalog ? TlStrings.ttsVoiceGuide : EnStrings.ttsVoiceGuide;
  String get voiceHeroSemantic =>
      isTagalog ? TlStrings.voiceHeroSemantic : EnStrings.voiceHeroSemantic;
  String get voicePlaygroundSemantic => isTagalog
      ? TlStrings.voicePlaygroundSemantic
      : EnStrings.voicePlaygroundSemantic;
  String get voiceDetectedLabel =>
      isTagalog ? TlStrings.voiceDetectedLabel : EnStrings.voiceDetectedLabel;
  String get voiceListeningLabel =>
      isTagalog ? TlStrings.voiceListeningLabel : EnStrings.voiceListeningLabel;
  String get voiceWakeWordDetectedLabel => isTagalog
      ? TlStrings.voiceWakeWordDetectedLabel
      : EnStrings.voiceWakeWordDetectedLabel;
  String get voiceTryItHint =>
      isTagalog ? TlStrings.voiceTryItHint : EnStrings.voiceTryItHint;
  String get voiceHelpCommandList =>
      isTagalog ? TlStrings.voiceHelpCommandList : EnStrings.voiceHelpCommandList;
  String get voiceStatusStandingBy =>
      isTagalog ? TlStrings.voiceStatusStandingBy : EnStrings.voiceStatusStandingBy;
  String get voicePromptWhatShallIDo =>
      isTagalog ? TlStrings.voicePromptWhatShallIDo : EnStrings.voicePromptWhatShallIDo;
  String get blindTapToSpeak =>
      isTagalog ? TlStrings.blindTapToSpeak : EnStrings.blindTapToSpeak;

  // Categorized Commands
  String get voiceCommandCatNav => isTagalog ? TlStrings.voiceCommandCatNav : EnStrings.voiceCommandCatNav;
  String get voiceCommandCatScan => isTagalog ? TlStrings.voiceCommandCatScan : EnStrings.voiceCommandCatScan;
  String get voiceCommandCatHelp => isTagalog ? TlStrings.voiceCommandCatHelp : EnStrings.voiceCommandCatHelp;

  String get voiceCmdOpenSettings => isTagalog ? TlStrings.voiceCmdOpenSettings : EnStrings.voiceCmdOpenSettings;
  String get voiceCmdGoHome => isTagalog ? TlStrings.voiceCmdGoHome : EnStrings.voiceCmdGoHome;
  String get voiceCmdOpenTutorial => isTagalog ? TlStrings.voiceCmdOpenTutorial : EnStrings.voiceCmdOpenTutorial;
  String get voiceCmdCommandList => isTagalog ? TlStrings.voiceCmdCommandList : EnStrings.voiceCmdCommandList;
  String get voiceCmdFlashOn => isTagalog ? TlStrings.voiceCmdFlashOn : EnStrings.voiceCmdFlashOn;
  String get voiceCmdFlashOff => isTagalog ? TlStrings.voiceCmdFlashOff : EnStrings.voiceCmdFlashOff;
  String get voiceCmdFrontCam => isTagalog ? TlStrings.voiceCmdFrontCam : EnStrings.voiceCmdFrontCam;
  String get voiceCmdBackCam => isTagalog ? TlStrings.voiceCmdBackCam : EnStrings.voiceCmdBackCam;
  String get voiceCmdHelp => isTagalog ? TlStrings.voiceCmdHelp : EnStrings.voiceCmdHelp;
  String get voiceCmdExit => isTagalog ? TlStrings.voiceCmdExit : EnStrings.voiceCmdExit;

  // Command Confirmation & Feedback
  String get voiceConfirmPrefix => isTagalog ? TlStrings.voiceConfirmPrefix : EnStrings.voiceConfirmPrefix;
  String get voiceConfirmSuffix => isTagalog ? TlStrings.voiceConfirmSuffix : EnStrings.voiceConfirmSuffix;
  String get voiceActionSuccess => isTagalog ? TlStrings.voiceActionSuccess : EnStrings.voiceActionSuccess;
  String get voiceActionCancelled => isTagalog ? TlStrings.voiceActionCancelled : EnStrings.voiceActionCancelled;
  String get voiceFlashFrontError => isTagalog ? TlStrings.voiceFlashFrontError : EnStrings.voiceFlashFrontError;

  // Scanner status labels
  String get scannerStatusIdle =>
      isTagalog ? TlStrings.scannerStatusIdle : EnStrings.scannerStatusIdle;
  String get scannerStatusPreviewing => isTagalog
      ? TlStrings.scannerStatusPreviewing
      : EnStrings.scannerStatusPreviewing;
  String get scannerStatusScanning => isTagalog
      ? TlStrings.scannerStatusScanning
      : EnStrings.scannerStatusScanning;
  String get scannerStatusProcessing => isTagalog
      ? TlStrings.scannerStatusProcessing
      : EnStrings.scannerStatusProcessing;
  String get scannerStatusResult =>
      isTagalog ? TlStrings.scannerStatusResult : EnStrings.scannerStatusResult;
  String get scannerTapToOpen =>
      isTagalog ? TlStrings.scannerTapToOpen : EnStrings.scannerTapToOpen;
}
