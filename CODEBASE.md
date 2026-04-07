# MoneySense Codebase Reference

A file-by-file guide to the project: what each file is, why it exists, and what it is responsible for.

---

## Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── home_shell.dart
│   └── routes/
│       └── routes.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   └── app_typography.dart
│   ├── l10n/
│   │   ├── app_localizations.dart
│   │   ├── en.dart
│   │   └── tl.dart
│   ├── services/
│   │   ├── earcon_service.dart
│   │   ├── haptic_service.dart
│   │   ├── inertial_detector_widget.dart
│   │   ├── inertial_service.dart
│   │   ├── scanner_speech_scripts.dart
│   │   ├── shake_detector_widget.dart
│   │   ├── shake_service.dart
│   │   ├── speech_scripts.dart
│   │   ├── tts_message.dart
│   │   ├── tts_service.dart
│   │   └── voice/
│   │       ├── voice_command_executor.dart
│   │       ├── voice_command_overlay.dart
│   │       ├── voice_command_service.dart
│   │       ├── voice_intent.dart
│   │       └── voice_intent_parser.dart
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── onboarding/
│   │   └── presentation/screens/
│   │       └── onboarding_screen.dart
│   ├── scanner/
│   │   ├── data/datasources/
│   │   │   └── camera_service.dart
│   │   ├── domain/entities/
│   │   │   └── scanner_state.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── scanner_provider.dart
│   │       ├── screens/
│   │       │   ├── result_screen.dart
│   │       │   └── scanner_screen.dart
│   │       └── widgets/
│   │           └── camera_viewfinder.dart
│   ├── settings/
│   │   ├── data/datasources/
│   │   │   └── settings_storage.dart
│   │   ├── domain/entities/
│   │   │   ├── app_settings.dart
│   │   │   └── vision_config.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── settings_provider.dart
│   │       └── screens/
│   │           ├── settings_screen.dart
│   │           ├── simple_settings_screen.dart
│   │           └── vision_profile_picker_screen.dart
│   └── tutorial/
│       ├── domain/
│       │   └── tutorial_route.dart
│       └── presentation/
│           ├── screens/
│           │   ├── app_navigation_tutorial.dart
│           │   ├── denomination_vibration_tutorial.dart
│           │   ├── gestural_navigation_tutorial.dart
│           │   ├── inertial_navigation_tutorial.dart
│           │   ├── shake_tutorial.dart
│           │   ├── tutorial_navigator.dart
│           │   └── tutorial_screen.dart
│           └── widgets/
│               └── ms_tutorial_scaffold.dart
└── shared/
    └── widgets/
        ├── full_screen_loader.dart
        ├── ms_action_tile.dart
        ├── ms_bottom_nav.dart
        ├── ms_section_header.dart
        ├── ms_segmented_selector.dart
        ├── ms_settings_card.dart
        ├── ms_slider_tile.dart
        ├── ms_timer_tile.dart
        └── ms_toggle_tile.dart
```

---

## Root

### `main.dart`

The app entry point. Starts `SharedPreferences`, discovers available cameras, and initializes haptic capabilities in parallel before the first frame. Then locks orientation to portrait, sets up edge-to-edge display, and starts the app inside a `ProviderScope` with the camera list and user preferences already injected.

---

## `app/`

The composition root. Wires together the root widget, the navigation shell, and global providers. No business logic lives here.

### `app.dart`

The root `ConsumerWidget` that owns the `MaterialApp`. Watches settings to switch themes and applies the user's font scale via a `MediaQuery` override so every widget in the app respects the chosen scale automatically. Also registers the route observer and initializes the TTS engine.

### `home_shell.dart`

The persistent home `Scaffold`. Shows the scanner as the main body and the bottom navigation bar. Handles the three nav actions: open settings (left slide), toggle camera (center), open tutorial (right slide). It also manages the lifecycle of the `VoiceCommandEngine`, starting or stopping the voice listener based on the user's settings. When the user finishes onboarding and chooses "Show me around," this shell launches the app navigation tutorial.

### `routes/routes.dart`

Named route string constants: `/onboarding`, `/`, `/settings`, `/tutorial`. These are ready for full `go_router` integration. Navigation currently uses `Navigator.push()`.

---

## `core/`

Infrastructure shared by the whole app. Nothing here depends on a specific feature.

### `constants/app_colors.dart`

Every color used in the app, defined in one place. Accent yellow and accent blue are kept consistent across both themes so the color language never changes regardless of light or dark mode. Widgets should use `VisionConfig.accent(isDark)` for accent colors rather than reading from here directly, so contrast boosts apply automatically.

### `constants/app_spacing.dart`

Spacing constants on a 4-point grid. Using named values like `AppSpacing.md` instead of raw numbers keeps layout consistent and makes changes easy across the whole app.

### `constants/app_typography.dart`

Base text style definitions without color bindings. The active text theme is built in `app_theme.dart`. This file is a reference for font sizes and weights used during theming.

### `l10n/app_localizations.dart`

The entry point for all user-facing strings. `AppLocalizations.of(isTagalog)` returns the right string table without needing a `BuildContext`, so it works in providers and services as well as widgets.

### `l10n/en.dart`

All English strings. Every string in the app starts here.

### `l10n/tl.dart`

All Tagalog translations. Each entry must have a matching entry in `en.dart` with the same key name.

### `services/tts_service.dart`

The text-to-speech engine. Runs a priority queue so critical messages like scan results interrupt lower-priority ones. Handles TalkBack coexistence on Android, language switching, and debouncing so rapid navigation events collapse into a single utterance.

### `services/tts_message.dart`

Defines `TtsMessage` and the `TtsPriority` enum. Every spoken utterance in the app is a `TtsMessage` so the queue knows how to route it. Priorities from lowest to highest: ambient, navigation, result, critical.

### `services/speech_scripts.dart`

The only place that builds `TtsMessage` objects from text. If something new needs to be said, it goes here. Organized into classes by area: `AppSpeech`, `NavSpeech`, `SettingsSpeech`, `LanguageSpeech`, and `OnboardingSpeech`. Scanner-specific messages are in `scanner_speech_scripts.dart` and re-exported from here.

### `services/scanner_speech_scripts.dart`

TTS messages specific to the scanner: results, idle hints, and error guidance. Split from `speech_scripts.dart` so scanner-related speech is easy to find and review alongside the scanner feature.

### `services/earcon_service.dart`

Plays non-speech audio cues (earcons) for app events, such as when a scan starts, a result is ready, or a button is pressed. It provides an immediate, low-latency audio channel that complements TTS.

### `services/haptic_service.dart`

Controls all vibration feedback. Three intensity levels: subtle (HapticFeedback only), medium (single motor pulse), and strong (distinct multi-pulse patterns per event type). Device vibration capabilities are cached at startup so patterns fire immediately without any async delay.

### `services/voice/voice_command_service.dart`

Manages the Speech-to-Text hardware lifecycle. It handles permission requests, initializes the speech engine, and implements the wake-word detection logic ("Hey MoneySense"). When a wake-word is detected, it triggers the active listening state.

### `services/voice/voice_intent_parser.dart`

The logic layer that converts raw text from the STT service into structured `VoiceIntent` objects. It supports both English and Tagalog commands using regular expression matching and flexible phrasing.

### `services/voice/voice_command_executor.dart`

The action dispatcher for the voice system. It receives a `VoiceIntent` and executes the corresponding logic (e.g., navigating to a screen, toggling the flash, or providing a spoken status update) by interacting with Riverpod providers.

### `services/voice/voice_command_overlay.dart`

A visual feedback widget that appears at the top of the screen when the app is actively listening for a command. It provides a non-intrusive cue that the voice system is ready for input.

### `services/voice/voice_intent.dart`

Defines the `VoiceIntent` enum representing all supported voice actions (e.g., `openSettings`, `toggleFlash`, `scanNow`).

### `services/shake_service.dart`

Detects intentional phone shakes using the accelerometer. Filters out walking and incidental motion by requiring a high acceleration threshold and two confirmed jolts within a short window. The thresholds are tuned so normal phone handling never triggers it.

### `services/shake_detector_widget.dart`

Connects `ShakeService` to the navigator and the app lifecycle. Starts and stops the accelerometer based on the `shakeToGoBack` setting and pauses the sensor when the app is backgrounded.

### `services/inertial_service.dart`

Detects phone tilt using the raw accelerometer. When the X axis dominates and the phone holds the tilt for one second, it fires a left or right callback. A flat-guard rejects navigation when the phone is lying on a surface, and a cooldown prevents re-firing on the return motion.

### `services/inertial_detector_widget.dart`

Connects `InertialService` to the navigator. Uses `RouteAware` to pause tilt navigation when another screen is on top and resume it when the user returns.

### `theme/app_theme.dart`

Produces the light and dark `ThemeData`. Yellow is the Material 3 primary color so selection states, sliders, and filled buttons are yellow automatically. Blue is secondary, used for switches and the scan button. The same switch and slider configuration is shared between both themes.

---

## `features/`

Each folder here is a self-contained vertical slice. The three internal layers keep UI, business logic, and hardware access separate from each other.

### `onboarding/presentation/screens/onboarding_screen.dart`

A 6-page `PageView` shown on first launch. The user picks their vision profile, language, and navigation preferences (Standard, Gestural, Inertial, or Voice), grants camera permission, and then chooses to take the app tour or go straight to scanning. All choices are held in local state until the final page and written to settings in one go. Accent colors update live as the profile is selected so contrast boosts are visible immediately.

### `scanner/data/datasources/camera_service.dart`

All camera hardware interaction lives here. Provides the available cameras list and the `CameraControllerNotifier` that manages the full camera lifecycle. The notifier has separate `suspend` and `close` methods: suspend releases the hardware but remembers the user wanted the camera open, while close clears that intent. This is how resume-after-background works correctly.

### `scanner/domain/entities/scanner_state.dart`

Defines the scanner state machine and the `DetectionResult` type. States: `idle`, `previewing`, `paused`, `scanning`, `processing`, `result`. These are plain Dart types with no Flutter imports, so they are easy to unit test.

### `scanner/presentation/providers/scanner_provider.dart`

Riverpod providers for scanner state and detection results. `cameraOpenProvider` stores what the user wants (intent). `scannerStateProvider` stores what the scanner is currently doing. `detectionResultProvider` stores the latest ML output. This file also re-exports `camera_service.dart` so other files only need one import.

### `scanner/presentation/screens/scanner_screen.dart`

The main home screen. Manages camera lifecycle from both Android app lifecycle events and route changes using `RouteAware`. Suspends the camera when Settings or Tutorial is pushed on top, resumes when the user returns. Also handles the swipe gestures for navigation when gestural mode is on.

### `scanner/presentation/screens/result_screen.dart`

The display for scan results. It shows the detected denomination with high contrast and announces the result via TTS. It features an automatic go-back timer that returns the user to the scanner after a configurable delay.

### `scanner/presentation/widgets/camera_viewfinder.dart`

The animated border drawn around the camera preview. Changes color and pulses based on scanner state: grey when idle, yellow while scanning, blue while processing, green on a result.

### `settings/data/datasources/settings_storage.dart`

Reads and writes `AppSettings` to `SharedPreferences`. Each field is stored individually using string key constants to avoid typos.

### `settings/domain/entities/app_settings.dart`

The immutable value object holding all user preferences: theme, language, font scale, vision profile, TTS and haptic settings, and navigation toggles. Uses `copyWith` for updates. Everything lives in one object so there is only one provider to watch and one serialization call to save.

### `settings/domain/entities/vision_config.dart`

Computed from `VisionProfile`. This is the single source of truth for how a vision profile changes the app. Provides the font scale floor, contrast level, TTS verbosity default, haptic intensity default, and the `accent(isDark)` color method. All widgets read accent colors from here, not from `AppColors` directly, so profile-based contrast boosts propagate everywhere.

### `settings/presentation/providers/settings_provider.dart`

The Riverpod notifier for settings. Every change goes through a named method (e.g., `setThemeMode`, `toggleFlashlight`) so mutations are auditable. Loads from and saves to `SettingsStorage` on every change.

### `settings/presentation/screens/settings_screen.dart`

The advanced settings UI organized into sections: General, Scanning, Navigation, Accessibility, and Help and Support. Help buttons on relevant tiles open the corresponding interactive tutorial via `TutorialNavigator`.

### `settings/presentation/screens/simple_settings_screen.dart`

The primary settings interface for most users. It features an aesthetic, balanced grid of tiled options (e.g., Theme, Language, Camera, Voice Navigation) without section headers for a cleaner look. The "Advanced Menu" button is integrated into the scrollable list at the bottom.

### `settings/presentation/screens/vision_profile_picker_screen.dart`

A specialized selection screen that allows users to choose their vision profile (Low Vision, Partially Blind, Fully Blind) with live voice feedback for each option.

### `tutorial/domain/tutorial_route.dart`

Enum identifying each available tutorial. Adding a new tutorial means adding a value here and a matching case in `TutorialNavigator`. Layout, animation, and back gesture behavior are all inherited from `MsTutorialScaffold`.

### `tutorial/presentation/screens/tutorial_navigator.dart`

The single entry point for launching any tutorial. Maps a `TutorialRoute` to a widget and pushes it with a slide-up transition. All tutorial navigation in the app goes through here.

### `tutorial/presentation/screens/tutorial_screen.dart`

The tutorial hub, accessible from the bottom nav. Shows a card for each available tutorial grouped by feature area. Tapping a card calls `TutorialNavigator`.

### `tutorial/presentation/screens/app_navigation_tutorial.dart`

A 5-page interactive walkthrough of all navigation methods: the bottom nav bar, gestural swipes, inertial tilt, and shake to go back. Launched automatically if the user chooses "Show me around" at the end of onboarding.

### `tutorial/presentation/screens/denomination_vibration_tutorial.dart`

Teaches the vibration pattern for all 10 Philippine peso denominations. Users can tap any denomination card to feel its pattern, or play all patterns in sequence. Coins use a long pulse followed by short pulses; bills use only short pulses, with the count matching the denomination rank.

### `tutorial/presentation/screens/shake_tutorial.dart`

Interactive tutorial for shake-to-go-back. Uses the live accelerometer so users can practice the gesture and see real-time feedback on screen.

### `tutorial/presentation/screens/gestural_navigation_tutorial.dart`

Interactive tutorial for swipe navigation. A gesture pad at the bottom detects real swipes using the same logic as the scanner screen and shows which action each direction triggers.

### `tutorial/presentation/screens/inertial_navigation_tutorial.dart`

Interactive tutorial for tilt navigation. Shows how tilting the phone left or right triggers screen changes and lets users practice the gesture with live feedback.

### `tutorial/presentation/widgets/ms_tutorial_scaffold.dart`

Shared layout for all feature tutorials. Provides a 260px hero illustration zone at the top and a scrollable content area below with a badge, title, description, and numbered steps. An optional interactive widget can be placed below the steps. Every tutorial uses this scaffold.

---

## `shared/widgets/`

Reusable UI components used by at least two features. All use the `Ms` prefix, accept no Riverpod references, manage their own TalkBack semantics, and adapt to light and dark themes automatically.

### `full_screen_loader.dart`

A full-screen blocking overlay shown during language switches. Covers everything, absorbs all input, and shows a spinner with a message. Dismissed automatically once the switch completes.

### `ms_action_tile.dart`

A tappable settings row with a leading icon, title, subtitle, and trailing chevron. Used for the Help and Support section items.

### `ms_bottom_nav.dart`

The three-button nav bar at the bottom of the home screen. Settings and Tutorial buttons are yellow; the Scan/Stop button is blue. Colors come from `VisionConfig` so contrast boosts apply here too.

### `ms_section_header.dart`

A small uppercased label placed above a group of settings tiles. Deliberately subdued so it does not compete with tile content.

### `ms_segmented_selector.dart`

A pill-style multi-option selector used for Theme and Language settings. Pills use fixed text scaling so they do not overflow at large font sizes, while the surrounding label still scales with the user's preference.

### `ms_settings_card.dart`

A rounded container that groups related settings tiles with dividers. Does not add any `Semantics` wrapping since each child tile handles its own TalkBack focus independently.

### `ms_slider_tile.dart`

A settings row with a slider and plus/minus step buttons for coarser adjustment. Used for font size and intensity controls. TalkBack gets four separate focus nodes: a heading, a decrease button, the slider, and an increase button.

### `ms_timer_tile.dart`

A toggle combined with a tappable duration badge. Used for the auto-go-back timer. The badge opens a picker for the timer duration and is only focusable when the toggle is on.

### `ms_toggle_tile.dart`

A settings row with a switch and an optional help button. The tile and the help button are separate TalkBack focus nodes so both are reachable independently. Help buttons open a feature tutorial.
