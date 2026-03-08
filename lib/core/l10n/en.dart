/// English (en) string resources for MoneySense.
abstract final class EnStrings {
  // ── General ───────────────────────────────────────────────────────────────
  static const String appName = 'MoneySense';

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  static const String navSettings = 'Settings';
  static const String navScan = 'Scan';
  static const String navTutorial = 'Tutorial';

  // ── Settings screen ───────────────────────────────────────────────────────
  static const String settings = 'Settings';

  // Section headers
  static const String sectionGeneral = 'General';
  static const String sectionScanning = 'Scanning';
  static const String sectionNavigation = 'Navigation';
  static const String sectionHelpSupport = 'Help & Support';

  // General — titles
  static const String theme = 'Theme';
  static const String themeSystem = 'System';
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String language = 'Language';
  static const String languageEnglish = 'English';
  static const String languageTagalog = 'Tagalog';
  static const String fontSize = 'Font Size';

  // General — subtitles
  static const String themeSubtitle =
      'Choose between light, dark, or follow your system setting.';
  static const String languageSubtitle =
      'Select the language used throughout the app.';
  static const String fontSizeSubtitle =
      'Adjust the text size to what is most comfortable for you.';

  // Scanning — titles
  static const String useFrontCamera = 'Use Front Camera';
  static const String useFlashlight = 'Use Flashlight';
  static const String denominationVibration = 'Denomination Vibration';

  // Scanning — subtitles
  static const String useFrontCameraSubtitle =
      'Flip to the front-facing camera for scanning.';
  static const String useFlashlightSubtitle =
      'Keep the flashlight on while the camera is active.';
  static const String denominationVibrationSubtitle =
      'Feel a unique vibration pattern for each denomination scanned.';

  // Navigation — titles
  static const String shakeToGoBack = 'Shake to Go Back';
  static const String goBackTimerOnResult = 'Go Back Timer on Result';
  static const String gesturalNavigation = 'Gestural Navigation';
  static const String inertialNavigation = 'Inertial Navigation';

  // Navigation — subtitles
  static const String shakeToGoBackSubtitle =
      'Shake your phone to navigate back from any screen.';
  static const String goBackTimerSubtitle =
      'Automatically return to the scanner after showing a result.';
  static const String gesturalNavigationSubtitle =
      'Swipe on the scanner to open Settings, Tutorial, or toggle flash.';
  static const String inertialNavigationSubtitle =
      'Tilt your phone left or right to navigate between screens.';

  // Help & Support — subtitles
  static const String checkForUpdatesSubtitle =
      'See if a newer version of MoneySense is available.';
  static const String playOnboardingSubtitle =
      'Replay the first-run setup to change your profile or language.';
  static const String appInformationSubtitle =
      'View version number, licenses, and build details.';
  static const String leaveAFeedbackSubtitle =
      'Tell us how we can improve MoneySense for you.';
  static const String termsOfServicesSubtitle =
      'Read the terms and conditions for using this application.';

  // Help & Support — titles
  static const String checkForUpdates = 'Check for Updates';
  static const String playOnboardingSetup = 'Play Onboarding Setup';
  static const String appInformation = 'App Information';
  static const String leaveAFeedback = 'Leave a Feedback';
  static const String termsOfServices = 'Terms of Services';

  // Inertial navigation dialog — now points to the real tutorial
  static const String inertialDialogBody =
      'Tilt your phone left to open Tutorial or right to open Settings — '
      'no tapping required.\n\nTap the help button to open the interactive tutorial.';
  static const String gotIt = 'Got it';

  // ── Tutorial card — Inertial Navigation ───────────────────────────────────
  static const String tutorialCardInertialTitle = 'Inertial Navigation';
  static const String tutorialCardInertialDesc =
      'Tilt your phone left or right to navigate between screens — '
      'no buttons or taps required.';

  // ── Tutorial: Inertial Navigation ─────────────────────────────────────────
  static const String inertialTutorialBadge = 'Navigation';
  static const String inertialTutorialDescription =
      'Hold your phone upright and tilt it left to open Tutorial or right '
      'to open Settings. On any sub-screen, tilt back to return home. '
      'The phone must be held upright — it will not trigger while lying flat.';
  static const String inertialTutorialStep1 =
      'Enable "Inertial Navigation" in Settings → Navigation.';
  static const String inertialTutorialStep2 =
      'Hold your phone upright in portrait orientation.';
  static const String inertialTutorialStep3 =
      'Tilt RIGHT to open Settings, tilt LEFT to open Tutorial.';
  static const String inertialTutorialStep4 =
      'On Settings or Tutorial, tilt either direction to return home.';
  static const String inertialTutorialStep5 =
      'The phone must be tilted steadily — a quick flick will not trigger it.';
  static const String inertialTiltRight = 'Tilt right → Settings';
  static const String inertialTiltLeft  = 'Tilt left → Tutorial';
  static const String inertialTiltBack  = 'Tilt either → Go back';
  static const String inertialTryItHint = 'Tilt your phone left or right to try';
  static const String inertialTiltDetected = '✓ Tilt detected!';
  static const String inertialFlatWarning =
      'Phone is flat — hold it upright to activate';
  static const String inertialLegendRight = 'Tilt right';
  static const String inertialLegendLeft  = 'Tilt left';
  static const String inertialLegendOpensSettings  = 'Opens Settings';
  static const String inertialLegendOpensTutorial  = 'Opens Tutorial';
  static const String inertialLegendGoBack         = 'Go back (from sub-screens)';

  // ── Scanner screen ────────────────────────────────────────────────────────
  static const String scanning = 'Scanning...';
  static const String processing = 'Processing...';
  static const String tapToScan = 'Double-tap to scan';
  static const String paused = 'Paused';
  static const String doubleTapToResume = 'Double-tap to resume';

  // ── Tutorial screen ───────────────────────────────────────────────────────
  static const String tutorialScreenTitle = 'Learn the features';
  static const String tutorialScreenSubtitle =
      'Tap any tutorial below to learn how each feature works '
      'with live, interactive examples.';
  static const String tutorialSectionScanning = 'SCANNING';
  static const String tutorialSectionNavigation = 'NAVIGATION';

  // Tutorial card — Denomination Vibration
  static const String tutorialCardDenomTitle = 'Denomination Vibration';
  static const String tutorialCardDenomDesc =
      'Learn each denomination\'s unique vibration pattern and play them to feel the difference.';

  // Tutorial card — Shake to Go Back
  static const String tutorialCardShakeTitle = 'Shake to Go Back';
  static const String tutorialCardShakeDesc =
      'Shake your phone to navigate back from any screen — no buttons required.';

  // Tutorial card — Gestural Navigation
  static const String tutorialCardGestureTitle = 'Gestural Navigation';
  static const String tutorialCardGestureDesc =
      'Swipe on the scanner to jump between screens and toggle the flashlight.';

  // ── Tutorial: Denomination Vibration ─────────────────────────────────────
  static const String denomTutorialBadge = 'Scanning';
  static const String denomTutorialDescription =
      'Each Philippine denomination produces a unique vibration pattern '
      'so you can identify your currency by touch alone — no screen needed.';
  static const String denomTutorialStep1 =
      'Enable Denomination Vibration in Settings → Scanning.';
  static const String denomTutorialStep2 =
      'Scan a bill or coin with the camera.';
  static const String denomTutorialStep3 =
      'Feel the vibration pattern that matches the denomination.';
  static const String denomTutorialStep4 =
      'Use this list to learn and memorise each pattern.';
  static const String denomPlayDemoLabel = 'Play Vibration Demo';
  static const String denomPlayDemoSub = 'Plays all patterns in sequence';
  static const String denomPatternsLabel = 'PATTERNS';

  // ── Tutorial: Shake to Go Back ────────────────────────────────────────────
  static const String shakeTutorialBadge = 'Navigation';
  static const String shakeTutorialDescription =
      'Give your phone a quick, intentional shake and MoneySense will '
      'navigate back to the previous screen — no button press needed.';
  static const String shakeTutorialStep1 =
      'Enable "Shake to Go Back" in Settings → Navigation.';
  static const String shakeTutorialStep2 =
      'Open any screen — Settings, Tutorial, or a scan result.';
  static const String shakeTutorialStep3 =
      'Shake your phone once with a confident wrist flick.';
  static const String shakeTutorialStep4 =
      'Feel the vibration confirmation as the screen goes back.';
  static const String shakeTryItTitle = 'Try it now';
  static const String shakeTryItHint = 'Shake your phone with a quick wrist flick';
  static const String shakeDetected = '✓ Shake detected!';
  static const String shakeCountSingle = '1 shake detected';
  static String shakeCountMultiple(int n) => '$n shakes detected';

  // ── Tutorial: Gestural Navigation ─────────────────────────────────────────
  static const String gestureTutorialBadge = 'Navigation';
  static const String gestureTutorialDescription =
      'Navigate MoneySense hands-free using swipes and taps on the '
      'scanner screen — perfect when your other hand is holding currency.';
  static const String gestureTutorialStep1 =
      'Enable "Gestural Navigation" in Settings → Navigation.';
  static const String gestureTutorialStep2 =
      'Swipe RIGHT on the scanner screen to open Settings.';
  static const String gestureTutorialStep3 =
      'Swipe LEFT on the scanner screen to open Tutorial.';
  static const String gestureTutorialStep4 =
      'Swipe UP to toggle the flashlight on or off.';
  static const String gestureTutorialStep5 =
      'Double-tap the scanner to freeze or resume the live preview.';
  static const String gestureTryHint = 'Swipe or double-tap here to try';
  static const String gestureSwipeRight = 'Swipe right';
  static const String gestureSwipeLeft = 'Swipe left';
  static const String gestureSwipeUp = 'Swipe up';
  static const String gestureDoubleTap = 'Double-tap';
  static const String gestureOpensSettings = 'Opens Settings';
  static const String gestureOpensTutorial = 'Opens Tutorial';
  static const String gestureTogglesFlash = 'Toggles flashlight';
  static const String gestureFreezesPreview = 'Freezes / resumes preview';
  static const String gestureLabelRight = '→ Opens Settings';
  static const String gestureLabelLeft = '← Opens Tutorial';
  static const String gestureLabelUp = '↑ Toggles Flashlight';
  static const String gestureLabelTap = '⊙ Preview Frozen / Resumed';

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const String onboardingWelcomeTitle = 'Welcome to MoneySense';
  static const String onboardingWelcomeSubtitle =
      'Your accessible Philippine currency identifier.';
  static const String onboardingVisionTitle = 'How do you see?';
  static const String onboardingVisionSubtitle =
      'We\'ll adjust the app to best serve your needs.';
  static const String visionLowVision = 'Low Vision';
  static const String visionPartiallyBlind = 'Partially Blind';
  static const String visionFullyBlind = 'Fully Blind';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';
}
