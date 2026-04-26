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
  static const String simpleMode = 'Simple Mode';
  static const String advancedMode = 'Advanced Mode';

  // Section headers
  static const String sectionGeneral = 'General';
  static const String sectionScanning = 'Scanning';
  static const String sectionNavigation = 'Navigation';
  static const String sectionAccessibility = 'Accessibility';
  static const String sectionHelpSupport = 'Help & Support';

  // General: titles
  static const String theme = 'Theme';
  static const String themeSystem = 'System';
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String language = 'Language';
  static const String languageEnglish = 'English';
  static const String languageTagalog = 'Tagalog';
  static const String fontSize = 'Font Size';

  // General: subtitles
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

  // Scanning: titles
  static const String useFrontCamera = 'Use Front Camera';
  static const String useFlashlight = 'Use Flashlight';
  static const String denominationVibration = 'Denomination Vibration';

  // Scanning: subtitles
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

  // Navigation: titles
  static const String shakeToGoBack = 'Shake to Go Back';
  static const String goBackTimerOnResult = 'Go Back Timer on Result';
  static const String gesturalNavigation = 'Gestural Navigation';
  static const String inertialNavigation = 'Inertial Navigation';

  // Navigation: subtitles
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

  // Help & Support: subtitles
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

  // Help & Support: titles
  static const String checkForUpdates = 'Check for Updates';
  static const String playOnboardingSetup = 'Play Onboarding Setup';
  static const String appInformation = 'App Information';
  static const String leaveAFeedback = 'Leave a Feedback';
  static const String termsOfServices = 'Terms of Services';

  // Inertial navigation dialog: now points to the real tutorial
  static const String inertialDialogBody =
      'Tilt your phone left to open Tutorial or right to open Settings. '
      'no tapping required.\n\nTap the help button to open the interactive tutorial.';
  static const String gotIt = 'Got it';

  // ── Tutorial card: Inertial Navigation ───────────────────────────────────
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

  // Tutorial card: Denomination Vibration
  static const String tutorialCardDenomTitle = 'Denomination Vibration';
  static const String tutorialCardDenomDesc =
      'Learn each denomination\'s unique vibration pattern and play them to feel the difference.';

  // Tutorial card: Shake to Go Back
  static const String tutorialCardShakeTitle = 'Shake to Go Back';
  static const String tutorialCardShakeDesc =
      'Shake your phone to navigate back from any screen, no buttons required.';

  // Tutorial card: Gestural Navigation
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
      'For prescriptions (75-500), astigmatism, or vision issues affecting daily tasks despite glasses.';
  static const String visionPartiallyBlindDesc =
      'For individuals with limited functional vision or serious eye conditions not corrected by glasses.';
  static const String visionFullyBlindDesc =
      'For individuals with no functional vision. Audio and haptic feedback as primary tools.';

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
  static const String onboardingVisionOptions = 'Please say: Low Vision, Partially Blind, or Fully Blind.';

  static const String voiceNavigation = 'Voice Navigation';
  static const String voiceNavigationDesc = 'Use voice commands to control the app.';
  static const String onboardingLanguageOptions = 'Please say: English, or Tagalog.';

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
  static const String onboardingFinishOptions =
      'Setup is complete! Would you like a quick tour of the app before we begin scanning? '
      'Say Yes to start the tour, or No to start using the scanner immediately.';
  static const String onboardingExitToScanner = 'Alright, taking you to the scanner screen now. Happy scanning!';
  static const String onboardingExitToTour = 'Excellent choice! Let\'s start the tour.';
  static const String onboardingWelcomeConfirm = 'Great, let\'s begin. Now moving to vision profile selection.';
  static const String onboardingConfirmVision = 'Vision profile set. Moving to language selection.';
  static const String onboardingConfirmLanguage = 'Language set. Moving to camera access.';
  static const String onboardingConfirmPerm = 'Permissions granted. Moving to the final step.';
  static const String onboardingConfirmPermAlready = 'Permissions already granted. Moving to the final step.';

  // Tutorial: App Navigation overview card
  static const String tutorialCardAppNavTitle = 'App Navigation';
  static const String tutorialCardAppNavDesc =
      'A guided walkthrough of the three screens and how to reach them.';

  static const String next = 'Next';
  static const String getStarted = 'Get Started';

  // ── TTS speech strings ────────────────────────────────────────────────────
  // These are spoken aloud, not shown on screen.
  // Written for natural speech: concise, unambiguous, no symbols.

  // App-level
  static const String ttsSpeechEnabled = 'Certainly. Voice feedback is now active.';
  static const String ttsSpeechDisabling = 'Understood. I\'m turning off voice feedback now.';
  static const String ttsNavSettings = 'Opening your settings now.';
  static const String ttsNavTutorial = 'I\'m opening the tutorial guides for you.';
  static const String ttsNavHome = 'Heading back to the scanner screen.';

  // Language change: spoken before and after the engine switches
  static String ttsLangChanging(String langName) =>
      'Certainly. I\'m updating your language to $langName. Please wait a moment.';
  static String ttsLangChanged(String langName) =>
      'Got it! Your language has been updated to $langName.';

  // Short visible label shown next to the spinner during language change
  static const String ttsLangChangingLabel = 'Changing language…';

  // Settings confirmations: use parametric helpers (see AppLocalizations)
  // ttsSettingEnabled / ttsSettingDisabled / ttsSettingChanged
  // are generated via methods in AppLocalizations, not const strings.

  // Scanner: results
  // ttsScanResult(denomination): minimal: just the amount
  static String ttsScanResult(String denomination) => denomination;
  // ttsScanResultWithType(denomination, type): standard: amount + type
  static String ttsScanResultWithType(String denomination, String type) =>
      '$denomination $type.';
  // ttsScanResultLowConfidence(denomination, type): full: low confidence
  static String ttsScanResultLowConfidence(String denomination, String type) =>
      'I think it\'s a $denomination pesos $type, but I\'m not fully certain. Could you please check it again?';

  // Scanner: camera state
  static const String ttsCameraOpened = 'The camera is ready for you.';
  static const String ttsCameraClosed = 'I\'ve closed the camera for you.';
  static const String ttsPreviewFrozen = 'I\'ve paused the preview so you can examine it closely.';
  static const String ttsPreviewResumed = 'Resuming the live camera view.';
  static const String ttsFlashOn = 'I\'ve turned the flashlight on for you.';
  static const String ttsFlashOff = 'Flashlight is now off.';

  // Scanner: ambient hints (full verbosity only)
  static const String ttsScannerIdle =
      'Hold a bill or coin flat in front of the camera, and I will identify it for you.';
  static const String ttsScanStarted = 'I\'m starting the scan now. Please hold steady.';
  static const String ttsProcessing = 'Just a moment, I\'m identifying the currency...';

  // Scanner: errors
  static const String ttsCameraPermissionDenied =
      'I need camera access to help identify currency. Please allow permission in your phone\'s settings.';
  static const String ttsScanFailed =
      'I couldn\'t identify the currency this time. Please try again with different lighting or angle.';
  static const String ttsCameraError =
      'I encountered a camera error. Please try closing and reopening the scanner.';

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

  // ── Onboarding TTS: spoken aloud during setup ────────────────────────────
  static const String ttsOnboardingWelcome =
      'Welcome to MoneySense. Your accessible Philippine currency identifier. '
      'Say Proceed to continue.';
  static const String ttsOnboardingVision =
      'How do you see? Choose a vision profile. '
      'Low Vision, Partially Blind, or Fully Blind. '
      'Say an option to choose it.';
  static const String ttsOnboardingLanguage =
      'Choose your language. English or Tagalog. '
      'Say an option to choose it.';
  static const String ttsOnboardingProfileSelected = 'Vision profile set.';

  // Tagalog onboarding TTS is in tl.dart and routed through AppLocalizations.

  // App Navigation Tutorial
  static const String appNavTutorialTitle = 'App Navigation';
  static const String appNavTutorialClose = 'Close tutorial';
  static const String appNavTutorialBack = 'Back';
  static const String appNavTutorialNext = 'Next';
  static const String appNavTutorialDone = 'Done';

  static const String appNavPage1Title = 'Three screens';
  static const String appNavPage1Body =
      'MoneySense has three screens you can always reach from anywhere in the app.';
  static const String appNavScannerLabel = 'Scanner';
  static const String appNavScannerDesc =
      'Point your camera at Philippine currency to identify it.';
  static const String appNavSettingsLabel = 'Settings';
  static const String appNavSettingsDesc =
      'Adjust vision profile, language, navigation, and audio.';
  static const String appNavTutorialLabel = 'Tutorial';
  static const String appNavTutorialDesc =
      'Interactive guides for every app feature.';

  static const String appNavPage2Title = 'Bottom navigation';
  static const String appNavPage2Body =
      'The bottom bar is always visible. Tap the left icon for Settings, '
      'the centre to start or stop scanning, and the right icon for Tutorial.';
  static const String appNavPage2Note =
      'This is the primary way to navigate. All three styles support it.';

  static const String appNavPage3Title = 'Gestural navigation';
  static const String appNavPage3Body =
      'When Gestural mode is on, you can swipe left or right with one finger '
      'on the scanner screen to open Settings or Tutorial.';
  static const String appNavPage3Note =
      'Enable in Settings under Navigation, or go back and change your navigation style.';

  static const String appNavPage4Title = 'Inertial navigation';
  static const String appNavPage4Body =
      'When Inertial mode is on, tilt your phone left to open Tutorial and right '
      'to open Settings. Hold the tilt for one second to confirm.';
  static const String appNavPage4Note =
      'Useful when you need hands-free navigation while holding currency.';

  static const String appNavPage5Title = 'Shake to go back';
  static const String appNavPage5Body =
      'From any screen, give your phone a quick shake to go back to the scanner. '
      'No button needed.';
  static const String appNavPage5Note =
      'Enable or disable this in Settings under Navigation.';

  static const String appNavNavBottomBar = 'Bottom Bar';
  static const String appNavNavGestural = 'Gestural';
  static const String appNavNavInertial = 'Inertial';

  // Splash / startup screen
  static const String splashGettingReady = 'Getting ready…';
  static const String splashLoadingVoice = 'Loading voice…';
  static const String splashReadyToScan = 'Ready to scan.';

  // Reset Settings
  static const String resetSettingsTitle = 'Reset Settings';
  static const String resetSettingsSubtitle =
      'Restore all settings to default values.';
  static const String resetDialogTitle = 'Reset Settings?';
  static const String resetDialogBody =
      'This will restore all settings to their default values. '
      'Your scan history is not affected.';
  static const String resetDialogRunOnboarding =
      'Run the setup guide again after reset?';
  static const String resetDialogYesOnboarding = 'Yes, run setup';
  static const String resetDialogNoOnboarding = 'No, just reset';
  static const String resetDialogCancel = 'Cancel';

  // Tutorial audio guides — spoken on screen entry (TTS)
  static const String ttsInertialGuide =
      'Welcome to the Inertial Navigation Tutorial. This feature allows you to navigate by simply tilting your phone. '
      'You can tilt right to open Settings, or tilt left to open the Tutorial. '
      'Just hold the tilt for one second to trigger it. '
      'Please make sure your phone is held upright, not flat on a surface. '
      'Feel free to scroll down to try the live tilt demo yourself!';

  static const String ttsGesturalGuide =
      'Welcome to the Gestural Navigation Tutorial. This feature lets you navigate using simple swipe gestures on the scanner screen. '
      'You can swipe right to open Settings, or swipe left to open the Tutorial. '
      'You can also swipe up to toggle the flashlight, or double-tap anywhere to freeze the preview. '
      'Scroll down whenever you are ready to try the gesture playground.';

  static const String ttsShakeGuide =
      'Welcome to the Shake to Go Back Tutorial. This feature lets you return to the scanner from any screen just by shaking your phone. '
      'Simply give your phone a short, firm shake, as if you were saying no. '
      'I will play a short vibration to confirm I felt the shake. '
      'You can scroll down to test the shake detector now.';

  static const String ttsHapticGuide =
      'Welcome to the Denomination Vibration Tutorial. This feature plays a unique vibration pattern whenever I identify currency for you. '
      'Coins use one long pulse followed by shorter pulses, while bills use only short pulses. '
      'The number of pulses will match the value of the currency. '
      'Scroll down to feel each individual pattern.';

  // Tutorial hero semantic descriptions (read by TalkBack instead of visual labels)
  static const String inertialHeroSemantic =
      'Animated phone graphic showing left and right tilt directions. '
      'The phone rotates to show tilt angle. '
      'An indicator bar shows how far you are tilting.';

  static const String gesturalHeroSemantic =
      'Animated phone graphic cycling through swipe gestures. '
      'Shows swipe right for Settings, swipe left for Tutorial, '
      'swipe up for Flash, and double-tap for Scan.';

  static const String shakeHeroSemantic =
      'Animated phone graphic floating gently. '
      'Motion lines on the sides indicate a shaking motion. '
      'When a shake is detected the phone glows and shows a checkmark.';

  static const String hapticHeroSemantic =
      'Animated vibration graphic with ripple rings radiating outward '
      'from a pulsing phone icon, representing haptic feedback.';

  // Tutorial interactive zone semantic hints
  static const String inertialPlaygroundSemantic =
      'Live tilt meter. Tilt your phone left or right. '
      'A moving dot shows your current tilt position. '
      'Hold the tilt for one second to register a navigation event.';

  static const String gesturalPlaygroundSemantic =
      'Gesture practice zone. Swipe right, left, or up, or double-tap '
      'anywhere in this area to test each gesture.';

  static const String shakePlaygroundSemantic =
      'Shake counter. Shake your phone to test the detector. '
      'Each detected shake increments the counter.';

  // Earcon setting
  static const String earconTitle = 'Sound Effects';
  static const String earconSubtitle = 'Short audio cues for scan events.';
  static const String earconSubtitleFull =
      'Plays brief tones when scanning starts, a result is found, or the '
      'scanner fails to identify. Silenced automatically when TalkBack is '
      'active. Independent of voice feedback.';

  static const String resultUncertainLabel = 'UNCERTAIN';
  static const String resultTypeCoin = 'coin';
  static const String resultTypeBill = 'bill';

  static const String confidenceVeryConfident = 'very confident';
  static const String confidenceConfident = 'confident';
  static const String confidenceUncertain = 'uncertain';

  static const String resultConfidencePre = 'I am ';
  static const String resultUncertainSuffix =
      ' about the scanned bill. Please re-scan.';
  static String resultConfidentSuffix(String denomination, String type) =>
      ' that the scanned $type is $denomination pesos.';

  static String resultGoBackHintPre(String seconds) =>
      'Shake or wait $seconds seconds to ';
  static const String resultGoBackLink = 'go back';

  static const String resultDismissLabel =
      'Dismiss result. Go back to scanner.';
  static const String resultConfirmLabel =
      'Accept result. Close result screen.';

  static const String resultSemanticUncertain =
      'Result: Uncertain. Could not identify the currency. Please re-scan.';
  static String resultSemanticConfident(
    String denomination,
    String type,
    String level,
  ) => 'Result: $denomination pesos $type. Confidence: $level.';
  static String resultGoBackHintSemantic(String seconds) =>
      'Shake or wait $seconds seconds to go back.';

  // ── Scanner screen status labels ───────────────────────────────────────────
  static const String scannerStatusIdle = 'Camera is off';
  static const String scannerStatusPreviewing = 'Point camera at currency';
  static const String scannerStatusScanning = 'Scanning...';
  static const String scannerStatusCentering = 'Centering the bill. Hold still.';
  static const String scannerStatusProcessing = 'Verifying authenticity...';

  // ── Centering Guidance ─────────────────────────────────────────────────────
  static const String guidanceMoveRight = 'Move right';
  static const String guidanceMoveLeft = 'Move left';
  static const String guidanceMoveDown = 'Move down';
  static const String guidanceMoveUp = 'Move up';
  static const String guidanceCentered = 'Bill centered';
  static const String guidanceMoveRightDown = 'Move right and down';
  static const String guidanceMoveRightUp = 'Move right and up';
  static const String guidanceMoveLeftDown = 'Move left and down';
  static const String guidanceMoveLeftUp = 'Move left and up';

  static const String scannerStatusResult = 'Result ready';
  static const String scannerTapToOpen = 'Tap to open camera';

  // ── Voice Tutorial ──
  static const String tutorialCardVoiceTitle = 'Voice Navigation';
  static const String tutorialCardVoiceDesc =
      'Control the app using your voice and the "Hey MS" wake-word.';
  static const String voiceTutorialBadge = 'Navigation';
  static const String voiceTutorialDescription =
      'Control MoneySense hands-free or with simple taps. Voice commands work in all modes once enabled.';
  static const String voiceTutorialStep1 =
      'Say "Hey MS" then a command like "Open Settings" or "Start Scan".';
  static const String voiceTutorialStep2 =
      'In Standard mode, tap the center of the camera screen to start listening manually.';
  static const String voiceTutorialStep3 =
      'In Fully Blind mode, tap anywhere on the screen to talk to MoneySense.';
  static const String voiceTutorialStep4 =
      'To hear "What shall I do?", use the wake word ("Hey MS") without a command. Tapping skip this prompt.';
  static const String ttsVoiceGuide =
      'Voice Navigation Tutorial. You can control the app by saying "Hey MS" followed by a command. If you just say "Hey MS", I will ask what you want to do. You can also tap the screen to speak immediately. In Fully Blind mode, tap anywhere on the screen. In Standard mode, tap the middle of the camera view. Note that manually tapping will skip the "What shall I do" prompt for faster navigation.';
  static const String voiceHeroSemantic =
      'Animated microphone graphic with sound waves expanding. When you speak, the waves grow and change color to show activity.';
  static const String voicePlaygroundSemantic =
      'Voice command practice area. Try saying "Hey MS" then a command to see it recognized here.';
  static const String voiceDetectedLabel = '✓ Command Recognized!';
  static const String voiceListeningLabel = 'Listening...';
  static const String voiceWakeWordDetectedLabel = 'Wake-word detected!';
  static const String voiceTryItHint = 'Try saying "Hey MS"';
  static const String voiceHelpCommandList =
      'Available commands: Open settings, start scan, turn on flash, or open tutorial. Use "Hey MS" then the command.';
  static const String voiceStatusStandingBy = 'Standing by for "Hey MS"...';
  static const String voicePromptWhatShallIDo = 'What shall I do?';
  
  // Categorized Commands
  static const String voiceCommandCatNav = 'NAVIGATION';
  static const String voiceCommandCatScan = 'SCANNER';
  static const String voiceCommandCatHelp = 'HELP';
  
  static const String voiceCmdStartScanner = 'Start the Scanner';
  static const String voiceCmdIdentify = 'Identify this Money';
  static const String voiceCmdOpenSettings = 'Open Settings';
  static const String voiceCmdGoHome = 'Go to Home / Scanner';
  static const String voiceCmdOpenTutorial = 'Open Tutorials';
  static const String voiceCmdCommandList = 'Show Command List';
  static const String voiceCmdFlashOn = 'Turn on Flashlight';
  static const String voiceCmdFlashOff = 'Turn off Flashlight';
  static const String voiceCmdFrontCam = 'Switch to Front Camera';
  static const String voiceCmdBackCam = 'Switch to Rear Camera';
  static const String voiceCmdHelp = 'Ask for Help';
  static const String voiceCmdExit = 'Exit Application';
  static const String blindTapToSpeak = 'Tap anywhere to speak';

  // Command Confirmation & Feedback
  static const String voiceConfirmPrefix = 'Did you say: ';
  static const String voiceConfirmSuffix = '? Yes or no?';
  static const String voiceActionSuccess = 'Got it!';
  static const String voiceActionCancelled = 'No problem. What shall I do instead?';
  static const String voiceListeningFeedback = 'I am listening.';
  static const String voiceFlashFrontError = 'I am sorry, but I cannot turn on the flashlight while you are using the front camera.';

  static const String resultVerifyLabel = 'Verify Authenticity';
  static const String resultRetryLabel = 'Retry';
  static const String resultTitle = 'Detection Result';
  static const String resultVerifying = 'Verifying...';
  static const String resultGenuine = 'GENUINE BILL';
  static const String resultCounterfeit = 'COUNTERFEIT BILL';
  static const String resultVerificationFailed = 'Verification failed.';
  static const String resultManualCapturing = 'Identifying bill...';
  static String resultAutoVerifyHint(String seconds) => 'Verifying automatically in $seconds... ';
  static const String resultAutoVerifyCancel = 'Cancel';
  static const String strictVerificationTitle = 'Strict Verification';
  static const String strictVerificationSubtitle = 'Apply tight neural constraints to the verification model. Warning: This may occasionally result in inaccurate predictions.';

  // Share App
  static const String shareAppTitle = 'Share MoneySense';
  static const String shareAppSubtitle = 'Show a QR code to share the app.';
  static const String shareAppInstructions = 'Scan this QR code to download MoneySense directly to your phone.';
  static const String shareAppCopyLink = 'Copy Link';
  static const String shareAppOpenBrowser = 'Open in Browser';
  static const String shareAppLinkCopied = 'Link copied to clipboard!';
}
