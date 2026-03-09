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
  static const String sectionNavigation    = 'Nabigasyon';
  static const String sectionAccessibility = 'Aksesibilidad';
  static const String sectionHelpSupport   = 'Tulong at Suporta';

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
  static const String themeSubtitleFull =
      'Piliin kung paano magmumukhang ang app. Ang light mode ay gumagamit ng puting background; ang dark mode ay gumagamit ng madilim na background; ang system mode ay awtomatikong sinusundan ang kasalukuyang setting ng display ng iyong telepono.';
  static const String languageSubtitle =
      'Piliin ang wika na gagamitin sa buong app.';
  static const String languageSubtitleFull =
      'Pumili sa pagitan ng Ingles at Filipino (Tagalog). Binabago nito ang lahat ng teksto sa screen at mga binibigkas na anunsyo sa buong app.';
  static const String fontSizeSubtitle =
      'Ayusin ang laki ng teksto ayon sa iyong kaginhawahan.';
  static const String fontSizeSubtitleFull =
      'I-drag ang slider para palakihin o paliitin ang teksto. Ang iyong vision profile ay nagtatakda ng minimum na laki. Maaari kang pumunta ng mas mataas, ngunit hindi mas mababa sa floor ng iyong profile.';

  // Scanning — titles
  static const String useFrontCamera = 'Gamitin ang Front Camera';
  static const String useFlashlight = 'Gamitin ang Flash';
  static const String denominationVibration = 'Vibrasyon ng Denominasyon';

  // Scanning — subtitles
  static const String useFrontCameraSubtitle =
      'Lumipat sa kamera sa harap para sa pag-scan.';
  static const String useFrontCameraSubtitleFull =
      'Kapag naka-enable, ginagamit ng MoneySense ang front (selfie) camera sa halip ng rear camera. Kapaki-pakinabang kung mas gusto mong hawakan ang telepono nang nakaharap sa iyo habang nagsa-scan.';
  static const String useFlashlightSubtitle =
      'Panatilihing bukas ang flashlight habang aktibo ang kamera.';
  static const String useFlashlightSubtitleFull =
      'Binubuksan ang rear flashlight tuwing bukas ang scanner, tinutulungan na mailaw ang bill sa madilim na kondisyon. Gumagana lamang sa rear camera.';
  static const String denominationVibrationSubtitle =
      'Maramdaman ang natatanging pattern ng vibrasyon para sa bawat denominasyon.';
  static const String denominationVibrationSubtitleFull =
      'Kapag natukoy ang isang bill, ang iyong telepono ay nagvi-vibrate sa isang pattern na natatangi sa denominasyong iyon, para maramdaman mo ang resulta nang hindi nakikinig. Bawat halaga ng bill ay may natatanging pattern.';

  // Navigation — titles
  static const String shakeToGoBack = 'Iling para Bumalik';
  static const String goBackTimerOnResult = 'Timer ng Pagbabalik sa Resulta';
  static const String gesturalNavigation = 'Gestural na Nabigasyon';
  static const String inertialNavigation = 'Inertial na Nabigasyon';

  // Navigation — subtitles
  static const String shakeToGoBackSubtitle =
      'Iiling ang telepono para bumalik sa nakaraang screen.';
  static const String shakeToGoBackSubtitleFull =
      'Mag-bigay ng mabilis na iling sa iyong telepono para bumalik sa nakaraang screen mula kahit saan sa app. Ang threshold ng pag-iling ay nakatakda upang maiwasan ang mga aksidenteng trigger sa panahon ng normal na paggalaw.';
  static const String goBackTimerSubtitle =
      'Awtomatikong bumalik sa scanner pagkatapos ipakita ang resulta.';
  static const String goBackTimerSubtitleFull =
      'Pagkatapos matukoy ang isang denominasyon, awtomatikong babalik ang MoneySense sa scanner pagkatapos ng bilang ng segundo na itinakda mo dito. Itakda sa 0 para i-disable ang timer at manatili sa result screen.';
  static const String gesturalNavigationSubtitle =
      'Mag-swipe sa scanner para buksan ang Settings, Tutorial, o i-toggle ang flash.';
  static const String gesturalNavigationSubtitleFull =
      'Sa scanner screen: mag-swipe pakanan para buksan ang Settings, mag-swipe pakaliwa para buksan ang Tutorial, mag-swipe pataas para i-toggle ang flashlight, at i-double-tap para i-freeze o i-unfreeze ang live camera preview.';
  static const String inertialNavigationSubtitle =
      'Ikiling ang telepono pakaliwa o pakanan para mag-navigate sa pagitan ng mga screen.';
  static const String inertialNavigationSubtitleFull =
      'Hawakan ang iyong telepono nang tuwid at ikiling ito pakaliwa para buksan ang Tutorial, o pakanan para sa Settings. Sa anumang sub-screen, ikiling sa alinmang direksyon para bumalik. Kailangan mong hawakan ang tilt ng isang segundo bago ito ma-trigger.';

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

  // Inertial navigation dialog — now points to the real tutorial
  static const String inertialDialogBody =
      'Ikiling ang telepono pakaliwa para buksan ang Tutorial o pakanan para buksan ang Settings. '
      'hindi na kailangang mag-tap.\n\nI-tap ang help button para buksan ang interactive na tutorial.';
  static const String gotIt = 'Naintindihan';

  // ── Tutorial card — Inertial Navigation ───────────────────────────────────
  static const String tutorialCardInertialTitle = 'Inertial na Nabigasyon';
  static const String tutorialCardInertialDesc =
      'Ikiling ang telepono pakaliwa o pakanan para mag-navigate sa pagitan ng mga screen. '
      'hindi na kailangan ng mga pindutan o tap.';

  // ── Tutorial: Inertial Navigation ─────────────────────────────────────────
  static const String inertialTutorialBadge = 'Nabigasyon';
  static const String inertialTutorialDescription =
      'Hawakan ang telepono nang patayo at ikiling ito pakaliwa para buksan ang Tutorial o '
      'pakanan para buksan ang Settings. Sa anumang sub-screen, ikiling pabalik para bumalik sa home. '
      'Ang telepono ay dapat hawaking patayo, hindi ito mag-a-activate habang nakahiga.';
  static const String inertialTutorialStep1 =
      'I-enable ang "Inertial na Nabigasyon" sa Settings → Nabigasyon.';
  static const String inertialTutorialStep2 =
      'Hawakan ang telepono nang patayo sa portrait orientation.';
  static const String inertialTutorialStep3 =
      'Ikiling PAKANAN para buksan ang Settings, ikiling PAKALIWA para buksan ang Tutorial.';
  static const String inertialTutorialStep4 =
      'Sa Settings o Tutorial, ikiling sa anumang direksyon para bumalik sa home.';
  static const String inertialTutorialStep5 =
      'Ang telepono ay dapat ikiling nang tuluy-tuloy. Ang mabilis na pagkilos ay hindi mag-a-activate.';
  static const String inertialTiltRight = 'Ikiling pakanan → Settings';
  static const String inertialTiltLeft  = 'Ikiling pakaliwa → Tutorial';
  static const String inertialTiltBack  = 'Ikiling kahit saan → Bumalik';
  static const String inertialTryItHint = 'Ikiling ang telepono pakaliwa o pakanan para subukan';
  static const String inertialTiltDetected = '✓ Natukoy ang pag-ikiling!';
  static const String inertialFlatWarning =
      'Nakahiga ang telepono. Hawakan ito nang patayo para i-activate';
  static const String inertialLegendRight = 'Ikiling pakanan';
  static const String inertialLegendLeft  = 'Ikiling pakaliwa';
  static const String inertialLegendOpensSettings  = 'Nagbubukas ng Settings';
  static const String inertialLegendOpensTutorial  = 'Nagbubukas ng Tutorial';
  static const String inertialLegendGoBack         = 'Bumalik (mula sa mga sub-screen)';

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
      'Iiling ang telepono para bumalik sa nakaraang screen, hindi na kailangan ang mga pindutan.';

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
      'babalik sa nakaraang screen, hindi na kailangan pang pindutin ang anumang pindutan.';
  static const String shakeTutorialStep1 =
      'I-enable ang "Iling para Bumalik" sa Settings → Nabigasyon.';
  static const String shakeTutorialStep2 =
      'Buksan ang anumang screen: Settings, Tutorial, o resulta ng scan.';
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
      'sa scanner screen, perpekto kapag hawak mo ang pera sa iyong kabilang kamay.';
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

  // ── Accessibility settings ────────────────────────────────────────────────

  // Vision profile
  static const String visionProfileTitle    = 'Uri ng Paningin';
  static const String visionProfileSubtitle =
      'Inaangkop ang TTS verbosity, lakas ng haptic, at laki ng font sa iyong pangangailangan.';
  static const String visionProfileSubtitleFull =
      'Ang iyong vision profile ang pundasyon ng accessibility system ng MoneySense. Ang pagpili ng profile ay awtomatikong nagtatakda ng speech verbosity, lakas ng haptic, minimum na laki ng font, at kung ang audio ay itinuturing na pangunahin. Maaari mo pa ring i-fine-tune ang bawat setting nang paisa-isa pagkatapos pumili.';

  // TTS
  static const String ttsTitle    = 'Text-to-Speech';
  static const String ttsSubtitle =
      'Binibigkas ang mga resulta ng scan at mga kaganapan sa app.';
  static const String ttsSubtitleFull =
      'Kapag naka-enable, binabasa ng MoneySense nang malakas ang denominasyon ng bawat bill na na-scan. Sa mas mataas na antas ng verbosity, inuanunsyo rin nito ang mga navigation event, pangalan ng screen, at estado ng system. Gumagamit ng built-in na speech engine ng iyong device.';
  static const String ttsVerbosityTitle    = 'Antas ng Pagsasalita';
  static const String ttsVerbositySubtitle =
      'Gaano karami ang sinasalita ng app: resulta lamang, o buong narrasyon.';
  static const String ttsVerbositySubtitleFull =
      'Resulta: ang na-scan na denominasyon lamang ang binibigkas. Karaniwan: mga resulta kasama ang mga navigation event at mga kumpirmasyon ng setting. Buo: lahat ay binabalita: mga paglipat ng screen, estado ng scanner, idle na mga prompt, at lahat ng interaksyon.';
  static const String ttsVerbosityMinimal  = 'Minimal';
  static const String ttsVerbosityStandard = 'Karaniwan';
  static const String ttsVerbosityFull     = 'Buo';

  // Haptics
  static const String hapticTitle    = 'Haptic Feedback';
  static const String hapticSubtitle =
      'Vibrasyon na feedback para sa mga resulta ng scan at nabigasyon.';
  static const String hapticSubtitleFull =
      'Kapag naka-enable, nagvi-vibrate ang iyong telepono bilang tugon sa mga resulta ng scan, nabigasyon, at iba pang mga kaganapan. Ang mga pattern ng vibrasyon ay natatangi sa bawat uri ng kaganapan upang maaari itong makilala sa pamamagitan ng pakiramdam, lalo na mahalaga kapag hindi available ang audio.';
  static const String hapticIntensityTitle    = 'Lakas ng Haptic';
  static const String hapticIntensitySubtitle =
      'Gaano kalakas ang pag-vibrate ng telepono para sa bawat kaganapan.';
  static const String hapticIntensitySubtitleFull =
      'Banayad: magaang na haptic click lamang, walang motor vibration. Katamtaman: haptic click kasama ang maikling motor pulse. Malakas: haptic click kasama ang mayamang multi-pulse na mga pattern. Bawat uri ng kaganapan (resulta ng scan, error, nabigasyon) ay may natatanging pattern na maaari mong matutunan.';
  static const String hapticIntensitySubtle  = 'Banayad';
  static const String hapticIntensityMedium  = 'Katamtaman';
  static const String hapticIntensityStrong  = 'Malakas';

  // Vision profile descriptions
  static const String visionLowVisionDesc =
      'Visual na UI na may pinapalaking teksto at contrast. Opsyonal ang TTS at haptics.';
  static const String visionPartiallyBlindDesc =
      'May tulong na audio. Awtomatikong binabalita ng TTS ang mga resulta at nabigasyon.';
  static const String visionFullyBlindDesc =
      'Audio ang pangunahin. Lahat ay binabalita ng TTS. Mga mayamang haptic pattern ang nagdadala ng kahulugan.';

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

  // ── TTS speech strings ────────────────────────────────────────────────────

  // App-level
  static const String ttsSpeechEnabled   = 'Naka-on na ang text to speech.';
  static const String ttsSpeechDisabling = 'Papatayin ang text to speech.';

  // Navigation
  static const String ttsNavSettings = 'Mga Setting.';
  static const String ttsNavTutorial = 'Tutorial.';
  static const String ttsNavHome     = 'Scanner.';

  // Language change
  static String ttsLangChanging(String langName) =>
      'Binabago ang audio sa $langName.';
  static String ttsLangChanged(String langName) =>
      'Tapos na. Nagsasalita na ngayon sa $langName.';

  // Short visible label shown next to the spinner during language change
  static const String ttsLangChangingLabel = 'Binabago ang wika…';

  // Scanner — results
  static String ttsScanResult(String denomination) =>
      denomination;
  static String ttsScanResultWithType(String denomination, String type) =>
      '$denomination na $type.';
  static String ttsScanResultLowConfidence(String denomination, String type) =>
      '$denomination na $type. Hindi ganap na sigurado. Pakiverify.';

  // Scanner — camera state
  static const String ttsCameraOpened   = 'Handa na ang kamera.';
  static const String ttsCameraClosed   = 'Sarado ang kamera.';
  static const String ttsPreviewFrozen  = 'Na-freeze ang preview.';
  static const String ttsPreviewResumed = 'Na-resume ang preview.';
  static const String ttsFlashOn        = 'Naka-on ang flashlight.';
  static const String ttsFlashOff       = 'Naka-off ang flashlight.';

  // Scanner — ambient hints
  static const String ttsScannerIdle  =
      'Ilagay ang isang bill o barya nang patag sa harap ng kamera para i-scan.';
  static const String ttsScanStarted  = 'Nagsa-scan.';
  static const String ttsProcessing   = 'Pinoproseso.';

  // Scanner — errors
  static const String ttsCameraPermissionDenied =
      'Hindi pinahintulutan ang kamera. Mangyaring payagan ang camera permission sa Settings.';
  static const String ttsScanFailed   =
      'Hindi ma-identify ang pera. Subukan ulit sa mas maayos na ilaw.';
  static const String ttsCameraError  =
      'Error sa kamera. Pakisara at buksan ulit ang scanner.';

  // ── Scanner Semantics labels ───────────────────────────────────────────────
  static const String scannerSemanticIdle       =
      'Scanner. Naka-off ang kamera. I-tap ang camera button para magsimula.';
  static const String scannerSemanticReady      =
      'Handa na ang scanner. I-double tap para i-scan ang bill o barya.';
  static const String scannerSemanticScanning   = 'Nagsa-scan. Huwag gumalaw.';
  static const String scannerSemanticProcessing = 'Pinoproseso. Sandali na.';
  static const String scannerSemanticPaused     =
      'Na-pause ang preview. I-double tap para i-resume.';
  static const String scannerSemanticResult     = 'Handa na ang resulta.';

  // ── Onboarding TTS ────────────────────────────────────────────────────────
  static const String ttsOnboardingWelcome =
      'Maligayang pagdating sa MoneySense. '
      'Ang iyong accessible na identifier ng piso. '
      'I-tap ang Susunod para magpatuloy.';
  static const String ttsOnboardingVision =
      'Paano ka nakakita? Pumili ng vision profile. '
      'Mababang Paningin, Bahagyang Bulag, o Ganap na Bulag. '
      'I-tap ang isang opsyon, tapos i-tap ang Susunod.';
  static const String ttsOnboardingLanguage =
      'Piliin ang iyong wika. Ingles o Tagalog. '
      'I-tap ang isang opsyon, tapos i-tap ang Magsimula.';
  static const String ttsOnboardingProfileSelected =
      'Na-set na ang vision profile.';
}
