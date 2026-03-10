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
  static const String sectionAccessibility = 'Accessibility';
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
  static const String themeSubtitleFull =
      'Choose how the app looks. Light mode uses a white background; dark mode uses a dark navy background; system mode automatically matches your phone\'s current display setting.';
  static const String languageSubtitle =
      'Select the language used throughout the app.';
  static const String languageSubtitleFull =
      'Choose between English and Filipino (Tagalog). This changes all on-screen text and spoken announcements throughout the app.';
  static const String fontSizeSubtitle =
      'Adjust the text size to what is most comfortable for you.';
  static const String fontSizeSubtitleFull =
      "Drag the slider to make text larger or smaller. Your vision profile sets a minimum size floor. You can go larger, but not below your profile's floor.";

  // Scanning — titles
  static const String useFrontCamera = 'Use Front Camera';
  static const String useFlashlight = 'Use Flashlight';
  static const String denominationVibration = 'Denomination Vibration';

  // Scanning — subtitles
  static const String useFrontCameraSubtitle =
      'Flip to the front-facing camera for scanning.';
  static const String useFrontCameraSubtitleFull =
      'When enabled, MoneySense uses the front (selfie) camera instead of the rear camera. Useful if you prefer to hold the phone facing toward you while scanning.';
  static const String useFlashlightSubtitle =
      'Keep the flashlight on while the camera is active.';
  static const String useFlashlightSubtitleFull =
      'Turns on the rear flashlight whenever the scanner is open, helping illuminate the bill in low-light conditions. Only works with the rear camera.';
  static const String denominationVibrationSubtitle =
      'Feel a unique vibration pattern for each denomination scanned.';
  static const String denominationVibrationSubtitleFull =
      'When a bill is identified, your phone vibrates in a pattern unique to that denomination, so you can feel the result without listening. Each bill value has a distinct pattern.';

  // Navigation — titles
  static const String shakeToGoBack = 'Shake to Go Back';
  static const String goBackTimerOnResult = 'Go Back Timer on Result';
  static const String gesturalNavigation = 'Gestural Navigation';
  static const String inertialNavigation = 'Inertial Navigation';

  // Navigation — subtitles
  static const String shakeToGoBackSubtitle =
      'Shake your phone to navigate back from any screen.';
  static const String shakeToGoBackSubtitleFull =
      'Give your phone a quick shake to return to the previous screen from anywhere in the app. The shake threshold is calibrated to avoid accidental triggers during normal movement.';
  static const String goBackTimerSubtitle =
      'Automatically return to the scanner after showing a result.';
  static const String goBackTimerSubtitleFull =
      'After a denomination is identified, MoneySense will automatically return to the scanner after the number of seconds you set here. Set it to 0 to disable the timer and stay on the result screen.';
  static const String gesturalNavigationSubtitle =
      'Swipe on the scanner to open Settings, Tutorial, or toggle flash.';
  static const String gesturalNavigationSubtitleFull =
      'On the scanner screen: swipe right to open Settings, swipe left to open Tutorial, swipe up to toggle the flashlight, and double-tap to freeze or unfreeze the live camera preview.';
  static const String inertialNavigationSubtitle =
      'Tilt your phone left or right to navigate between screens.';
  static const String inertialNavigationSubtitleFull =
      'Hold your phone upright and tilt it left to open the Tutorial, or right to open Settings. On any sub-screen, tilt either direction to go back. You must hold the tilt for one second before it triggers.';

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
      'Tilt your phone left to open Tutorial or right to open Settings. '
      'no tapping required.\n\nTap the help button to open the interactive tutorial.';
  static const String gotIt = 'Got it';

  // ── Tutorial card — Inertial Navigation ───────────────────────────────────
  static const String tutorialCardInertialTitle = 'Inertial Navigation';
  static const String tutorialCardInertialDesc =
      'Tilt your phone left or right to navigate between screens. '
      'no buttons or taps required.';

  // ── Tutorial: Inertial Navigation ─────────────────────────────────────────
  static const String inertialTutorialBadge = 'Navigation';
  static const String inertialTutorialDescription =
      'Hold your phone upright and tilt it left to open Tutorial or right '
      'to open Settings. On any sub-screen, tilt back to return home. '
      'The phone must be held upright. It will not trigger while lying flat.';
  static const String inertialTutorialStep1 =
      'Enable "Inertial Navigation" in Settings → Navigation.';
  static const String inertialTutorialStep2 =
      'Hold your phone upright in portrait orientation.';
  static const String inertialTutorialStep3 =
      'Tilt RIGHT to open Settings, tilt LEFT to open Tutorial.';
  static const String inertialTutorialStep4 =
      'On Settings or Tutorial, tilt either direction to return home.';
  static const String inertialTutorialStep5 =
      'The phone must be tilted steadily. A quick flick will not trigger it.';
  static const String inertialTiltRight = 'Tilt right → Settings';
  static const String inertialTiltLeft = 'Tilt left → Tutorial';
  static const String inertialTiltBack = 'Tilt either → Go back';
  static const String inertialTryItHint =
      'Tilt your phone left or right to try';
  static const String inertialTiltDetected = '✓ Tilt detected!';
  static const String inertialFlatWarning =
      'Phone is flat. Hold it upright to activate';
  static const String inertialLegendRight = 'Tilt right';
  static const String inertialLegendLeft = 'Tilt left';
  static const String inertialLegendOpensSettings = 'Opens Settings';
  static const String inertialLegendOpensTutorial = 'Opens Tutorial';
  static const String inertialLegendGoBack = 'Go back (from sub-screens)';

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
      'Shake your phone to navigate back from any screen, no buttons required.';

  // Tutorial card — Gestural Navigation
  static const String tutorialCardGestureTitle = 'Gestural Navigation';
  static const String tutorialCardGestureDesc =
      'Swipe on the scanner to jump between screens and toggle the flashlight.';

  // ── Tutorial: Denomination Vibration ─────────────────────────────────────
  static const String denomTutorialBadge = 'Scanning';
  static const String denomTutorialDescription =
      'Each Philippine denomination produces a unique vibration pattern '
      'so you can identify your currency by touch alone, no screen needed.';
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
      'navigate back to the previous screen, no button press needed.';
  static const String shakeTutorialStep1 =
      'Enable "Shake to Go Back" in Settings → Navigation.';
  static const String shakeTutorialStep2 =
      'Open any screen: Settings, Tutorial, or a scan result.';
  static const String shakeTutorialStep3 =
      'Shake your phone once with a confident wrist flick.';
  static const String shakeTutorialStep4 =
      'Feel the vibration confirmation as the screen goes back.';
  static const String shakeTryItTitle = 'Try it now';
  static const String shakeTryItHint =
      'Shake your phone with a quick wrist flick';
  static const String shakeDetected = '✓ Shake detected!';
  static const String shakeCountSingle = '1 shake detected';
  static String shakeCountMultiple(int n) => '$n shakes detected';

  // ── Tutorial: Gestural Navigation ─────────────────────────────────────────
  static const String gestureTutorialBadge = 'Navigation';
  static const String gestureTutorialDescription =
      'Navigate MoneySense hands-free using swipes and taps on the '
      'scanner screen, perfect when your other hand is holding currency.';
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

  // ── Accessibility settings ────────────────────────────────────────────────

  // Vision profile
  static const String visionProfileTitle = 'Vision Profile';
  static const String visionProfileSubtitle =
      'Adjusts TTS verbosity, haptic strength, and font floor to your needs.';
  static const String visionProfileSubtitleFull =
      'Your vision profile is the foundation of MoneySense\'s accessibility system. Choosing a profile automatically sets the speech verbosity, haptic strength, minimum font size, and whether audio is treated as primary. You can still fine-tune each setting individually after choosing.';

  // TTS
  static const String ttsTitle = 'Text-to-Speech';
  static const String ttsSubtitle = 'Speaks scan results and app events aloud.';
  static const String ttsSubtitleFull =
      'When enabled, MoneySense reads aloud the denomination of each bill scanned. At higher verbosity levels, it also announces navigation events, screen names, and system state. Uses your device\'s built-in speech engine.';
  static const String ttsVerbosityTitle = 'Speech Verbosity';
  static const String ttsVerbositySubtitle =
      'How much the app speaks: results only, or full narration.';
  static const String ttsVerbositySubtitleFull =
      'Results: only the scanned denomination is spoken. Standard: results plus navigation events and setting confirmations. Full: everything is narrated: screen transitions, scanner state, idle prompts, and all interactions.';
  static const String ttsVerbosityMinimal = 'Minimal';
  static const String ttsVerbosityStandard = 'Standard';
  static const String ttsVerbosityFull = 'Full';

  // Haptics
  static const String hapticTitle = 'Haptic Feedback';
  static const String hapticSubtitle =
      'Vibration feedback for scan results and navigation.';
  static const String hapticSubtitleFull =
      'When enabled, your phone vibrates in response to scan results, navigation, and other events. The vibration patterns are distinct per event type so they can be told apart by feel alone, especially important when audio is not available.';
  static const String hapticIntensityTitle = 'Haptic Intensity';
  static const String hapticIntensitySubtitle =
      'How strongly the phone vibrates for each event.';
  static const String hapticIntensitySubtitleFull =
      'Subtle: light haptic click only, no motor vibration. Medium: haptic click plus a short motor pulse. Strong: haptic click plus rich multi-pulse patterns, each event type (scan result, error, navigation) has a distinct pattern you can learn to recognise.';
  static const String hapticIntensitySubtle = 'Subtle';
  static const String hapticIntensityMedium = 'Medium';
  static const String hapticIntensityStrong = 'Strong';

  // Vision profile descriptions (shown in the tile below the pills)
  static const String visionLowVisionDesc =
      'Visual UI with amplified text and contrast. TTS and haptics are optional.';
  static const String visionPartiallyBlindDesc =
      'Audio-assisted. TTS announces results and navigation automatically.';
  static const String visionFullyBlindDesc =
      'Audio-primary. TTS narrates everything. Rich haptic patterns carry meaning.';

  // ── Onboarding
  static const String onboardingWelcomeTitle = 'Welcome to MoneySense';
  static const String onboardingWelcomeSubtitle =
      'Your accessible Philippine currency identifier.';
  static const String onboardingVisionTitle = 'How do you see?';
  static const String onboardingVisionSubtitle =
      'We\'ll adjust the app to best serve your needs.';
  static const String visionLowVision = 'Low Vision';
  static const String visionPartiallyBlind = 'Partially Blind';
  static const String visionFullyBlind = 'Fully Blind';

  // Onboarding: Navigation style
  static const String onboardingNavTitle = 'How do you navigate?';
  static const String onboardingNavSubtitle =
      'Choose how you want to move between screens. You can change this later in Settings.';
  static const String onboardingNavNormal = 'Standard';
  static const String onboardingNavNormalDesc =
      'Use the buttons and bottom navigation bar.';
  static const String onboardingNavGestural = 'Gestural';
  static const String onboardingNavGesturalDesc =
      'Swipe left or right to open Settings and Tutorial.';
  static const String onboardingNavInertial = 'Inertial';
  static const String onboardingNavInertialDesc =
      'Tilt your phone left or right to navigate.';

  // Onboarding: Permissions
  static const String onboardingPermissionTitle = 'Camera access';
  static const String onboardingPermissionSubtitle =
      'MoneySense needs the camera to identify Philippine currency. Tap the button below to grant access.';
  static const String onboardingPermissionGrant = 'Grant camera access';
  static const String onboardingPermissionGranted = 'Camera access granted';
  static const String onboardingPermissionDenied =
      'Camera access was denied. You can allow it later in your device Settings.';
  static const String onboardingPermissionSkip = 'Skip for now';

  // Onboarding: Finish
  static const String onboardingFinishTitle = "You're all set!";
  static const String onboardingFinishSubtitle =
      'MoneySense is ready to use. Would you like a quick tour of the app first?';
  static const String onboardingFinishTour = 'Show me around';
  static const String onboardingFinishSkip = 'Start scanning';

  // Tutorial: App Navigation overview card
  static const String tutorialCardAppNavTitle = 'App Navigation';
  static const String tutorialCardAppNavDesc =
      'A guided walkthrough of the three screens and how to reach them.';

  static const String next = 'Next';
  static const String getStarted = 'Get Started';

  // ── TTS speech strings ────────────────────────────────────────────────────
  // These are spoken aloud, not shown on screen.
  // Written for natural speech — concise, unambiguous, no symbols.

  // App-level
  static const String ttsSpeechEnabled = 'Text to speech enabled.';
  static const String ttsSpeechDisabling = 'Text to speech turning off.';

  // Navigation
  static const String ttsNavSettings = 'Settings.';
  static const String ttsNavTutorial = 'Tutorial.';
  static const String ttsNavHome = 'Scanner.';

  // Language change — spoken before and after the engine switches
  static String ttsLangChanging(String langName) =>
      'Changing audio to $langName.';
  static String ttsLangChanged(String langName) =>
      'Done. Now speaking $langName.';

  // Short visible label shown next to the spinner during language change
  static const String ttsLangChangingLabel = 'Changing language…';

  // Settings confirmations — use parametric helpers (see AppLocalizations)
  // ttsSettingEnabled / ttsSettingDisabled / ttsSettingChanged
  // are generated via methods in AppLocalizations, not const strings.

  // Scanner — results
  // ttsScanResult(denomination) — minimal: just the amount
  static String ttsScanResult(String denomination) => denomination;
  // ttsScanResultWithType(denomination, type) — standard: amount + type
  static String ttsScanResultWithType(String denomination, String type) =>
      '$denomination $type.';
  // ttsScanResultLowConfidence(denomination, type) — full: low confidence
  static String ttsScanResultLowConfidence(String denomination, String type) =>
      '$denomination $type. Not fully certain, please verify.';

  // Scanner — camera state
  static const String ttsCameraOpened = 'Camera ready.';
  static const String ttsCameraClosed = 'Camera closed.';
  static const String ttsPreviewFrozen = 'Preview frozen.';
  static const String ttsPreviewResumed = 'Preview resumed.';
  static const String ttsFlashOn = 'Flashlight on.';
  static const String ttsFlashOff = 'Flashlight off.';

  // Scanner — ambient hints (full verbosity only)
  static const String ttsScannerIdle =
      'Hold a bill or coin flat in front of the camera to scan.';
  static const String ttsScanStarted = 'Scanning.';
  static const String ttsProcessing = 'Processing.';

  // Scanner — errors
  static const String ttsCameraPermissionDenied =
      'Camera access denied. Please allow camera permission in Settings.';
  static const String ttsScanFailed =
      'Could not identify the currency. Please try again with better lighting.';
  static const String ttsCameraError =
      'Camera error. Please close and reopen the scanner.';

  // ── Scanner Semantics labels (read by TalkBack, not spoken by TTS) ────────
  static const String scannerSemanticIdle =
      'Scanner. Camera is off. Tap the camera button to start.';
  static const String scannerSemanticReady =
      'Scanner ready. Double-tap to scan a bill or coin.';
  static const String scannerSemanticScanning = 'Scanning. Hold still.';
  static const String scannerSemanticProcessing = 'Processing. Almost done.';
  static const String scannerSemanticPaused =
      'Preview paused. Double-tap to resume.';
  static const String scannerSemanticResult = 'Result ready.';

  // ── Onboarding TTS — spoken aloud during setup ────────────────────────────
  static const String ttsOnboardingWelcome =
      'Welcome to MoneySense. Your accessible Philippine currency identifier. '
      'Tap Next to continue.';
  static const String ttsOnboardingVision =
      'How do you see? Choose a vision profile. '
      'Low Vision, Partially Blind, or Fully Blind. '
      'Tap an option, then tap Next.';
  static const String ttsOnboardingLanguage =
      'Choose your language. English or Tagalog. '
      'Tap an option, then tap Get Started.';
  static const String ttsOnboardingProfileSelected = 'Vision profile set.';

  // Tagalog onboarding TTS is in tl.dart and routed through AppLocalizations.
}
