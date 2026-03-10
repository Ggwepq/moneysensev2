# MoneySense: System and Architecture Documentation

---

## 1. What MoneySense Is

### Background

In the Philippines, where most everyday transactions still rely on cash, identifying currency accurately is a basic daily need. For the estimated 2.5 million visually impaired Filipinos, this is a persistent challenge. The Bangko Sentral ng Pilipinas introduced tactile marks on banknotes in 2020, but research has found these are not always sufficient, particularly when notes are worn or when a user has limited tactile sensitivity. Peso coins are similarly difficult to tell apart by touch alone, since their differences come down to size, weight, and engraved detail that is not always easy to feel consistently.

Mobile apps using computer vision and text-to-speech have shown real promise for this problem, and some reach recognition accuracy above 90%. However, the available options share a set of common limitations: most scan only one bill at a time, require an internet connection, and do not support Filipino and English voice output together. No existing application is designed specifically for Filipino users, works offline, recognizes multiple bills and coins at once, provides bilingual audio, and is completely free.

MoneySense was built to fill that gap. It uses the phone camera to detect Philippine peso bills and coins in real time, announces the denomination by voice in Filipino or English, and works entirely without an internet connection. It is designed for three user groups: people with low vision who benefit from larger text and higher contrast, people with partial blindness who rely on audio cues alongside some remaining vision, and people who are fully blind and navigate entirely by sound and touch.

### Goal

Give visually impaired Filipinos a reliable, independent way to handle cash without needing to ask for help.

### Objectives

1. Design an accessible interface and system architecture that supports all three vision profiles across all app features.
2. Build a real-time detection system using YOLOv8 for denomination identification and MobileNet for authenticity verification, capable of working under varying lighting, orientations, and backgrounds.
3. Test bill and coin recognition, real-time performance, and voice guidance through structured test cases under different conditions.
4. Evaluate usability, reliability, accuracy, and accessibility using the FURPS framework alongside testing with visually impaired participants.

### Supported Currency

**Bills:** ₱20, ₱50, ₱100, ₱200, ₱500, ₱1,000

**Coins:** New ₱20, new and old ₱10, new and old ₱5, new and old ₱1, new 25 centavos

### Limitations

Recognition accuracy can drop under poor lighting, with heavily worn or folded notes, with overlapping items, or on low-end devices with slower processors. The app supports Filipino and English only; other Philippine languages are not included in this version.

---

## 2. Architecture Overview

MoneySense uses **feature-first Clean Architecture** with **Riverpod** for reactive state management.

```
lib/
├── app/        Root widget and navigation shell
├── core/       Constants, theme, localisation, and platform services
├── features/   Self-contained feature slices
└── shared/     Reusable UI components shared across features
```

Each feature folder contains three internal layers:

```
features/<n>/
├── data/           Platform and storage access
├── domain/         Pure Dart entities and enums
└── presentation/   Providers (state logic), screens (UI), widgets
```

The domain layer has no Flutter or package imports, which means it can be unit tested without a device or emulator. The data layer wraps hardware and storage so those concerns never leak into the UI. Providers sit in the presentation layer as the boundary between business logic and widgets.

---

## 3. Why Feature-First Organization

The alternative to feature-first is layer-first: all screens in one folder, all providers in another, all models in a third. This layout works for simple apps but becomes painful as the codebase grows, because a single feature change requires jumping between multiple distant folders.

In MoneySense, each feature interacts with different hardware. The scanner uses the camera, the navigation features use the accelerometer, and settings use persistent storage. Keeping each feature self-contained means the camera code, camera state, and camera UI are all in the same place. Adding or removing a feature is a folder operation, not a search-and-edit across the project.

---

## 4. Why Riverpod

Riverpod was chosen over BLoC and the original Provider package for reasons specific to this app's requirements.

**Cross-widget state without wiring.** `cameraOpenProvider` and `appSettingsProvider` are read by the scanner, the bottom nav, the shake detector, and the settings screen simultaneously. Riverpod makes this trivial. With BLoC, cross-widget access requires `BlocProvider` trees or global singletons; with Provider it requires careful `InheritedWidget` ancestors.

**Hardware lifecycle management.** `ref.onDispose` automatically stops accelerometer streams and disposes camera controllers when providers are garbage-collected. Without this, widgets have to manually chain `dispose()` calls, which is easy to get wrong and causes resource leaks.

**Async hardware initialization.** Camera initialization is async and can fail. `AsyncNotifierProvider` provides `AsyncValue<CameraController?>` for free, covering loading, error, and data states without boilerplate.

**Pre-run value injection.** The camera list and SharedPreferences instance are discovered in `main()` before `runApp()` and injected via `ProviderScope.overrides`. This pattern lets the entire app start with real data already in place rather than showing a loading state on the first frame.

**Selective rebuilds.** A widget that only cares about one setting can use `.select()` to avoid rebuilding when unrelated settings change. For example, the shake detector subscribes to `appSettingsProvider.select((s) => s.shakeToGoBack)` and does not rebuild when the font size or language changes.

---

## 5. The Vision Profile System

The vision profile is the core personalization mechanism. When the user picks Low Vision, Partially Blind, or Fully Blind during onboarding, it feeds into `VisionConfig`, which computes all adaptive behavior for that profile.

`VisionConfig` provides: a minimum font scale floor, a contrast level that boosts accent colors, default TTS verbosity and haptic intensity, flags for whether navigation and idle state should be announced automatically, and `accent(isDark)` / `accentForeground(isDark)` color methods.

Every widget reads accent colors from `VisionConfig.accent(isDark)` rather than from `AppColors` directly. `AppColors` holds the base palette. `VisionConfig` adds the profile-appropriate contrast boost on top. This means changing a contrast threshold in `VisionConfig` affects every screen at once.

If widgets read from `VisionProfile` directly with a switch statement, then every widget would need to be updated when a profile is added or modified. With `VisionConfig` as the intermediary, the widget does not need to know which profile is active, only what color and behavior to use.

---

## 6. State Management Patterns

### Intent vs hardware state

The camera uses two separate providers:

```
cameraOpenProvider        what the user wants (bool)
cameraControllerProvider  what the hardware is actually doing (CameraController?)
```

This separation exists because the user's intent must survive background and foreground cycles, while the hardware controller must be released whenever the app loses foreground. `suspendCamera()` releases the hardware but leaves the intent flag true. `closeCamera()` clears the intent. When the app resumes, checking the intent flag determines whether to reopen.

### Settings as a single value object

All 13 user preferences live in one `AppSettings` object under `appSettingsProvider`. This means one subscription instead of 13, atomic updates via `copyWith`, and one serialization call to persist everything. Widgets that only care about one field use `.select()` to limit rebuilds.

### Named mutator methods

No widget writes `state = ...` directly to the settings provider. All changes go through named methods like `setThemeMode` and `setVisionProfile`. This keeps all state transitions named and easy to audit.

---

## 7. Navigation Design

MoneySense uses `Navigator.push()` for main screen navigation and a static `TutorialNavigator` for tutorials.

### Slide direction matches the triggering gesture

The swipe gesture and the slide animation point the same direction, so the user can build a spatial mental model of where each screen lives.

| Destination | Trigger | Slide direction |
|---|---|---|
| Settings | Swipe right | Enters from the left |
| Tutorial hub | Swipe left | Enters from the right |
| Feature tutorial | Help button or tutorial card | Slides up from the bottom |

### Why push instead of tab switching

When Settings or Tutorial is open, the bottom nav disappears. Using `Navigator.push()` achieves this without any custom visibility logic. It also gives Android's native back button behavior for free.

### Camera and route awareness

`ScannerScreen` subscribes to a shared `RouteObserver` via the `RouteAware` mixin. When a route is pushed on top, `didPushNext()` fires and the camera suspends. When that route pops, `didPopNext()` fires and the camera resumes if the intent flag is still true. This is separate from the Android app lifecycle observer. Both are needed because neither alone can distinguish between a route push inside the app and the user pressing the home button.

---

## 8. Accessibility Architecture

Accessibility is built into every widget and design decision in the app, not added as an afterthought.

### TalkBack semantics

Every interactive widget manages its own semantics tree explicitly. Flutter's automatic merging can combine a tile and its help button into one focus node, which hides the help button from TalkBack users. The approach here is deliberate suppression: composite tiles use `excludeSemantics: true` on the top-level `Semantics` node to suppress descendant auto-generated nodes, then create explicit nodes for the parts TalkBack needs to reach. When a tile and a help button must be separate focus stops, both use `container: true` to create hard boundaries.

### Font scaling

The user's chosen font scale is applied at the root via a `MediaQuery` override in `app.dart`. All text in the app scales without any widget knowing about it. The segmented selector pills are the one exception: they opt out of scaling with `MediaQuery.withNoTextScaling` because they are fixed-size chrome and cannot grow without breaking the layout.

### Vibration as primary output

For fully blind users, the denomination vibration patterns are a primary output channel, not a secondary confirmation. Each of the 10 denominations has a unique pattern of long and short pulses that can be learned and identified without looking at the screen. The interactive tutorial for this feature lets users practice each pattern before relying on it in real use.

### TTS priority queue

The TTS engine runs a priority queue so time-sensitive messages are never blocked. A scan result always interrupts ambient guidance. Navigation messages are debounced so rapid transitions produce one utterance instead of stacking. The engine also adds a short delay when TalkBack is detected as active so the app's voice does not talk over TalkBack's announcements.

---

## 9. Camera Lifecycle

The camera lifecycle is the most complex part of the app because it involves Android lifecycle events, route changes, the flash state, and the intent flag all interacting.

### Why `inactive` is ignored

`AppLifecycleState.inactive` fires when the user pulls down the notification shade, swipes up the navigation bar, or when a call HUD appears. These are not genuine backgrounds. Releasing the camera on `inactive` would turn off the flashlight every time the user pulls down the notification bar while scanning. The correct behavior is to only release hardware on `paused` or `hidden`, which represent genuine backgrounds.

### The `_routeObscured` flag

A boolean flag prevents the camera from restarting prematurely. When `didPushNext()` fires, the flag is set to true. On `AppLifecycleState.resumed`, the camera only restarts if the flag is false. This prevents a double-resume when the user backgrounds the app while Settings is open and then returns.

---

## 10. ML Model Integration

The ML pipeline is the pending connection point. The rest of the system works independently so wiring in the model requires changes in one place.

**YOLOv8** runs on-device via TensorFlow Lite for real-time denomination detection. It handles multiple objects in a single frame, which is what enables multi-bill and multi-coin scanning. On-device inference is also what makes offline operation possible.

**MobileNet** provides a lightweight verification pass to confirm authenticity and improve classification confidence. It is fast enough for mid-range Android devices without causing frame drops during scanning.

When the model produces a result, it writes to `detectionResultProvider`. The scanner screen, TTS service, and vibration service all watch this provider and respond automatically. The `startScanning()` method in `ScannerNotifier` is where this write happens.

---

## 11. Localisation Approach

All user-facing strings live in `en.dart` and `tl.dart`. `AppLocalizations.of(isTagalog)` returns the right table. It does not need a `BuildContext`, which means strings work in providers, services, and TTS scripts without passing context through call chains.

This is simpler than ARB-based localisation for the current stage. ARB generates files and requires build steps; the direct Dart approach is faster to iterate on. The architecture supports migrating to ARB when the string set stabilizes and the team grows.

---

## 12. Tutorial System

Adding a new tutorial takes three changes: add a value to `TutorialRoute`, add a case in `TutorialNavigator`, add a card in `TutorialScreen`. All layout, animation, and navigation behavior is handled by `MsTutorialScaffold`.

Each tutorial has a 260px hero zone for an animated illustration and a scrollable content area for instructions. An optional interactive zone at the bottom lets users practice the feature with live sensor or gesture input. The interactive zone is fully self-contained and receives nothing from the scaffold.

---

## 13. Plugin Rationale

| Plugin | Why it was chosen |
|---|---|
| flutter_riverpod | Best support for cross-widget state, async initialization, and lifecycle management in Flutter without `InheritedWidget` boilerplate |
| camera | Official Flutter team plugin. Provides camera preview, lens switching, flash control, and image streaming, which are all needed when the ML pipeline is connected |
| flutter_tts | Most widely used Flutter TTS plugin. Supports both Android TTS and iOS AVSpeechSynthesizer, handles language codes, and can share the audio session with TalkBack on Android |
| sensors_plus | Official community plugin for accelerometer and other sensors. Stream-based API integrates cleanly with Riverpod providers |
| vibration | Provides amplitude control for vibration on Android. Flutter's built-in `HapticFeedback` does not support custom amplitudes or pattern timing, which are both required for the denomination feedback system |
| shared_preferences | Simple key-value persistence. Sufficient for the current settings model without the overhead of a local database |
| go_router | Prepared for future deep-link and route-guard support. Route constants are already defined |
| intl | Required by `flutter_localizations` for date and number formatting support |
