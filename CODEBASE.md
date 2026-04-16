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
│   ├── startup_splash.dart
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
│   │   │   ├── authenticity_service.dart
│   │   │   ├── camera_service.dart
│   │   │   └── detection_service.dart
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
│   │           ├── about_screen.dart
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
│           │   ├── tutorial_screen.dart
│           │   └── voice_tutorial.dart
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

### `startup_splash.dart`

Shown on every launch while TTS initializes. Ensures that TTS has fully finalized its internal preparation (and that the Accessibility/TalkBack channels have refreshed) before handing the user over to the initial screens. Uses an earcon locally to ping success before visual UI switches.

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

### `l10n/en.dart` & `l10n/tl.dart`

English and Tagalog strings. Every user-facing UI string, screen reader text, and TTS spoken phrase lives in these two files.

### `services/tts_service.dart`

The text-to-speech engine. Runs a priority queue so critical messages (like scan results) interrupt lower-priority ones. Deals with TalkBack coexistence directly by probing `flutter/accessibility` to delay its own output slightly if an accessibility service is active.

### `services/tts_message.dart`

Defines `TtsMessage` and the `TtsPriority` enum. Every spoken utterance in the app is a strongly-typed `TtsMessage`. Priorities: ambient, navigation, result, critical.

### `services/speech_scripts.dart` & `services/scanner_speech_scripts.dart`

The only places that build `TtsMessage` objects from text. They map the localized strings to priority and verbosity logic. Separated to keep scanner-specific phrases out of general app speech domains.

### `services/earcon_service.dart`

Plays non-speech audio cues (earcons) for app events. Essential for the fully blind to verify system state instantaneously (i.e. camera opened, centered accurately) without needing to listen to an unwieldy full TTS sentence.

### `services/haptic_service.dart`

Controls all vibration feedback using the `vibration` plugin. Defines exactly three intensity levels (subtle, medium, strong). Dynamically assesses device haptic capabilities (`hasAmplitudeControl`) at init so patterns can fallback gracefully to length-based timing instead of amplitude if needed. Contains the core engine for outputting specific denomination vibration patterns.

### `services/voice/voice_command_service.dart`

Manages `speech_to_text`. Initializes listening logic and implements the "hey moneysense" background acoustic wake-word listener. Transitions from passive listening to active parsing upon wake-word validation.

### `services/voice/voice_intent_parser.dart`

Receives raw string output from STT and filters it against English/Tagalog Regex phrases to extract `VoiceIntent` actions. 

### `services/voice/voice_command_executor.dart` & `voice_command_overlay.dart`

`Executor` uses Riverpod references to change state based on intents (e.g. turning on the flash). `Overlay` is a floating UI bug giving sighted users and developers visual context to the acoustic listening phase.

### `services/shake_service.dart` & `services/shake_detector_widget.dart`

Uses accelerometer stream to determine rapid phone translation (shake). Requires multi-jolt verification to decline false positives (like dropping phone casually into pocket). Maps directly back into the Navigator queue to replicate native back button action.

### `services/inertial_service.dart` & `services/inertial_detector_widget.dart`

Reads raw XYZ orientation. Verifies stable dominances (user is strongly tilting the phone and not laying flat on table). Requires active hold duration limits and emits navigation events based on direction.

---

## `features/`

Each folder here is a self-contained vertical slice. The three internal layers keep UI, business logic, and hardware access separate from each other.

### `onboarding/presentation/screens/onboarding_screen.dart`

A 6-page `PageView` shown on first launch. The user picks their vision profile, language, and navigation preferences, grants camera permission, and then chooses to take the app tour or go straight to scanning. All choices are held in local state until the final page and written to settings in one go. Accent colors update live as the profile is selected so contrast boosts are visible immediately.

### `scanner/data/datasources/camera_service.dart`

All camera hardware interaction lives here. Provides the available cameras list and the `CameraControllerNotifier` that manages the full camera lifecycle. The notifier has separate `suspend` and `close` methods: suspend releases the hardware but remembers the user wanted the camera open, while close clears that intent. This is how resume-after-background works correctly.

### `scanner/data/datasources/detection_service.dart`

Houses the continuous, real-time background Isolate for `YOLOv8-Nano`. Operates a tight YUV stream loop, doing direct Float32 tensor conversion and dynamic size adaptation to pass coordinates directly back up to the rendering layer. Contains dynamic heuristics around aspect-ratios uniquely to distinguish the ₱20 coin vs the ₱20 bill.

### `scanner/data/datasources/authenticity_service.dart`

Manages the heavy, isolated operations of the "Triple-Check" authentication. It drives both the `Siamese model` (Cosine similarity measurement across vector dictionaries) and the `ResNet-18` (Genuine vs Fake texturing). Additionally manages `Google ML Kit Text Recognition` instance parsing for gold standard OCR matching. Handles the business logic of veto constraints and majority consensus calculations based on these parallel networks.

### `scanner/domain/entities/scanner_state.dart`

Defines the scanner state machine (`idle`, `previewing`, `paused`, `scanning`, `centering`, `processing`, `result`) and the strongly-typed `DetectionResult`.

### `scanner/presentation/providers/scanner_provider.dart`

Riverpod providers for scanner state and detection results. It coordinates the `DetectionService`, runs the `centering` TTS queues, tracks consecutive matching frames to prevent UI thrashing, and invokes the `AuthenticityService` isolate. 

### `scanner/presentation/screens/scanner_screen.dart`

The main home screen. Manages camera lifecycle from both Android app lifecycle events and route changes using `RouteAware`. Suspends the camera when Settings or Tutorial is pushed on top, resumes when the user returns. Performs on-the-fly ambient lighting detection across the `Y` tensor planes of incoming frames to automatically toggle the system flashlight. Accepts the multi-directional diagonal/horizontal gestural pan tracking logic.

### `scanner/presentation/screens/result_screen.dart`

The display for scan results. Shows the detected denomination with high contrast and announces the result via TTS. Features an automatic go-back timer that returns the user to the scanner after a configurable delay. Displays detailed diagnostic outputs under an expanded tab for authentication (e.g. OCR words matched, Siamese similarity scores).

### `scanner/presentation/widgets/camera_viewfinder.dart`

The animated border drawn around the camera preview. Changes color and pulses based on scanner state: grey when idle, yellow while scanning, blue while centering, green on a result. Features a central crosshair indicating ideal bounds to guide the user towards centered alignment.

### `settings/data/datasources/settings_storage.dart`

Reads and writes `AppSettings` to `SharedPreferences`. Each field is stored individually using string key constants to avoid typos.

### `settings/domain/entities/app_settings.dart` & `vision_config.dart`

`AppSettings`: The immutable value object holding all user preferences. Everything lives in one object so there is only one provider to watch and one serialization call to save.

`VisionConfig`: Computed from `VisionProfile`. The single source of truth for contrast levels, font floors, TTS verbs, and accent colors. Removes standard global styling overrides scattered everywhere in favor of isolated component styling logic mapping back to this strict object.

### `settings/presentation/providers/settings_provider.dart`

The Riverpod notifier for settings. Every change goes through a named method (e.g., `setThemeMode`, `toggleFlashlight`) so mutations are auditable. 

### `settings/presentation/screens/simple_settings_screen.dart` 

The main layout for preferences using aesthetics derived from the Vision profile (toggles, Segmented Control systems). Clean, flat design focusing on critical preferences over granular control.

### `settings/presentation/screens/settings_screen.dart` & `vision_profile_picker_screen.dart` & `about_screen.dart`

Granular detail views. `settings_screen.dart` acts as an Advanced list for highly specific overrides (e.g. exactly how to behave when a scan timeout hits). `about_screen.dart` acts as an app identifier layout. `vision_profile_picker_screen.dart` manages live-time changing of critical user profiles with immediate contrasting visual feedback inside its local scope. 

### `tutorial/` 

`tutorial_route.dart` acts as a static list. `tutorial_navigator.dart` and `ms_tutorial_scaffold.dart` form an isolated routing setup letting any piece of UI pop up a visual guide showing an animated hero graphic and specific instructions.
There are individualized interactive playgrounds inside `presentation/screens/*_tutorial.dart` specifically letting users run live sensors for `Shake`, `Inertial`, `Gestures`, and `Vibration Patterns` securely to get comfortable without messing up true actions inside the scanner.

---

## `shared/widgets/`

Reusable UI components used by at least two features. All use the `Ms` prefix, accept no Riverpod references, manage their own TalkBack semantics, and adapt to light and dark themes automatically.

- **`full_screen_loader.dart`**: Complete screen absorption lock-out overlay used during heavy async loads like language parsing resets.
- **`ms_bottom_nav.dart`**: Unified three-button static bar using `VisionConfig` colors directly. 
- **`ms_segmented_selector.dart`**: Non-scaling (TextScale blocked explicitly via MediaQuery) aesthetic pill structures for Theme/Language swaps.
- **`ms_slider_tile.dart`**: Combines sliders, plus/minus indicators, and isolated TalkBack segments to guarantee granular value shifts without breaking finger-tracing.
- **`ms_timer_tile.dart`**: Unique combinations of string badging and on/off toggles to encapsulate features like the auto-close Result Screen.
- **`ms_action_tile.dart` & `ms_settings_card.dart` & `ms_toggle_tile.dart`**: Base elements providing structural rendering to complex UI layouts to standardize padding drops and dividers universally.
