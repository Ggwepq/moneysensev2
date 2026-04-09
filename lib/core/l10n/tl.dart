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
  static const String simpleMode = 'Simpleng Menu';
  static const String advancedMode = 'Detalyadong Menu';

  // Section headers
  static const String sectionGeneral = 'Pangkalahatan';
  static const String sectionScanning = 'Pag-scan';
  static const String sectionNavigation = 'Nabigasyon';
  static const String sectionAccessibility = 'Aksesibilidad';
  static const String sectionHelpSupport = 'Tulong at Suporta';

  // General: titles
  static const String theme = 'Tema';
  static const String themeSystem = 'Sistema';
  static const String themeLight = 'Maliwanag';
  static const String themeDark = 'Madilim';
  static const String language = 'Wika';
  static const String languageEnglish = 'Ingles';
  static const String languageTagalog = 'Tagalog';
  static const String fontSize = 'Laki ng Teksto';

  // General: subtitles
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

  // Scanning: titles
  static const String useFrontCamera = 'Gamitin ang Front Camera';
  static const String useFlashlight = 'Gamitin ang Flash';
  static const String denominationVibration = 'Vibrasyon ng Denominasyon';

  // Scanning: subtitles
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

  // Navigation: titles
  static const String shakeToGoBack = 'Iling para Bumalik';
  static const String goBackTimerOnResult = 'Timer ng Pagbabalik sa Resulta';
  static const String gesturalNavigation = 'Gestural na Nabigasyon';
  static const String inertialNavigation = 'Inertial na Nabigasyon';

  // Navigation: subtitles
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

  // Help & Support: subtitles
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

  // Help & Support: titles
  static const String checkForUpdates = 'Suriin ang mga Update';
  static const String playOnboardingSetup = 'I-play ang Onboarding';
  static const String appInformation = 'Impormasyon ng App';
  static const String leaveAFeedback = 'Mag-iwan ng Feedback';
  static const String termsOfServices = 'Mga Tuntunin ng Serbisyo';

  // Inertial navigation dialog: now points to the real tutorial
  static const String inertialDialogBody =
      'Ikiling ang telepono pakaliwa para buksan ang Tutorial o pakanan para buksan ang Settings. '
      'hindi na kailangang mag-tap.\n\nI-tap ang help button para buksan ang interactive na tutorial.';
  static const String gotIt = 'Naintindihan';

  // ── Tutorial card: Inertial Navigation ───────────────────────────────────
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
  static const String inertialTiltLeft = 'Ikiling pakaliwa → Tutorial';
  static const String inertialTiltBack = 'Ikiling kahit saan → Bumalik';
  static const String inertialTryItHint =
      'Ikiling ang telepono pakaliwa o pakanan para subukan';
  static const String inertialTiltDetected = '✓ Natukoy ang pag-ikiling!';
  static const String inertialFlatWarning =
      'Nakahiga ang telepono. Hawakan ito nang patayo para i-activate';
  static const String inertialLegendRight = 'Ikiling pakanan';
  static const String inertialLegendLeft = 'Ikiling pakaliwa';
  static const String inertialLegendOpensSettings = 'Nagbubukas ng Settings';
  static const String inertialLegendOpensTutorial = 'Nagbubukas ng Tutorial';
  static const String inertialLegendGoBack = 'Bumalik (mula sa mga sub-screen)';

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

  // Tutorial card: Denomination Vibration
  static const String tutorialCardDenomTitle = 'Vibrasyon ng Denominasyon';
  static const String tutorialCardDenomDesc =
      'Alamin ang natatanging pattern ng vibrasyon ng bawat denominasyon at subukan ito.';

  // Tutorial card: Shake to Go Back
  static const String tutorialCardShakeTitle = 'Iling para Bumalik';
  static const String tutorialCardShakeDesc =
      'Iiling ang telepono para bumalik sa nakaraang screen, hindi na kailangan ang mga pindutan.';

  // Tutorial card: Gestural Navigation
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
  static const String denomPlayDemoSub =
      'Pinapalaro ang lahat ng pattern nang sunud-sunod';
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
  static const String gestureTryHint =
      'Mag-swipe o mag-double-tap dito para subukan';
  static const String gestureSwipeRight = 'Swipe pakanan';
  static const String gestureSwipeLeft = 'Swipe pakaliwa';
  static const String gestureSwipeUp = 'Swipe pataas';
  static const String gestureDoubleTap = 'Double-tap';
  static const String gestureOpensSettings = 'Nagbubukas ng Settings';
  static const String gestureOpensTutorial = 'Nagbubukas ng Tutorial';
  static const String gestureTogglesFlash = 'Nag-toggle ng flashlight';
  static const String gestureFreezesPreview =
      'Nagpe-freeze / nagpapatuloy ng preview';
  static const String gestureLabelRight = '→ Nagbubukas ng Settings';
  static const String gestureLabelLeft = '← Nagbubukas ng Tutorial';
  static const String gestureLabelUp = '↑ Nag-toggle ng Flashlight';
  static const String gestureLabelTap = '⊙ Preview Frozen / Ipinagpatuloy';

  // ── Accessibility settings ────────────────────────────────────────────────

  // Vision profile
  static const String visionProfileTitle = 'Uri ng Paningin';
  static const String visionProfileSubtitle =
      'Inaangkop ang TTS verbosity, lakas ng haptic, at laki ng font sa iyong pangangailangan.';
  static const String visionProfileSubtitleFull =
      'Ang iyong vision profile ang pundasyon ng accessibility system ng MoneySense. Ang pagpili ng profile ay awtomatikong nagtatakda ng speech verbosity, lakas ng haptic, minimum na laki ng font, at kung ang audio ay itinuturing na pangunahin. Maaari mo pa ring i-fine-tune ang bawat setting nang paisa-isa pagkatapos pumili.';

  // TTS
  static const String ttsTitle = 'Text-to-Speech';
  static const String ttsSubtitle =
      'Binibigkas ang mga resulta ng scan at mga kaganapan sa app.';
  static const String ttsSubtitleFull =
      'Kapag naka-enable, binabasa ng MoneySense nang malakas ang denominasyon ng bawat bill na na-scan. Sa mas mataas na antas ng verbosity, inuanunsyo rin nito ang mga navigation event, pangalan ng screen, at estado ng system. Gumagamit ng built-in na speech engine ng iyong device.';
  static const String ttsVerbosityTitle = 'Antas ng Pagsasalita';
  static const String ttsVerbositySubtitle =
      'Gaano karami ang sinasalita ng app: resulta lamang, o buong narrasyon.';
  static const String ttsVerbositySubtitleFull =
      'Resulta: ang na-scan na denominasyon lamang ang binibigkas. Karaniwan: mga resulta kasama ang mga navigation event at mga kumpirmasyon ng setting. Buo: lahat ay binabalita: mga paglipat ng screen, estado ng scanner, idle na mga prompt, at lahat ng interaksyon.';
  static const String ttsVerbosityMinimal = 'Minimal';
  static const String ttsVerbosityStandard = 'Karaniwan';
  static const String ttsVerbosityFull = 'Buo';

  // Haptics
  static const String hapticTitle = 'Haptic Feedback';
  static const String hapticSubtitle =
      'Vibrasyon na feedback para sa mga resulta ng scan at nabigasyon.';
  static const String hapticSubtitleFull =
      'Kapag naka-enable, nagvi-vibrate ang iyong telepono bilang tugon sa mga resulta ng scan, nabigasyon, at iba pang mga kaganapan. Ang mga pattern ng vibrasyon ay natatangi sa bawat uri ng kaganapan upang maaari itong makilala sa pamamagitan ng pakiramdam, lalo na mahalaga kapag hindi available ang audio.';
  static const String hapticIntensityTitle = 'Lakas ng Haptic';
  static const String hapticIntensitySubtitle =
      'Gaano kalakas ang pag-vibrate ng telepono para sa bawat kaganapan.';
  static const String hapticIntensitySubtitleFull =
      'Banayad: magaang na haptic click lamang, walang motor vibration. Katamtaman: haptic click kasama ang maikling motor pulse. Malakas: haptic click kasama ang mayamang multi-pulse na mga pattern. Bawat uri ng kaganapan (resulta ng scan, error, nabigasyon) ay may natatanging pattern na maaari mong matutunan.';
  static const String hapticIntensitySubtle = 'Banayad';
  static const String hapticIntensityMedium = 'Katamtaman';
  static const String hapticIntensityStrong = 'Malakas';

  // Vision profile descriptions
  static const String visionLowVisionDesc =
      'Visual na UI na may pinapalaking teksto at contrast. Opsyonal ang TTS at haptics.';
  static const String visionPartiallyBlindDesc =
      'May tulong na audio. Awtomatikong binabalita ng TTS ang mga resulta at nabigasyon.';
  static const String visionFullyBlindDesc =
      'Audio ang pangunahin. Lahat ay binabalita ng TTS. Mga mayamang haptic pattern ang nagdadala ng kahulugan.';

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const String onboardingWelcomeTitle =
      'Maligayang Pagdating sa MoneySense';
  static const String onboardingWelcomeSubtitle =
      'Ang iyong accessible na identifier ng piso.';
  static const String onboardingVisionTitle = 'Paano ka nakakita?';
  static const String onboardingVisionSubtitle =
      'Iaangkop namin ang app para sa iyong pangangailangan.';
  static const String visionLowVision = 'Mababang Paningin';
  static const String visionPartiallyBlind = 'Bahagyang Bulag';
  static const String visionFullyBlind = 'Ganap na Bulag';
  static const String onboardingVisionOptions = 'Mangyaring sabihin: Mababang Paningin, Bahagyang Bulag, o Ganap na Bulag.';

  static const String voiceNavigation = 'Nabigasyon sa Boses';
  static const String voiceNavigationDesc = 'Gamitin ang mga voice command para makontrol ang app.';
  static const String onboardingLanguageOptions = 'Mangyaring sabihin: English, o Tagalog.';


  // Onboarding: Permissions
  static const String onboardingPermissionTitle = 'Access sa Camera';
  static const String onboardingPermissionSubtitle =
      'Kailangan ng MoneySense ang camera para matukoy ang pera. Pindutin ang pindutan sa ibaba para pahintulutan.';
  static const String onboardingPermissionGrant = 'Pahintulutan ang camera';
  static const String onboardingPermissionGranted =
      'Pinahintulutan na ang camera';
  static const String onboardingPermissionDenied =
      'Hindi pinahintulutan ang camera. Maaari mo itong payagan sa Settings ng iyong device.';
  static const String onboardingPermissionSkip = 'Preskindiin muna';

  // Onboarding: Finish
  static const String onboardingFinishTitle = 'Handa ka na!';
  static const String onboardingFinishSubtitle =
      'Handang gamitin ang MoneySense. Gusto mo bang mabigyan ng mabilis na gabay sa app?';
  static const String onboardingFinishTour = 'Ipakita sa akin';
  static const String onboardingFinishSkip = 'Magsimulang mag-scan';
  static const String onboardingFinishOptions = 'Tapos na ang setup! Gusto mo ba ng mabilis na tour sa app bago tayo mag-scan? Sabihin ang Oo para simulan ang tour, o Hindi para mag-scan agad.';
  static const String onboardingExitToScanner = 'Sige, pupunta na tayo sa scanner screen. Masayang pag-scan!';
  static const String onboardingExitToTour = 'Magandang pili! Simulan na natin ang tour.';
  static const String onboardingWelcomeConfirm = 'Magaling, magsimula na tayo. Ngayon ay pupunta sa pagpili ng vision profile.';
  static const String onboardingConfirmVision = 'Na-set na ang vision profile. Pupunta na sa pagpili ng wika.';
  static const String onboardingConfirmLanguage = 'Naibigay na ang wika. Susunod na ang pag-access sa camera.';
  static const String onboardingConfirmPerm = 'Naibigay na ang mga pahintulot. Pupunta na sa huling hakbang.';
  static const String onboardingConfirmPermAlready = 'Naibigay na dati ang mga pahintulot. Pupunta na sa huling hakbang.';

  // Tutorial: App Navigation card
  static const String tutorialCardAppNavTitle = 'Nabigasyon sa App';
  static const String tutorialCardAppNavDesc =
      'Gabay sa tatlong screen at kung paano maabot ang mga ito.';

  static const String next = 'Susunod';
  static const String getStarted = 'Magsimula';

  // ── TTS speech strings ────────────────────────────────────────────────────

  // App-level
  static const String ttsSpeechEnabled = 'Siyempre. Aktibo na ang voice feedback.';
  static const String ttsSpeechDisabling = 'Naintindihan ko. Pinapatay ko na ang voice feedback.';
  static const String ttsNavSettings = 'Binubuksan na ang iyong settings.';
  static const String ttsNavTutorial = 'Binubuksan ko na ang gabay sa tutorial para sa iyo.';
  static const String ttsNavHome = 'Babalik na tayo sa scanner screen.';

  // Language change
  static String ttsLangChanging(String langName) =>
      'Siyempre. Binabago ko na ang wika sa $langName. Maghintay lang ng sandali.';
  static String ttsLangChanged(String langName) =>
      'Tapos na. Ang wika ay naka-set na ngayon sa $langName.';

  // Short visible label shown next to the spinner during language change
  static const String ttsLangChangingLabel = 'Binabago ang wika…';

  // Scanner: results
  static String ttsScanResult(String denomination) => denomination;
  static String ttsScanResultWithType(String denomination, String type) =>
      '$denomination na $type.';
  static String ttsScanResultLowConfidence(String denomination, String type) =>
      'Sa tingin ko ito ay $denomination na $type, pero hindi ako sigurado. Maaari mo bang i-check ulit?';

  // Scanner: camera state
  static const String ttsCameraOpened = 'Handa na ang camera para sa iyo.';
  static const String ttsCameraClosed = 'Sinarado ko na ang camera.';
  static const String ttsPreviewFrozen = 'Naka-hinto na ang preview para masuri mo itong mabuti.';
  static const String ttsPreviewResumed = 'Pinagpapatuloy na natin ang live preview.';
  static const String ttsFlashOn = 'Binuksan ko na ang flashlight para sa iyo.';
  static const String ttsFlashOff = 'Naka-off na ang flashlight.';

  // Scanner: ambient hints
  static const String ttsScannerIdle =
      'I-angat ang barya o bill sa tapat ng camera, at sasabihin ko sa iyo kung magkano ito.';
  static const String ttsScanStarted = 'Sinisimulan ko na ang pag-scan. Huwag munang igalaw ang phone.';
  static const String ttsProcessing = 'Sandali lang, inaalam ko na kung anong pera ito...';

  // Scanner: errors
  static const String ttsCameraPermissionDenied =
      'Kailangan ko ng access sa camera para matulungan kang ma-identify ang pera. Mangyaring payagan ang permission sa iyong settings.';
  static const String ttsScanFailed =
      'Hindi ko ma-identify ang pera sa pagkakataong ito. Pakisubukan ulit sa ibang anggulo o mas maliwanag na lugar.';
  static const String ttsCameraError =
      'Nagkaroon ng error sa camera. Pakisara at buksan ulit ang scanner.';

  // ── Scanner Semantics labels ───────────────────────────────────────────────
  static const String scannerSemanticIdle =
      'Scanner. Naka-off ang kamera. I-tap ang camera button para magsimula.';
  static const String scannerSemanticReady =
      'Handa na ang scanner. I-double tap para i-scan ang bill o barya.';
  static const String scannerSemanticScanning = 'Nagsa-scan. Huwag gumalaw.';
  static const String scannerSemanticProcessing = 'Pinoproseso. Sandali na.';
  static const String scannerSemanticPaused =
      'Na-pause ang preview. I-double tap para i-resume.';
  static const String scannerSemanticResult = 'Handa na ang resulta.';

  // ── Onboarding TTS ────────────────────────────────────────────────────────
  static const String ttsOnboardingWelcome =
      'Maligayang pagdating sa MoneySense. '
      'Ang iyong accessible na identifier ng piso. '
      'Sabihin ang Ituloy para magpatuloy.';
  static const String ttsOnboardingVision =
      'Paano ka nakakita? Pumili ng vision profile. '
      'Mababang Paningin, Bahagyang Bulag, o Ganap na Bulag. '
      'Sabihin ang isang opsyon para piliin ito.';
  static const String ttsOnboardingLanguage =
      'Piliin ang iyong wika. Ingles o Tagalog. '
      'Sabihin ang isang opsyon para piliin ito.';
  static const String ttsOnboardingProfileSelected =
      'Na-set na ang vision profile.';

  // App Navigation Tutorial
  static const String appNavTutorialTitle = 'Nabigasyon sa App';
  static const String appNavTutorialClose = 'Isara ang tutorial';
  static const String appNavTutorialBack = 'Bumalik';
  static const String appNavTutorialNext = 'Susunod';
  static const String appNavTutorialDone = 'Tapos';

  static const String appNavPage1Title = 'Tatlong screen';
  static const String appNavPage1Body =
      'Ang MoneySense ay may tatlong screen na palaging maabot mula kahit saan sa app.';
  static const String appNavScannerLabel = 'Scanner';
  static const String appNavScannerDesc =
      'Itutok ang camera sa piso para makilala ito.';
  static const String appNavSettingsLabel = 'Mga Setting';
  static const String appNavSettingsDesc =
      'Baguhin ang vision profile, wika, nabigasyon, at audio.';
  static const String appNavTutorialLabel = 'Tutorial';
  static const String appNavTutorialDesc =
      'Mga gabay para sa bawat feature ng app.';

  static const String appNavPage2Title = 'Bottom navigation';
  static const String appNavPage2Body =
      'Laging nakita ang bottom bar. I-tap ang kaliwang icon para sa Mga Setting, '
      'ang gitna para magsimula o tumigil sa pag-scan, at ang kanang icon para sa Tutorial.';
  static const String appNavPage2Note =
      'Ito ang pangunahing paraan ng nabigasyon. Sinusuportahan ng lahat ng tatlong estilo.';

  static const String appNavPage3Title = 'Gestural na nabigasyon';
  static const String appNavPage3Body =
      'Kapag naka-on ang Gestural mode, maaari kang mag-swipe pakaliwa o pakanan '
      'gamit ang isang daliri sa scanner screen para buksan ang Mga Setting o Tutorial.';
  static const String appNavPage3Note =
      'I-enable sa Mga Setting sa ilalim ng Nabigasyon, o bumalik at baguhin ang iyong estilo.';

  static const String appNavPage4Title = 'Inertial na nabigasyon';
  static const String appNavPage4Body =
      'Kapag naka-on ang Inertial mode, ihilig ang telepono pakaliwa para buksan ang Tutorial '
      'at pakanan para buksan ang Mga Setting. Hawakan ang tilt ng isang segundo para kumpirmahin.';
  static const String appNavPage4Note =
      'Kapaki-pakinabang kapag kailangan mo ng hands-free na nabigasyon habang hawak ang pera.';

  static const String appNavPage5Title = 'I-shake para bumalik';
  static const String appNavPage5Body =
      'Mula sa anumang screen, i-shake ang telepono para bumalik sa scanner. '
      'Hindi na kailangan ng button.';
  static const String appNavPage5Note =
      'I-enable o i-disable ito sa Mga Setting sa ilalim ng Nabigasyon.';

  static const String appNavNavBottomBar = 'Bottom Bar';
  static const String appNavNavGestural = 'Gestural';
  static const String appNavNavInertial = 'Inertial';

  // Splash / startup screen
  static const String splashGettingReady = 'Naghahanda…';
  static const String splashLoadingVoice = 'Naglo-load ng boses…';
  static const String splashReadyToScan = 'Handa nang mag-scan.';

  // Reset Settings
  static const String resetSettingsTitle = 'I-reset ang Mga Setting';
  static const String resetSettingsSubtitle =
      'Ibalik ang lahat ng setting sa default.';
  static const String resetDialogTitle = 'I-reset ang Mga Setting?';
  static const String resetDialogBody =
      'Ibabalik ang lahat ng setting sa kanilang default na halaga. '
      'Hindi maaapektuhan ang kasaysayan ng pag-scan.';
  static const String resetDialogRunOnboarding =
      'Patakbuhin muli ang gabay sa pag-setup pagkatapos ng reset?';
  static const String resetDialogYesOnboarding = 'Oo, patakbuhin';
  static const String resetDialogNoOnboarding = 'Hindi, i-reset lang';
  static const String resetDialogCancel = 'Kanselahin';

  // Tutorial audio guides — spoken on screen entry (TTS)
  static const String ttsInertialGuide =
      'Maligayang pagdating sa Tutorial ng Inertial Navigation. Ang feature na ito ay nagbibigay-daan sa iyo na mag-navigate sa pamamagitan lamang ng pag-tilt ng iyong telepono. '
      'Maaari mong i-tilt pakanan para buksan ang Mga Setting, o i-tilt pakaliwa para buksan ang Tutorial. '
      'Hawakan lang ang tilt nang isang segundo para ma-trigger ito. '
      'Pakitiyak na ang iyong telepono ay nakatayo at hindi nakapatag. '
      'Mag-scroll pababa para subukan ang aming live tilt demo!';

  static const String ttsGesturalGuide =
      'Maligayang pagdating sa Tutorial ng Gestural Navigation. Ang feature na ito ay nagbibigay-daan sa iyo na mag-navigate gamit ang mga simpleng swipe gesture sa scanner screen. '
      'Maaari kang mag-swipe pakanan para sa Mga Setting, o mag-swipe pakaliwa para sa Tutorial. '
      'Puwede mo ring i-swipe pataas para buksan ang flashlight, o mag-double-tap kahit saan para ihinto ang preview. '
      'Mag-scroll pababa kapag handa ka na para subukan ang ating gesture playground.';

  static const String ttsShakeGuide =
      'Maligayang pagdating sa Tutorial ng Shake to Go Back. Ang feature na ito ay nagbibigay-daan sa iyo na bumalik sa scanner mula sa anumang screen sa pamamagitan lamang ng pag-shake ng iyong telepono. '
      'Sapat na ang isang maikli at mabilis na shake, na parang sinasabing hindi. '
      'Magpe-play ako ng maikling vibration para kumpirmahing naramdaman ko ang shake. '
      'Maaari kang mag-scroll pababa para subukan ang shake detector ngayon.';

  static const String ttsHapticGuide =
      'Maligayang pagdating sa Tutorial ng Denomination Vibration. Ang feature na ito ay nagpe-play ng natatanging pattern ng vibration tuwing may makikilala akong pera para sa iyo. '
      'Ang mga barya ay gumagamit ng isang mahabang pulse na sinusundan ng mas maikling mga pulse, habang ang mga papel na pera naman ay gumagamit lamang ng mga maikling pulse. '
      'Ang bilang ng mga pulse ay tutugma sa halaga ng pera. '
      'Mag-scroll pababa para maramdaman ang bawat pattern.';

  // Tutorial hero semantic descriptions
  static const String inertialHeroSemantic =
      'Animated na graphic ng telepono na nagpapakita ng kaliwa at kanang direksyon ng tilt. '
      'Ang telepono ay umiikot para ipakita ang anggulo ng tilt. '
      'Isang indicator bar ang nagpapakita kung gaano kalayo ang iyong tilt.';

  static const String gesturalHeroSemantic =
      'Animated na graphic ng telepono na nagsu-cycle sa mga swipe gesture. '
      'Nagpapakita ng swipe pakanan para sa Mga Setting, swipe pakaliwa para sa Tutorial, '
      'swipe pataas para sa Flash, at double-tap para sa Scan.';

  static const String shakeHeroSemantic =
      'Animated na graphic ng telepono na dahan-dahang lumulutang. '
      'Ang mga motion line sa mga gilid ay nagpapahiwatig ng galaw ng pag-shake. '
      'Kapag natukoy ang shake, ang telepono ay nagniningning at nagpapakita ng checkmark.';

  static const String hapticHeroSemantic =
      'Animated na graphic ng vibration na may mga ripple ring na lumalayo '
      'mula sa isang kumikislap na icon ng telepono, na kumakatawan sa haptic feedback.';

  // Tutorial interactive zone semantic hints
  static const String inertialPlaygroundSemantic =
      'Live na tilt meter. I-tilt ang iyong telepono pakaliwa o pakanan. '
      'Ang gumagalaw na tuldok ay nagpapakita ng iyong kasalukuyang posisyon ng tilt. '
      'Hawakan ang tilt nang isang segundo para mairehistro ang isang navigation event.';

  static const String gesturalPlaygroundSemantic =
      'Lugar ng pagsasanay sa gesture. Mag-swipe pakanan, pakaliwa, o pataas, o mag-double-tap '
      'kahit saan sa lugar na ito para subukan ang bawat gesture.';

  static const String shakePlaygroundSemantic =
      'Shake counter. I-shake ang iyong telepono para subukan ang detector. '
      'Bawat natukoy na shake ay nagdaragdag sa counter.';

  // Earcon setting
  static const String earconTitle = 'Mga Sound Effect';
  static const String earconSubtitle =
      'Maikling audio cues para sa mga scan event.';
  static const String earconSubtitleFull =
      'Nagpapatugtog ng maikling tono kapag nagsisimula ang scan, '
      'may nakitang resulta, o hindi ma-identify ng scanner. '
      'Awtomatikong nata-tahimik kapag aktibo ang TalkBack. '
      'Hiwalay sa voice feedback.';

  // ── Result screen ──────────────────────────────────────────────────────────
  static const String resultUncertainLabel = 'HINDI SIGURADO';
  static const String resultTypeCoin = 'barya';
  static const String resultTypeBill = 'bill';

  static const String confidenceVeryConfident = 'lubos na sigurado';
  static const String confidenceConfident = 'sigurado';
  static const String confidenceUncertain = 'hindi sigurado';

  static const String resultConfidencePre = 'Ako ay ';
  static const String resultUncertainSuffix =
      ' tungkol sa na-scan na pera. Pakisubukan ulit.';
  static String resultConfidentSuffix(String denomination, String type) =>
      ' na ang na-scan na $type ay $denomination piso.';

  static String resultGoBackHintPre(String seconds) =>
      'I-shake o maghintay ng $seconds segundo para ';
  static const String resultGoBackLink = 'bumalik';

  static const String resultDismissLabel =
      'I-dismiss ang resulta. Bumalik sa scanner.';
  static const String resultConfirmLabel =
      'Tanggapin ang resulta. Isara ang result screen.';

  static const String resultSemanticUncertain =
      'Resulta: Hindi sigurado. Hindi ma-identify ang pera. Pakisubukan ulit.';
  static String resultSemanticConfident(
    String denomination,
    String type,
    String level,
  ) => 'Resulta: $denomination piso na $type. Antas ng kumpiyansa: $level.';
  static String resultGoBackHintSemantic(String seconds) =>
      'I-shake o maghintay ng $seconds segundo para bumalik.';

  // ── Scanner screen status labels ───────────────────────────────────────────
  static const String scannerStatusIdle = 'Naka-off ang kamera';
  static const String scannerStatusPreviewing = 'Ituro ang kamera sa pera';
  static const String scannerStatusScanning = 'Nagsa-scan…';
  static const String scannerStatusProcessing = 'Kinikilala…';
  static const String scannerStatusResult = 'Handa na ang resulta';
  static const String scannerTapToOpen = 'I-tap para buksan ang kamera';

  // ── Voice Tutorial ──
  static const String tutorialCardVoiceTitle = 'Voice Navigation';
  static const String tutorialCardVoiceDesc =
      'Kontrolin ang app gamit ang iyong boses at ang "Hey MS" na wake-word.';
  static const String voiceTutorialBadge = 'Navigation';
  static const String voiceTutorialDescription =
      'Kontrolin ang MoneySense nang hands-free o gamit ang simpleng tap. Gumagana ang boses sa lahat ng mode.';
  static const String voiceTutorialStep1 =
      'Sabihin ang "Hey MS" kasunod ng utos tulad ng "Buksan ang Settings" o "Simulan ang Scan".';
  static const String voiceTutorialStep2 =
      'Sa Standard mode, i-tap ang gitna ng camera screen para mag-manual na pakikinig.';
  static const String voiceTutorialStep3 =
      'Sa Fully Blind mode, i-tap kahit saan sa screen para kausapin ang MoneySense.';
  static const String voiceTutorialStep4 =
      'Para marinig ang "Ano ang aking gagawin?", gamitin ang "Hey MS" nang walang utos. Nilalampasan ng pag-tap ang tanong na ito.';
  static const String ttsVoiceGuide =
      'Tutorial sa Voice Navigation. Maaari mong kontrolin ang app sa pamamagitan ng pagsasabi ng "Hey MS" na sinusundan ng isang utos. Kung sasabihin mo lang ang "Hey MS", tatanungin ko kung ano ang gusto mong gawin. Maaari mo ring i-tap ang screen para magsalita agad. Sa Fully Blind mode, i-tap kahit saan sa screen. Sa Standard mode, i-tap ang gitna ng camera view. Tandaan na ang pag-tap ay lalampas sa tanong na "Ano ang aking gagawin" para sa mas mabilis na paggamit.';
  static const String voiceHeroSemantic =
      'Animated na mikropono na may mga sound wave na lumalaki. Kapag nagsalita ka, ang mga wave ay lumalaki at nagbabago ng kulay para ipakita ang aktibidad.';
  static const String voicePlaygroundSemantic =
      'Lugar para subukan ang voice command. Subukang sabihin ang "Hey MS" pagkatapos ay isang utos para makitang kinikilala ito dito.';
  static const String voiceDetectedLabel = '✓ Kinikilala ang Utos!';
  static const String voiceListeningLabel = 'Nakikinig...';
  static const String voiceWakeWordDetectedLabel = 'Wake-word ay naki-detect!';
  static const String voiceTryItHint = 'Subukang sabihin ang "Hey MS"';
  static const String voiceHelpCommandList =
      'Mga available na utos: Buksan ang settings, simulan ang scan, buksan ang flash, o buksan ang tutorial. Gamitin ang "Hey MS" bago ang utos.';
  static const String voiceStatusStandingBy = 'Naka-standby... sabihin ang "Hey MS"';
  static const String voicePromptWhatShallIDo = 'Ano ang aking gagawin?';
  static const String voiceCmdStartScanner = 'Simulan ang Scanner';
  static const String voiceCmdIdentify = 'Kilalanin ang Pera';

  // Categorized Commands
  static const String voiceCommandCatNav = 'NABIGASYON';
  static const String voiceCommandCatScan = 'SCANNER';
  static const String voiceCommandCatHelp = 'TULONG';
  
  static const String voiceCmdOpenSettings = 'Buksan ang Settings';
  static const String voiceCmdGoHome = 'Pumunta sa Home / Scanner';
  static const String voiceCmdOpenTutorial = 'Buksan ang mga Tutorial';
  static const String voiceCmdCommandList = 'Ipakita ang Listahan ng Utos';
  static const String voiceCmdFlashOn = 'Buksan ang Flashlight';
  static const String voiceCmdFlashOff = 'Patayin ang Flashlight';
  static const String voiceCmdFrontCam = 'Lumipat sa Front Camera';
  static const String voiceCmdBackCam = 'Lumipat sa Rear Camera';
  static const String voiceCmdHelp = 'Humingi ng Tulong';
  static const String voiceCmdExit = 'Isara ang Application';
  static const String blindTapToSpeak = 'I-tap kahit saan para magsalita';

  // Command Confirmation & Feedback
  static const String voiceConfirmPrefix = 'Sabi mo ba ay: ';
  static const String voiceConfirmSuffix = '? Oo o hindi?';
  static const String voiceActionSuccess = 'Sige!';
  static const String voiceActionCancelled = 'Walang problema. Ano ang gagawin natin?';
  static const String voiceListeningFeedback = 'Nakikinig ako.';
  static const String voiceFlashFrontError = 'Paumanhin, pero hindi ko kayang buksan ang flashlight habang ginagamit mo ang front camera.';

  static const String resultVerifyLabel = 'I-verify ang Katunayan';
  static const String resultVerifying = 'Vini-verify...';
  static const String resultGenuine = 'TUNAY NA PERA';
  static const String resultCounterfeit = 'FAKE NA PERA';
  static const String resultVerificationFailed = 'Bigo ang pag-verify.';
  static const String resultManualCapturing = 'Kinikilala ang pera...';
  static String resultAutoVerifyHint(String seconds) => 'Awtomatikong magpapatunay sa loob ng $seconds... ';
  static const String resultAutoVerifyCancel = 'Kanselahin';
}
