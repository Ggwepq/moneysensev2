/// Tagalog (tl) string resources for MoneySense.
abstract final class TlStrings {
  // ── General ───────────────────────────────────────────────────────────────
  static const String appName = 'MoneySense';

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  static const String navSettings = 'Mga Setting';
  static const String navScan = 'I-scan';
  static const String navTutorial = 'Tutorial';

  // ── Settings screen ───────────────────────────────────────────────────────
  static const String settings = 'Mga Setting';

  // Section headers
  static const String sectionGeneral = 'Pangkalahatan';
  static const String sectionScanning = 'Pag-scan';
  static const String sectionNavigation = 'Nabigasyon';
  static const String sectionHelpSupport = 'Tulong at Suporta';

  // General — titles
  static const String theme = 'Tema';
  static const String themeSystem = 'Sistema';
  static const String themeLight = 'Maliwanag';
  static const String themeDark = 'Madilim';
  static const String language = 'Wika';
  static const String languageEnglish = 'Ingles';
  static const String languageTagalog = 'Tagalog';
  static const String fontSize = 'Laki ng Teksto';

  // General — subtitles
  static const String themeSubtitle =
      'Pumili ng maliwanag, madilim, o sundan ang setting ng iyong device.';
  static const String languageSubtitle =
      'Piliin ang wika na gagamitin sa buong app.';
  static const String fontSizeSubtitle =
      'Ayusin ang laki ng teksto ayon sa iyong kaginhawahan.';

  // Scanning — titles
  static const String useFrontCamera = 'Gamitin ang Front Camera';
  static const String useFlashlight = 'Gamitin ang Flash';
  static const String denominationVibration = 'Vibrasyon ng Denominasyon';

  // Scanning — subtitles
  static const String useFrontCameraSubtitle =
      'Lumipat sa kamera sa harap para sa pag-scan.';
  static const String useFlashlightSubtitle =
      'Panatilihing bukas ang flashlight habang aktibo ang kamera.';
  static const String denominationVibrationSubtitle =
      'Maramdaman ang natatanging pattern ng vibrasyon para sa bawat denominasyon.';

  // Navigation — titles
  static const String shakeToGoBack = 'Iling para Bumalik';
  static const String goBackTimerOnResult = 'Timer ng Pagbabalik sa Resulta';
  static const String gesturalNavigation = 'Gestural na Nabigasyon';
  static const String inertialNavigation = 'Inertial na Nabigasyon';

  // Navigation — subtitles
  static const String shakeToGoBackSubtitle =
      'Iiling ang telepono para bumalik sa nakaraang screen.';
  static const String goBackTimerSubtitle =
      'Awtomatikong bumalik sa scanner pagkatapos ipakita ang resulta.';
  static const String gesturalNavigationSubtitle =
      'Mag-swipe sa scanner para buksan ang Settings, Tutorial, o i-toggle ang flash.';
  static const String inertialNavigationSubtitle =
      'Ikiling ang telepono pakaliwa o pakanan para mag-navigate sa pagitan ng mga screen.';

  // Help & Support — subtitles
  static const String checkForUpdatesSubtitle =
      'Tingnan kung may mas bagong bersyon ng MoneySense.';
  static const String playOnboardingSubtitle =
      'Ulitin ang setup para baguhin ang iyong profile o wika.';
  static const String appInformationSubtitle =
      'Tingnan ang numero ng bersyon, mga lisensya, at detalye ng build.';
  static const String leaveAFeedbackSubtitle =
      'Sabihin sa amin kung paano namin mapabuti ang MoneySense para sa iyo.';
  static const String termsOfServicesSubtitle =
      'Basahin ang mga tuntunin at kondisyon ng paggamit ng application na ito.';

  // Help & Support — titles
  static const String checkForUpdates = 'Suriin ang mga Update';
  static const String playOnboardingSetup = 'I-play ang Onboarding';
  static const String appInformation = 'Impormasyon ng App';
  static const String leaveAFeedback = 'Mag-iwan ng Feedback';
  static const String termsOfServices = 'Mga Tuntunin ng Serbisyo';

  // Inertial navigation dialog
  static const String inertialDialogBody =
      'Ikiling ang telepono pakaliwa para buksan ang Settings o pakanan para buksan ang Tutorial — '
      'hindi na kailangang mag-tap.\n\nIsang interactive na tutorial para sa feature na ito ay malapit nang dumating.';
  static const String gotIt = 'Naintindihan';

  // ── Scanner screen ────────────────────────────────────────────────────────
  static const String scanning = 'Nag-scan...';
  static const String processing = 'Pinoproseso...';
  static const String tapToScan = 'Mag-double-tap para mag-scan';
  static const String paused = 'Naka-pause';
  static const String doubleTapToResume = 'Mag-double-tap para ituloy';

  // ── Tutorial screen ───────────────────────────────────────────────────────
  static const String tutorialScreenTitle = 'Alamin ang mga feature';
  static const String tutorialScreenSubtitle =
      'I-tap ang anumang tutorial sa ibaba para matutunan kung paano gumagana '
      'ang bawat feature sa pamamagitan ng live na halimbawa.';
  static const String tutorialSectionScanning = 'PAG-SCAN';
  static const String tutorialSectionNavigation = 'NABIGASYON';

  // Tutorial card — Denomination Vibration
  static const String tutorialCardDenomTitle = 'Vibrasyon ng Denominasyon';
  static const String tutorialCardDenomDesc =
      'Alamin ang natatanging pattern ng vibrasyon ng bawat denominasyon at subukan ito.';

  // Tutorial card — Shake to Go Back
  static const String tutorialCardShakeTitle = 'Iling para Bumalik';
  static const String tutorialCardShakeDesc =
      'Iiling ang telepono para bumalik sa nakaraang screen — hindi na kailangan ang mga pindutan.';

  // Tutorial card — Gestural Navigation
  static const String tutorialCardGestureTitle = 'Gestural na Nabigasyon';
  static const String tutorialCardGestureDesc =
      'Mag-swipe sa scanner para lumipat sa pagitan ng mga screen at i-toggle ang flashlight.';

  // ── Tutorial: Denomination Vibration ─────────────────────────────────────
  static const String denomTutorialBadge = 'Pag-scan';
  static const String denomTutorialDescription =
      'Ang bawat denominasyong piso ay may natatanging pattern ng vibrasyon '
      'para makilala mo ang iyong pera sa pamamagitan ng hawak lamang.';
  static const String denomTutorialStep1 =
      'I-enable ang Vibrasyon ng Denominasyon sa Settings → Pag-scan.';
  static const String denomTutorialStep2 =
      'I-scan ang isang bill o barya gamit ang kamera.';
  static const String denomTutorialStep3 =
      'Maramdaman ang pattern ng vibrasyon na naaayon sa denominasyon.';
  static const String denomTutorialStep4 =
      'Gamitin ang listahang ito para matutunan ang bawat pattern.';
  static const String denomPlayDemoLabel = 'I-play ang Demo ng Vibrasyon';
  static const String denomPlayDemoSub = 'Pinapalaro ang lahat ng pattern nang sunud-sunod';
  static const String denomPatternsLabel = 'MGA PATTERN';

  // ── Tutorial: Shake to Go Back ────────────────────────────────────────────
  static const String shakeTutorialBadge = 'Nabigasyon';
  static const String shakeTutorialDescription =
      'Iiling ang telepono nang may layunin at ang MoneySense ay '
      'babalik sa nakaraang screen — hindi na kailangan pang pindutin ang anumang pindutan.';
  static const String shakeTutorialStep1 =
      'I-enable ang "Iling para Bumalik" sa Settings → Nabigasyon.';
  static const String shakeTutorialStep2 =
      'Buksan ang anumang screen — Settings, Tutorial, o resulta ng scan.';
  static const String shakeTutorialStep3 =
      'Iiling ang telepono nang isang beses nang may tiwala.';
  static const String shakeTutorialStep4 =
      'Maramdaman ang vibrasyon habang bumabalik ang screen.';
  static const String shakeTryItTitle = 'Subukan mo ngayon';
  static const String shakeTryItHint = 'Iiling ang telepono nang mabilis';
  static const String shakeDetected = '✓ Natukoy ang pag-iling!';
  static const String shakeCountSingle = '1 pag-iling na natukoy';
  static String shakeCountMultiple(int n) => '$n pag-iling na natukoy';

  // ── Tutorial: Gestural Navigation ─────────────────────────────────────────
  static const String gestureTutorialBadge = 'Nabigasyon';
  static const String gestureTutorialDescription =
      'Mag-navigate sa MoneySense nang walang kamay gamit ang mga swipe at tap '
      'sa scanner screen — perpekto kapag hawak mo ang pera sa iyong kabilang kamay.';
  static const String gestureTutorialStep1 =
      'I-enable ang "Gestural na Nabigasyon" sa Settings → Nabigasyon.';
  static const String gestureTutorialStep2 =
      'Mag-swipe PAKANAN sa scanner screen para buksan ang Settings.';
  static const String gestureTutorialStep3 =
      'Mag-swipe PAKALIWA sa scanner screen para buksan ang Tutorial.';
  static const String gestureTutorialStep4 =
      'Mag-swipe PATAAS para i-toggle ang flashlight.';
  static const String gestureTutorialStep5 =
      'Mag-double-tap sa scanner para i-freeze o ituloy ang live preview.';
  static const String gestureTryHint = 'Mag-swipe o mag-double-tap dito para subukan';
  static const String gestureSwipeRight = 'Swipe pakanan';
  static const String gestureSwipeLeft = 'Swipe pakaliwa';
  static const String gestureSwipeUp = 'Swipe pataas';
  static const String gestureDoubleTap = 'Double-tap';
  static const String gestureOpensSettings = 'Nagbubukas ng Settings';
  static const String gestureOpensTutorial = 'Nagbubukas ng Tutorial';
  static const String gestureTogglesFlash = 'Nag-toggle ng flashlight';
  static const String gestureFreezesPreview = 'Nagpe-freeze / nagpapatuloy ng preview';
  static const String gestureLabelRight = '→ Nagbubukas ng Settings';
  static const String gestureLabelLeft = '← Nagbubukas ng Tutorial';
  static const String gestureLabelUp = '↑ Nag-toggle ng Flashlight';
  static const String gestureLabelTap = '⊙ Preview Frozen / Ipinagpatuloy';

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const String onboardingWelcomeTitle = 'Maligayang Pagdating sa MoneySense';
  static const String onboardingWelcomeSubtitle =
      'Ang iyong accessible na identifier ng piso.';
  static const String onboardingVisionTitle = 'Paano ka nakakita?';
  static const String onboardingVisionSubtitle =
      'Iaangkop namin ang app para sa iyong pangangailangan.';
  static const String visionLowVision = 'Mababang Paningin';
  static const String visionPartiallyBlind = 'Bahagyang Bulag';
  static const String visionFullyBlind = 'Ganap na Bulag';
  static const String next = 'Susunod';
  static const String getStarted = 'Magsimula';
}
