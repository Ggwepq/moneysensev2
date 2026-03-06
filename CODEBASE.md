# MoneySense — Codebase Documentation

> **Version:** 1.0.0+1  
> **Platform:** Flutter (Android-first, portrait-only)  
> **Audience:** Visually impaired users identifying Philippine currency denominations

---

## Table of Contents

1. [Project Goal](#1-project-goal)
2. [Architecture Overview](#2-architecture-overview)
3. [Why This Architecture](#3-why-this-architecture)
4. [Dependency Reference](#4-dependency-reference)
5. [Directory Structure](#5-directory-structure)
6. [Layer Reference — `app/`](#6-layer-reference--app)
7. [Layer Reference — `core/`](#7-layer-reference--core)
8. [Layer Reference — `features/`](#8-layer-reference--features)
9. [Layer Reference — `shared/`](#9-layer-reference--shared)
10. [State Management Patterns](#10-state-management-patterns)
11. [Navigation Model](#11-navigation-model)
12. [Accessibility Architecture](#12-accessibility-architecture)
13. [Camera Lifecycle](#13-camera-lifecycle)
14. [Tutorial System](#14-tutorial-system)
15. [Adding New Features](#15-adding-new-features)

---

## 1. Project Goal

MoneySense is a **bilingual, accessibility-first** Flutter application that helps visually impaired Filipino users identify Philippine peso denominations through the camera. The primary users are people with **low vision**, **partial blindness**, or **full blindness** — categories selected during onboarding that inform how the app behaves.

Every design decision flows from three non-negotiable requirements:

| Requirement | What it means in practice |
|---|---|
| **Accessible by default** | WCAG 2.1 AA compliance, TalkBack-first semantics, adjustable font scale (0.8×–2.0×), haptic and vibration feedback as primary output channels |
| **Bilingual** | All user-facing strings support English and Tagalog with zero code duplication |
| **Physically navigable** | The app must be usable with one hand, eyes closed, or while holding currency — gestural swipes, shake-to-go-back, inertial tilt, and vibration patterns replace visual-only interactions |

---

## 2. Architecture Overview

MoneySense uses **feature-first Clean Architecture** layered with **Riverpod** for reactive state management.

```
lib/
├── main.dart                    ← Bootstrap, ProviderScope, system chrome
├── app/                         ← Root widget, navigation shell, route constants
├── core/                        ← Framework-wide: constants, theme, l10n, services
├── features/                    ← Domain-isolated vertical slices
│   ├── onboarding/
│   ├── scanner/
│   ├── settings/
│   └── tutorial/
└── shared/                      ← Reusable UI widgets used across ≥2 features
```

Each feature is a self-contained vertical slice that owns three layers internally:

```
feature/
├── data/
│   └── datasources/    ← Platform APIs, hardware drivers (camera, sensors)
├── domain/
│   └── entities/       ← Pure Dart value objects, enums, state types
└── presentation/
    ├── providers/       ← Riverpod notifiers (state + business logic)
    ├── screens/         ← Full-page widgets wired to providers
    └── widgets/         ← Private sub-widgets for this feature only
```

---

## 3. Why This Architecture

### Feature-first over layer-first

A layer-first layout (`screens/`, `providers/`, `models/` at the top level) forces developers to jump between distant folders for every feature change. In MoneySense, where each feature has distinct hardware requirements (camera, accelerometer, vibration), a **feature-first slice** keeps all related code collocated. Adding or removing a feature is as simple as adding or removing one folder.

### Clean Architecture layers within each feature

The three-layer split (data → domain → presentation) is not academic ceremony — it serves a concrete purpose here:

- **Domain entities are pure Dart.** `AppSettings`, `ScannerState`, `DetectionResult`, and `TutorialRoute` carry no Flutter imports. They can be unit-tested with zero widget infrastructure and are easily serialised for persistence.
- **Data sources are hardware-isolated.** `CameraService` wraps the `camera` package. If the camera API changes or is swapped for a different plugin, only `data/datasources/camera_service.dart` needs updating — nothing in the presentation layer changes.
- **Providers own business logic.** The presentation layer never reaches directly into data sources. All platform interaction goes through a Riverpod notifier, which means every state transition is observable and testable.

### Riverpod over BLoC / Provider / setState

Riverpod was chosen over the alternatives for reasons that are specific to MoneySense's needs:

| Concern | Why Riverpod wins here |
|---|---|
| **Multiple screens reading the same state** | `cameraOpenProvider` and `appSettingsProvider` are read by the scanner, the bottom nav, the shake detector, and the settings screen simultaneously. Riverpod makes cross-widget state trivial without `InheritedWidget` plumbing. |
| **App lifecycle & hardware** | `ref.onDispose` automatically stops the accelerometer stream and disposes camera controllers when providers are garbage-collected — no manual `dispose()` chains in widgets. |
| **`ProviderScope` overrides at startup** | `availableCamerasProvider` is seeded with the hardware camera list before `runApp()`. This pattern is not possible with BLoC and requires awkward workarounds in the original `Provider` package. |
| **`AsyncNotifier` for async hardware** | Camera initialisation is inherently async and failable. `AsyncNotifierProvider` gives `AsyncValue<CameraController?>` for free, covering loading, error, and data states without boilerplate. |
| **Fine-grained rebuilds** | `.select()` subscriptions (e.g., `appSettingsProvider.select((s) => s.shakeToGoBack)`) prevent the shake detector from rebuilding when unrelated settings change. |

### Shared widgets as a design system

The `shared/widgets/` folder is a **private component library**, not a dumping ground. Every widget there is used by at least two features and follows the `Ps` prefix naming convention. Each widget:

- Manages its own TalkBack semantics tree independently
- Accepts only plain Dart values (no Riverpod references)
- Adapts automatically to the current theme brightness

This makes them testable in isolation and safe to use in any context.

---

## 4. Dependency Reference

| Package | Role |
|---|---|
| `flutter_riverpod` | Reactive state management |
| `riverpod_annotation` + `build_runner` | Code generation for providers (future use) |
| `camera` | Camera hardware access — preview, flash, lens switching |
| `sensors_plus` | Accelerometer stream for shake detection |
| `vibration` | Motor vibration patterns for denomination feedback |
| `flutter_tts` | Text-to-speech output (wired, implementation pending) |
| `shared_preferences` | Settings persistence (wired, implementation pending) |
| `flutter_secure_storage` | Secure credential storage (reserved for future use) |
| `go_router` | Named route constants (wired, full integration pending) |
| `intl` | Internationalisation support |
| `flutter_localizations` | Material localisation delegates |
| `flutter_screenutil` | Responsive sizing utilities |
| `gap` | Semantic spacing widgets |

---

## 5. Directory Structure

Full annotated file tree of `lib/`:

```
lib/
│
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── home_shell.dart
│   └── routes/
│       └── routes.dart
│
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
│   │   ├── shake_service.dart
│   │   └── shake_detector_widget.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/                    ← Reserved for future utility functions
│
├── features/
│   │
│   ├── onboarding/
│   │   └── presentation/
│   │       └── screens/
│   │           └── onboarding_screen.dart
│   │
│   ├── scanner/
│   │   ├── data/
│   │   │   └── datasources/
│   │   │       └── camera_service.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── scanner_state.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── scanner_provider.dart
│   │       ├── screens/
│   │       │   └── scanner_screen.dart
│   │       └── widgets/
│   │           └── camera_viewfinder.dart
│   │
│   ├── settings/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── app_settings.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── settings_provider.dart
│   │       └── screens/
│   │           └── settings_screen.dart
│   │
│   └── tutorial/
│       ├── domain/
│       │   └── tutorial_route.dart
│       └── presentation/
│           ├── screens/
│           │   ├── tutorial_screen.dart
│           │   ├── tutorial_navigator.dart
│           │   ├── denomination_vibration_tutorial.dart
│           │   ├── shake_tutorial.dart
│           │   └── gestural_navigation_tutorial.dart
│           └── widgets/
│               └── ms_tutorial_scaffold.dart
│
└── shared/
    └── widgets/
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

## 6. Layer Reference — `app/`

The `app/` layer is the composition root. It wires the root widget, the navigation shell, and global services. Nothing in `app/` contains business logic.

---

### `main.dart`

**Purpose:** Bootstrap entry point. Executed once before the widget tree exists.

**Responsibilities:**
- Calls `WidgetsFlutterBinding.ensureInitialized()` so plugin channels are ready before async operations
- Discovers camera hardware via `availableCameras()` from the `camera` package and handles the no-camera fallback
- Forces portrait orientation via `SystemChrome.setPreferredOrientations`
- Sets transparent status and navigation bars for edge-to-edge display
- Starts the `ProviderScope` and injects the camera list via `overrides` so `availableCamerasProvider` is seeded before any widget reads it

**Why here and not in a provider:** Camera discovery is hardware I/O that must complete before the first frame. Putting it in `main()` before `runApp()` is the only way to guarantee the list is available synchronously to all providers.

---

### `app/app.dart` — `MoneySenseApp`

**Purpose:** Root `ConsumerWidget` that owns the `MaterialApp`.

**Responsibilities:**
- Watches `appSettingsProvider` to reactively switch themes and apply the user's font scale
- Wraps `MaterialApp` in a `MediaQuery` override that injects `TextScaler.linear(settings.fontScale)` — this is how the WCAG 1.4.4 font-scaling requirement is fulfilled app-wide without touching individual widgets
- Registers `routeObserverProvider` on `MaterialApp.navigatorObservers` so `ScannerScreen` can detect when other routes obscure it
- Wraps `HomeShell` in `ShakeDetectorWidget` so the accelerometer is active across the whole app

**Key pattern — MediaQuery font override:**
The `Builder` widget is required because `MediaQuery.of(context)` must resolve from a context that is *below* the `MaterialApp`. The outer `Builder` provides that context before the `MediaQuery` override is applied.

---

### `app/home_shell.dart` — `HomeShell`

**Purpose:** Single root `Scaffold` that hosts the scanner and the bottom navigation bar.

**Responsibilities:**
- Renders `ScannerScreen` as the persistent body (it is never removed from the tree)
- Renders `MsBottomNav` and handles its three tap actions
- Pushes `SettingsScreen` with a **left-slide** transition (entering from the left mirrors the right-swipe gesture that triggered it)
- Pushes `TutorialScreen` with a **right-slide** transition (entering from the right mirrors the left-swipe gesture)
- Drives camera open/close via three coordinated provider writes on the middle button tap

**Why Settings and Tutorial are pushed (not tab-switched):** The bottom nav must disappear on Settings and Tutorial screens. Pushing routes achieves this without a custom `IndexedStack` or visibility hack. It also gives native back-button and swipe-back behaviour for free on both iOS and Android.

---

### `app/routes/routes.dart` — `AppRoutes`

**Purpose:** Named route constant strings.

**Contents:** Four `static const String` values: `/onboarding`, `/`, `/settings`, `/tutorial`.

**Status:** These constants are defined for eventual `go_router` wiring. Current navigation uses imperative `Navigator.push()` calls in `HomeShell` and `TutorialNavigator`.

---

## 7. Layer Reference — `core/`

The `core/` layer contains infrastructure that has no dependency on any feature. Everything here is either framework configuration, platform abstraction, or a stateless utility.

---

### `core/constants/app_colors.dart` — `AppColors`

**Purpose:** Single source of truth for all colours used in the application.

**Design decisions:**
- `accentYellow = #E2DA00` and `accentBlue = #1E30F0` are identical in both light and dark themes. This was an intentional product decision: the colour language is consistent regardless of theme, so users learn one mapping — yellow means selection/primary, blue means action/toggle.
- `darkBackground = #010F1C` is a deep navy rather than pure black, giving depth to the dark theme without the harshness of `#000000`
- Dark surface layers step up in lightness (`darkSurface`, `darkSurfaceVariant`, `darkBorder`) so cards and tiles read as elevated even without shadows
- All colours are `static const` — zero runtime cost, compile-time safety

**WCAG contrast guidance (documented in file):**
- `accentYellow` on `darkBackground`: ~13.6:1 ✓ (exceeds AA for large text)
- `accentBlue` on `lightBackground`: ~5.0:1 ✓ (passes AA for normal text)

---

### `core/constants/app_spacing.dart` — `AppSpacing`

**Purpose:** 4-point spacing grid as named constants.

**Contents:** `xs` (4), `sm` (8), `md` (12), `base` (16), `lg` (20), `xl` (24), `xxl` (32), `xxxl` (48), `pagePadding` (16), `tileRadius` (12), `buttonRadius` (16).

**Why a spacing scale:** Consistent spacing prevents the visual inconsistency that accumulates when developers use arbitrary numbers. All padding and gap values in the app reference these constants. Adding `SizedBox(height: AppSpacing.md)` is more readable and maintainable than `SizedBox(height: 12)`.

---

### `core/constants/app_typography.dart` — `AppTypography`

**Purpose:** Typography scale as `TextStyle` constants.

**Status:** Defined as a reference and for future use. The active text theme is driven by `AppTheme._textTheme()` in `app_theme.dart`, which adds colour bindings that `AppTypography` intentionally omits (it provides colour-neutral base styles).

---

### `core/l10n/app_localizations.dart` — `AppLocalizations`

**Purpose:** Thin accessor layer over the two string tables.

**Pattern:** `AppLocalizations.of(bool isTagalog)` returns an instance bound to either `EnStrings` or `TlStrings`. Every string getter delegates to the appropriate static class. This avoids a `BuildContext` dependency — strings can be accessed from providers and services, not just widgets.

**Why not `flutter_localizations` ARB files:** ARB-based localisation requires build steps and a `BuildContext`. For an early-stage project where strings change frequently, the direct Dart approach is faster to iterate on and easier to review in code. The architecture supports migration to ARB when the string set stabilises.

---

### `core/l10n/en.dart` — `EnStrings`
### `core/l10n/tl.dart` — `TlStrings`

**Purpose:** Static string tables for English and Tagalog respectively.

**Convention:** Every public getter in `AppLocalizations` must have a corresponding constant in both files with identical keys. Adding a new string requires one line in each file plus one getter in `AppLocalizations`.

---

### `core/services/shake_service.dart` — `ShakeService` + `shakeServiceProvider`

**Purpose:** Accelerometer-based shake detection with anti-false-positive filtering.

**Algorithm:**
1. Sample the accelerometer at ~50 Hz (`samplingPeriod: 20ms`)
2. Remove gravity using a low-pass filter (`α = 0.85`): `g = α·g + (1−α)·raw`
3. Compute the dynamic acceleration magnitude: `√(dx²+dy²+dz²)`
4. Fire a "jolt" event when magnitude ≥ 15.0 m/s² (above all incidental motion)
5. Debounce consecutive jolts from the same physical shake (150 ms cooldown)
6. Require 2 jolts within an 800 ms window to confirm an intentional shake
7. Rate-limit the callback to once per 1200 ms to prevent rapid re-triggering

**Threshold rationale:** Earth gravity ≈ 9.8 m/s². Walking produces ~3–6 m/s² dynamic acceleration. Putting a phone down firmly produces ~8 m/s². An intentional wrist shake produces 12–25 m/s². The 15.0 m/s² threshold sits cleanly above all incidental motion.

**`shakeServiceProvider`:** A singleton `Provider<ShakeService>` scoped to the app lifetime. `ref.onDispose` stops the accelerometer stream when the app is destroyed, preventing resource leaks.

---

### `core/services/shake_detector_widget.dart` — `ShakeDetectorWidget`

**Purpose:** Widget that connects `ShakeService` to the Navigator and the app lifecycle.

**Responsibilities:**
- Watches `appSettingsProvider.shakeToGoBack` and starts/stops the service reactively — when the toggle is off, the accelerometer stream is fully closed (zero CPU/battery overhead)
- Implements `WidgetsBindingObserver` to stop the service on `paused`/`hidden` lifecycle states and restart it on `resumed`
- `inactive` is explicitly ignored (same policy as the camera) because nav-bar swipes and notification shades trigger `inactive` but the app is still visible
- On a confirmed shake: fires `HapticFeedback.mediumImpact()` immediately, then `Vibration.vibrate(duration: 60, amplitude: 200)` for a distinct motor "thud", then calls `Navigator.of(context).maybePop()`
- Exposes an `onShake` parameter so callers can override the default pop behaviour (e.g., dismiss a result overlay, trigger a scan)

---

### `core/theme/app_theme.dart` — `AppTheme`

**Purpose:** Produces `ThemeData` for both light and dark modes.

**Colour philosophy:**
- **Yellow (`#E2DA00`) = primary** on both themes — Material 3 uses `ColorScheme.primary` for selected segmented pills, slider tracks, and filled buttons. Setting this to yellow means all selection states are yellow automatically.
- **Blue (`#1E30F0`) = secondary** on both themes — Switch tracks (on state) and the scan button use blue, encoding the semantic "action/toggle" meaning.

**Shared helpers:**
- `_textTheme(primary, secondary)` — builds the full `TextTheme` with WCAG-compliant base sizes. `bodyLarge` = 16sp, `bodySmall` = 13sp, `labelSmall` = 11sp. At 80% user scale these become 12.8sp, 10.4sp, 8.8sp — all above the practical 10sp legibility floor.
- `_switchTheme(...)` — shared switch configuration. Track is always blue when on, muted when off.
- `_sliderTheme(inactive)` — slider always uses yellow for active track and thumb.

---

## 8. Layer Reference — `features/`

---

### Feature: `onboarding/`

**Purpose:** First-run experience that collects the user's vision profile and language preference before entering the main app.

---

#### `onboarding/presentation/screens/onboarding_screen.dart` — `OnboardingScreen`

**Purpose:** Three-step stepper screen shown on first launch.

**Steps:**
1. Welcome — app name, logo, one-line description
2. Vision profile selection — Low Vision / Partially Blind / Fully Blind (drives future TTS and haptic intensity)
3. Language selection — English / Tagalog (persisted to `appSettingsProvider` and affects all UI strings immediately)

**Completion:** `onComplete` callback is fired after step 3. The caller (`main.dart` or a future route guard) is responsible for marking onboarding as done in `SharedPreferences` and navigating to the home shell.

**State:** All step selections are held in local `StatefulWidget` state until `onComplete`, at which point they are committed to `appSettingsProvider` in a single write. This avoids partial saves if the user backs out mid-flow.

---

### Feature: `scanner/`

The scanner is the core feature of the app. It manages camera hardware, the scanning state machine, and will connect to the ML model.

---

#### `scanner/data/datasources/camera_service.dart`

**Purpose:** All camera hardware interaction lives in this single file.

**Providers:**
- `availableCamerasProvider` — a `Provider<List<CameraDescription>>` that must be overridden in `ProviderScope` at startup. Throws `UnimplementedError` if used without the override (a deliberate guard against missing setup).
- `cameraControllerProvider` — `AsyncNotifierProvider<CameraControllerNotifier, CameraController?>`. The async value is `null` when the camera is closed, `loading` during initialisation, and the live `CameraController` once ready.

**`CameraControllerNotifier` methods:**

| Method | Effect |
|---|---|
| `openCamera(useFrontCamera, useFlash)` | Disposes any existing controller, picks the correct lens, initialises, applies flash mode |
| `closeCamera()` | Disposes and sets state to `null`. Clears the open intent. |
| `suspendCamera()` | Disposes without clearing intent. Used when backgrounded or navigating away. |
| `resumeCamera(useFrontCamera, useFlash)` | Re-opens with saved settings. Used on foreground restore. |
| `setFlash(enabled)` | Applies flash mode to the live controller without reinitialising. |
| `switchCamera(...)` | Re-opens with the opposite lens. |

**Why `suspend`/`resume` vs `close`/`open`:** The camera must be released when the app backgrounds (OS requirement) but the user's intent to have it open must survive. Closing would require the user to re-tap the button after returning to the app. The intent flag `cameraOpenProvider` remembers whether the camera *should* be open — `suspendCamera` releases the hardware while preserving that flag.

---

#### `scanner/domain/entities/scanner_state.dart`

**Purpose:** Defines the scanner's state machine and the detection result type.

**`ScannerState` enum:**

| State | Meaning |
|---|---|
| `idle` | Camera off, no preview |
| `previewing` | Camera live, showing feed |
| `paused` | Feed frozen on double-tap (camera hardware stays open) |
| `scanning` | Active scan in progress — yellow pulsing border |
| `processing` | ML inference running — blue pulsing border |
| `result` | Detection complete — green solid border, result overlay shown |

**`DetectionResult`:** Immutable value class holding denomination string (e.g., `"₱1,000"`), type (`"bill"` or `"coin"`), confidence (0.0–1.0), and an optional cropped image path. All fields are set by the ML pipeline once connected.

---

#### `scanner/presentation/providers/scanner_provider.dart`

**Purpose:** State providers for the scanner and detection result.

**Providers:**
- `cameraOpenProvider` — `StateProvider<bool>`. The user's *intent* for the camera to be open. Survives app suspend/resume cycles. Distinguished from the actual controller state in `cameraControllerProvider`.
- `scannerStateProvider` — `NotifierProvider<ScannerNotifier, ScannerState>`. The state machine. Methods: `openCamera`, `closeCamera`, `pausePreview`, `resumePreview`, `startScanning`, `startProcessing`, `showResult`, `reset`.
- `detectionResultProvider` — `StateProvider<DetectionResult?>`. Holds the most recent detection result. Written by the ML pipeline, read by the result overlay and TTS service.

**Re-exports `camera_service.dart`:** Features that need to interact with the camera only need to import `scanner_provider.dart` — it re-exports the data source, so there is one import path for all camera-related symbols.

---

#### `scanner/presentation/screens/scanner_screen.dart` — `ScannerScreen`

**Purpose:** The main home screen. Manages camera lifecycle, gesture recognition, and state-driven UI.

**Also defines `routeObserverProvider`:** The `RouteObserver` is co-located here because `ScannerScreen` is the primary consumer. It is registered on `MaterialApp.navigatorObservers` in `app.dart`.

**Camera lifecycle policy:**

| Event | Action | Reason |
|---|---|---|
| `AppLifecycleState.inactive` | Do nothing | Nav-bar swipe, notification shade, call HUD — app is still visible |
| `AppLifecycleState.paused` | `suspendCamera()` | App is genuinely backgrounded |
| `AppLifecycleState.hidden` | `suspendCamera()` | Covered by another window |
| `AppLifecycleState.resumed` | `resumeCamera()` if intent=true AND not route-obscured | Back in foreground |
| `RouteAware.didPushNext()` | `suspendCamera()` | Settings / Tutorial pushed on top |
| `RouteAware.didPopNext()` | `resumeCamera()` if intent=true | Returned from Settings / Tutorial |

**Gesture map (when `gesturalNavigation` is enabled):**

| Gesture | Condition | Action |
|---|---|---|
| Swipe right | `ax ≥ ay`, velocity ≥ 300 px/s, not too diagonal | Open Settings |
| Swipe left | Same | Open Tutorial |
| Swipe up | `ay > ax`, velocity ≥ 300 px/s, `dy < 0` | Toggle flashlight |
| Double-tap | Camera open | Freeze / unfreeze preview |

**Anti-diagonal guard:** The ratio `ay/ax > 0.55` (cross-ratio) rejects swipes that are too diagonal. This prevents accidental navigation when the user is swiping vertically through content on the scanner overlay.

---

#### `scanner/presentation/widgets/camera_viewfinder.dart` — `CameraViewfinder`

**Purpose:** Animated rounded-rectangle frame drawn around the camera preview.

**Visual states:**

| `ScannerState` | Border colour | Animation |
|---|---|---|
| `idle` / `previewing` | Muted grey | Static |
| `scanning` | `accentYellow` | Pulsing opacity (800ms cycle) |
| `processing` | `accentBlue` | Pulsing opacity (800ms cycle) |
| `result` | `success` green | Static (solid) |

**Glow effect:** During `scanning` and `processing` states, a `BoxShadow` in the border colour creates an outward glow whose opacity is driven by the same animation as the border. The glow is removed in idle/result states.

**Layout technique:** The border is applied to an *outer* container and the camera preview is clipped inside an *inner* `ClipRRect` with `radius - borderWidth`. This prevents the border from being clipped by the screen edge and ensures the content never overlaps the border.

---

### Feature: `settings/`

---

#### `settings/domain/entities/app_settings.dart` — `AppSettings`

**Purpose:** Immutable value object representing the complete user preferences state.

**Design principles:**
- **Pure Dart** — no Flutter, no Riverpod imports. Serialisable to JSON for `SharedPreferences` persistence.
- **`copyWith` pattern** — all 13 fields are nullable in `copyWith`, so callers only specify what changes. This is the standard Flutter immutable update pattern.
- **Computed properties** — `flutterThemeMode` converts the app's `AppThemeMode` enum to Flutter's `ThemeMode`, and `isTagalog` provides a bool shortcut used extensively in `AppLocalizations.of()` calls.
- **Sensible defaults** — `denominationVibration: true`, `shakeToGoBack: true`, `gesturalNavigation: true` reflect the primary use case (visually impaired users) rather than a sighted default.

**Enums defined here:**
- `AppThemeMode` — `system`, `light`, `dark`
- `AppLanguage` — `english`, `tagalog`
- `VisionProfile` — `lowVision`, `partiallyBlind`, `fullyBlind`

---

#### `settings/presentation/providers/settings_provider.dart` — `AppSettingsNotifier`

**Purpose:** Riverpod notifier that owns `AppSettings` mutation and will own `SharedPreferences` persistence.

**Pattern:** Every setting has a dedicated mutator method (e.g., `setThemeMode`, `toggleFlashlight`). No widget ever calls `state = ...` directly. This keeps all state transitions named, auditable, and testable.

**Timer toggle logic:** `toggleGoBackTimer` remembers the last non-zero value in a private `_lastTimerSeconds` field so that turning the timer back on restores the previously chosen value rather than defaulting to zero.

**Pending:** `SharedPreferences` persistence. The `build()` method currently returns `const AppSettings()`. It should load from disk and `save()` should be called in each mutator.

---

#### `settings/presentation/screens/settings_screen.dart` — `SettingsScreen`

**Purpose:** Full settings UI, organised into four sections: General, Scanning, Navigation, Help & Support.

**Sections and their widgets:**

| Section | Widgets used |
|---|---|
| General | `_ThemeTile` (custom), `_LanguageTile` (custom), `MsSliderTile` |
| Scanning | `MsToggleTile` (×3, one with help button → denomination tutorial) |
| Navigation | `MsToggleTile` (×3, two with help buttons → shake / gestural tutorials), `MsTimerTile` |
| Help & Support | `MsActionTile` (×5) |

**Help buttons:** The three `showHelpButton: true` tiles open full interactive tutorials via `TutorialNavigator.push(context, TutorialRoute.*)`. The old `AlertDialog`-based `_showHelp()` has been removed.

**`_SwipeBackWrapper`:** A `GestureDetector` around the whole screen that pops on a rightward swipe. This mirrors how Settings is opened (swipe right from scanner → settings slides in from left; swipe right again → pop back to scanner).

---

### Feature: `tutorial/`

---

#### `tutorial/domain/tutorial_route.dart` — `TutorialRoute`

**Purpose:** Enum identifying every available feature tutorial.

**Values:** `denominationVibration`, `shakeToGoBack`, `gesturalNavigation`

**Extension point:** Adding a new tutorial requires only: (1) adding a value here, and (2) adding a `case` in `TutorialNavigator._buildScreen()`. All animation, back-gesture, and scaffold behaviour is inherited automatically.

---

#### `tutorial/presentation/screens/tutorial_navigator.dart` — `TutorialNavigator`

**Purpose:** Single entry point for pushing any feature tutorial.

**`TutorialNavigator.push(context, route)`:**
- Maps `TutorialRoute` → widget via `_buildScreen()`
- Applies a **slide-up** transition (from bottom) — distinct from the horizontal slides used for main screens, giving the tutorial a "detail sheet" feel
- `maybeFuture` typed so callers can `await` if they need to react to dismissal

**Why a static helper instead of a routing table:** The tutorials are always pushed imperatively (from help buttons and tutorial cards, never from a URL or deep link). A static method is simpler and more explicit than a route map for this use case.

---

#### `tutorial/presentation/screens/tutorial_screen.dart` — `TutorialScreen`

**Purpose:** The main Tutorial hub screen, accessible from the bottom nav.

**Contents:** A `ListView` with section labels (Scanning, Navigation) and `_TutorialCard` widgets for each available tutorial. Each card shows the feature icon, title, description, and a chevron. Tapping pushes the tutorial via `TutorialNavigator.push()`.

**`_SwipeBackWrapper`:** Pops on a **rightward** swipe — Tutorial slides in from the right, so the reverse gesture (swipe right) is the natural back motion. Note: this is the opposite direction from Settings.

---

#### `tutorial/presentation/screens/denomination_vibration_tutorial.dart` — `DenominationVibrationTutorial`

**Purpose:** Interactive tutorial teaching the vibration pattern for all 10 Philippine denominations.

**Vibration pattern encoding:**

| Type | Pattern |
|---|---|
| Coins | 1 long pulse (350ms) + N short pulses (100ms each, 120ms apart), 300ms gap between groups |
| Bills | N short pulses (100ms each, 120ms apart) |

| Denomination | Pattern | Description |
|---|---|---|
| ₱1 Coin | ▬ · | 1 long, 1 short |
| ₱5 Coin | ▬ · · | 1 long, 2 short |
| ₱10 Coin | ▬ · · · | 1 long, 3 short |
| ₱20 Coin | ▬ · · · · | 1 long, 4 short |
| ₱20 Bill | · | 1 short |
| ₱50 Bill | · · | 2 short |
| ₱100 Bill | · · · | 3 short |
| ₱200 Bill | · · · · | 4 short |
| ₱500 Bill | · · · · · | 5 short |
| ₱1000 Bill | · · · · · · | 6 short |

**Interactive components:**
- `_VibrationHero` — animated icon with ripple rings (idle loop)
- `_PatternList` — scrollable card list matching the screenshot design. Yellow left-edge pill for coins, blue for bills. `_PatternDots` renders each pattern as pill-shaped bars (wide = long, narrow = short) that animate to full yellow during playback.
- `_playDemo()` plays all 10 patterns in sequence with 400ms gaps
- Playback state prevents double-triggering; `dispose()` cancels any in-progress vibration

---

#### `tutorial/presentation/screens/shake_tutorial.dart` — `ShakeTutorial`

**Purpose:** Interactive tutorial for Shake to Go Back, with a live shake detector.

**Live detection:** Takes over `shakeServiceProvider` on `initState`, registering `_onShake` as the callback. On `dispose`, stops the service (the `ShakeDetectorWidget` in the app root will restart it on the next frame if the setting is enabled).

**Interactive zone (`_ShakeDemo`):** `AnimatedContainer` that transitions to a blue-highlighted state on shake detection. Shows a running shake count. Resets after 600ms.

**Hero (`_ShakeHero`):** Phone graphic that floats gently (sine wave animation) at idle. On shake, adds horizontal offset and glows blue with a checkmark overlay.

---

#### `tutorial/presentation/screens/gestural_navigation_tutorial.dart` — `GesturalNavigationTutorial`

**Purpose:** Interactive tutorial for gestural navigation with live swipe detection.

**Hero (`_GestureHero`):** An animated phone that cycles through all three gesture types every 2 seconds. Each gesture fires an `AnimationController` that slides an arrow out in the gesture direction while fading it out — showing the motion direction clearly.

**Interactive zone (`_GesturePlayground`):** A `GestureDetector` pad that detects real swipes using the same velocity and cross-ratio logic as `ScannerScreen`. Correctly detected swipes animate the pad background and display the corresponding action. A legend below permanently documents all three gestures.

---

#### `tutorial/presentation/widgets/ms_tutorial_scaffold.dart` — `MsTutorialScaffold`

**Purpose:** Shared layout scaffold for all feature tutorials.

**Layout zones:**

| Zone | Height | Content |
|---|---|---|
| Hero | 260px fixed | Animated illustration — passed in as `Widget hero` |
| Content | Scrollable | Badge chip, title, description, numbered steps, interactive widget |

**`_StepRow`:** Renders a numbered yellow circle (using `accentColor`) alongside step text. The number is always dark (`darkBackground`) regardless of theme, ensuring contrast against the yellow.

**Parameters:**
- `title` — used in both the AppBar and the content heading
- `badge` — category label shown as a small outlined chip (e.g., "NAVIGATION", "SCANNING")
- `accentColor` — drives badge, step numbers, and interactive accents; defaults to `accentYellow`; shake tutorial uses `accentBlue`

---

## 9. Layer Reference — `shared/`

All shared widgets follow these invariants:
- Named with the `Ps` prefix
- Accept no Riverpod references — all data is passed via constructor parameters
- Handle their own TalkBack semantics independently
- Adapt to `isDark` via `Theme.of(context).brightness`

---

### `ms_action_tile.dart` — `MsActionTile`

**Purpose:** Tappable settings row with a leading icon container, title/subtitle, and trailing chevron.

**Used for:** Help & Support section items (Check for Updates, App Information, etc.)

**TalkBack:** Single `Semantics(button: true, label: 'Title. Subtitle', excludeSemantics: true)` node.

---

### `ms_bottom_nav.dart` — `MsBottomNav`

**Purpose:** Three-button navigation bar at the bottom of the home screen.

**Layout:** Three `Expanded` buttons in a `Row`, all equal width. The center button (Scan/Stop) uses a pill shape; side buttons use a rounded rectangle.

**Colour encoding:** Settings and Tutorial buttons are always **yellow** (primary). Scan/Stop is always **blue** (action). `iconColor` for yellow buttons is `darkBackground` (near-black) for contrast.

**Glow:** Each button has a `BoxShadow` in its own colour. The shadow intensifies when `isSelected` is true.

---

### `ms_section_header.dart` — `MsSectionHeader`

**Purpose:** Small uppercased category label placed above a `MsSettingsCard`.

**Style:** 12sp, weight 600, letter-spacing 0.8, `onSurfaceVariant` colour — deliberately subdued so it doesn't compete with tile content.

---

### `ms_segmented_selector.dart` — `MsSegmentedSelector<T>`

**Purpose:** Pill-style multi-option selector (Theme: System/Light/Dark, Language: English/Tagalog).

**Overflow protection:** Labels use `MediaQuery.withNoTextScaling` inside each pill. The pill is a fixed-size UI element — it cannot grow with font scale without breaking layout. The surrounding tile *label* (e.g., "Theme") still scales. Labels use `Flexible` + `TextOverflow.ellipsis` + `maxLines: 1` as a safety net.

**Active colour:** Always `accentYellow` on both themes. Active text uses `lightOnSurface` (dark) for contrast against yellow.

**TalkBack:** Each option is a separate `Semantics(button: true, selected: isSelected, excludeSemantics: true)` node so TalkBack announces selected state per option.

---

### `ms_settings_card.dart` — `MsSettingsCard`

**Purpose:** Rounded container that groups related settings tiles with dividers.

**Critical design decision:** Does NOT wrap children in `Semantics` containers. This was the root cause of the help button inaccessibility bug — a `Semantics(container: true)` wrapper around a tile + its help button merged them into one focus stop, hiding the help button from TalkBack linear navigation. Each child widget is responsible for its own semantics boundaries.

Dividers are wrapped in `ExcludeSemantics`.

---

### `ms_toggle_tile.dart` — `MsToggleTile`

**Purpose:** Settings row with a switch toggle and an optional help button.

**TalkBack structure — two independent nodes:**

1. `Semantics(label: 'Title. Subtitle. Switch, on/off', toggled: value, container: true, excludeSemantics: true)` — the entire tile minus the help button. Double-tap activates the switch.
2. `Semantics(label: 'Help for Title', button: true, container: true, excludeSemantics: true)` — the help button, only present when `showHelpButton: true`.

**`container: true` on both nodes** creates hard semantic boundaries, preventing TalkBack from merging the tile and help button into a single focus stop. This is the fix for the help button inaccessibility.

---

### `ms_timer_tile.dart` — `MsTimerTile`

**Purpose:** Toggle tile combined with a tappable duration badge (used for "Go Back Timer on Result").

**TalkBack structure — two independent nodes:**

1. Tile node (same pattern as `MsToggleTile`, `container: true`)
2. Badge node — `Semantics(label: 'Timer value: N seconds. Tap to change.', button: enabled, container: true, excludeSemantics: true)` — only focusable when enabled

The badge taps open a bottom-sheet picker for selecting the timer duration in seconds.

---

### `ms_slider_tile.dart` — `MsSliderTile`

**Purpose:** Settings row with a labelled slider and ± step buttons for coarser adjustment.

**`_StepButton`:** Always yellow, always dark icon — the class was renamed from `_RoundButton` to `_StepButton` to distinguish from the bottom nav's `_EqualButton`.

**TalkBack structure — four nodes:**

1. Heading — `Semantics(header: true, label: 'Title. Subtitle. Currently: N%', excludeSemantics: true)`
2. Decrease — `Semantics(label: 'Decrease Title', button: true, excludeSemantics: true)`
3. Slider — `Semantics(label: 'Title: N%, slider: true)` — Flutter's native slider semantics provide additional swipe-to-adjust behaviour for free
4. Increase — `Semantics(label: 'Increase Title', button: true, excludeSemantics: true)`

---

## 10. State Management Patterns

### Intent vs hardware state

The camera uses a two-provider pattern that separates *user intent* from *hardware reality*:

```
cameraOpenProvider (bool)         — what the user wants
cameraControllerProvider (CameraController?) — what hardware is doing
```

This separation is essential for lifecycle management. The user's intent must survive background/foreground cycles and navigation pushes. The hardware controller must be released whenever the app loses foreground. Reading both together: "if `cameraOpen` is true and `controller` is null, a resume is in progress."

### Settings as a single atom

All 13 settings fields live in one `AppSettings` value object under `appSettingsProvider`. This means:

- One provider subscription instead of 13
- `copyWith` updates are atomic — no partial state inconsistency
- The whole settings object can be serialised to `SharedPreferences` in one write

The tradeoff is that widgets subscribing to `appSettingsProvider` will rebuild when *any* setting changes. Use `.select()` when a widget only cares about one field:

```dart
final shakeEnabled = ref.watch(
  appSettingsProvider.select((s) => s.shakeToGoBack),
);
```

### Provider ownership

| Provider | Owner | Reason |
|---|---|---|
| `availableCamerasProvider` | `camera_service.dart` | Closest to the hardware |
| `cameraControllerProvider` | `camera_service.dart` | Manages the hardware object |
| `cameraOpenProvider` | `scanner_provider.dart` | Intent lives with the state machine |
| `scannerStateProvider` | `scanner_provider.dart` | State machine |
| `detectionResultProvider` | `scanner_provider.dart` | Result of scanning |
| `appSettingsProvider` | `settings_provider.dart` | Settings domain |
| `routeObserverProvider` | `scanner_screen.dart` | Primary consumer |
| `shakeServiceProvider` | `shake_service.dart` | Close to the hardware service |

---

## 11. Navigation Model

MoneySense uses a **hybrid navigation model**: imperative `Navigator.push()` for the main screens and a static helper (`TutorialNavigator`) for tutorials.

### Slide direction convention

The swipe gestures that trigger navigation are spatial — swipe right reveals a screen on the left. The screen transition mirrors this:

| Destination | Triggered by | Transition |
|---|---|---|
| Settings | Swipe right on scanner | Slide in from left |
| Tutorial | Swipe left on scanner | Slide in from right |
| Feature Tutorial | Tap help button or tutorial card | Slide up from bottom |

### Back gesture convention

Each screen that is pushed has a `_SwipeBackWrapper` that mirrors the opening gesture:

| Screen | Back gesture |
|---|---|
| Settings | Swipe right (came from right, go back right) |
| Tutorial | Swipe right (entered from right, swipe right to reverse) |
| Feature Tutorials | No wrapper — standard back button or `maybePop()` |

### `RouteAware` pattern

`ScannerScreen` subscribes to `routeObserverProvider` via the `RouteAware` mixin. This gives it `didPushNext()` and `didPopNext()` callbacks that fire when another route is pushed on top or popped — enabling precise camera suspend/resume without polling.

---

## 12. Accessibility Architecture

Accessibility is not a layer — it is a concern threaded through every widget and system design decision.

### TalkBack semantics strategy

Every interactive widget in `shared/widgets/` owns and controls its own semantics tree. The strategy is **explicit suppression** rather than relying on Flutter's automatic merging:

1. Composite tiles use `excludeSemantics: true` on their top-level `Semantics` node to suppress all descendant nodes (Switch, Icon, Text) from creating duplicate focuses.
2. Interactive elements that must be separate focuses (tile + help button, tile + timer badge) use `container: true` on each to create hard semantic boundaries.
3. `ExcludeSemantics` wraps decorative elements (dividers, icons inside labelled containers).

### Font scaling (WCAG 1.4.4)

The `fontScale` setting (0.8–2.0) is injected at the root via `MediaQuery` override in `app.dart`. All text in the app is therefore scaled without any widget needing to know about it. The segmented selector pills opt out via `MediaQuery.withNoTextScaling` because they are fixed-size UI chrome that cannot accommodate scaling without layout overflow.

### Vibration as primary output

For fully blind users, vibration is not a secondary feedback channel — it is the primary denomination output. The `denominationVibration` system provides 10 distinct tactile patterns that can be learned and relied upon without any screen interaction. The tutorial for this feature is also accessible to all user types via the same vibration playback.

---

## 13. Camera Lifecycle

The camera lifecycle is one of the most complex parts of the app due to the interaction between Android lifecycle events, route changes, and the flash-persistence bug discovered during development.

### The `inactive` problem

`AppLifecycleState.inactive` fires not just when the app backgrounds, but also when:
- The user swipes down the notification shade
- The user swipes up the navigation bar
- An incoming call HUD appears
- Any system UI overlays the app

Killing the camera on `inactive` causes the flashlight to turn off whenever the user pulls down the navigation bar — even while still on the scanner screen. The fix is to explicitly ignore `inactive` and only release hardware on `paused` or `hidden`.

### Route vs lifecycle

`WidgetsBindingObserver` alone cannot distinguish between "app is backgrounded" and "a route was pushed on top of this screen". The `RouteAware` mixin provides `didPushNext()` / `didPopNext()` callbacks that are route-specific. The combination of both:

- `WidgetsBindingObserver` handles real app lifecycle (background/foreground)
- `RouteAware` handles navigation within the app

### `_routeObscured` flag

A boolean `_routeObscured` prevents a race condition where the camera might restart prematurely. On `didPushNext()`, the flag is set to true. On `AppLifecycleState.resumed`, the camera only restarts if `!_routeObscured`. This prevents a double-resume when the user puts the app into the background while Settings is open and then returns.

---

## 14. Tutorial System

The tutorial system is designed to be **zero-boilerplate extensible**. Adding a new tutorial requires exactly three edits:

1. Add a value to `TutorialRoute` enum
2. Add a `case` in `TutorialNavigator._buildScreen()` returning the new widget
3. Add a `_TutorialCard` to `tutorial_screen.dart` pointing to the new route

Everything else — animation, back gesture, scaffold, badge, steps, hero zone — is inherited from `MsTutorialScaffold`.

### `MsTutorialScaffold` parameters

| Parameter | Type | Purpose |
|---|---|---|
| `title` | `String` | AppBar title and content heading |
| `badge` | `String` | Category chip (e.g. "NAVIGATION") |
| `description` | `String` | One-paragraph explanation |
| `steps` | `List<String>` | 2–4 numbered instructions |
| `hero` | `Widget` | 260px animated illustration (any widget) |
| `interactive` | `Widget?` | Optional live demo zone below steps |
| `accentColor` | `Color` | Badge, step numbers, interactive accents |

### Interactive zone contract

The interactive zone receives no props from the scaffold — it is fully self-contained. It should:
- Be a `StatefulWidget` if it manages live sensor/gesture state
- Call `HapticFeedback.lightImpact()` on successful interaction
- Provide a visual confirmation state (colour change, icon switch) so sighted users get feedback too
- Reset to idle after a short delay (typically 600–1200ms)

---

## 15. Adding New Features

### Adding a new settings toggle

1. Add the field to `AppSettings` with a default value
2. Add a `copyWith` parameter for it in `AppSettings.copyWith()`
3. Add a mutator method to `AppSettingsNotifier`
4. Add a `MsToggleTile` or other tile widget in the relevant section of `settings_screen.dart`
5. If it needs a tutorial, add a `TutorialRoute` value and wire it (see Tutorial System above)

### Adding a new feature screen

1. Create `lib/features/<name>/` with the standard three-layer structure
2. Define domain entities as pure Dart classes in `domain/entities/`
3. Create a Riverpod notifier in `presentation/providers/`
4. Build the screen in `presentation/screens/`
5. Add a push helper in `HomeShell` or `TutorialNavigator` as appropriate
6. Add route constants to `app/routes/routes.dart`

### Adding a new shared widget

1. Create `lib/shared/widgets/ms_<name>.dart`
2. Name the class `Ms<Name>`
3. Accept only plain Dart values (no `WidgetRef`, no providers)
4. Add explicit `Semantics` nodes — do not rely on Flutter's automatic merging
5. Adapt to theme brightness via `Theme.of(context).brightness`

### Adding a new localisation string

1. Add the constant to `en.dart` and `tl.dart` with the same key name
2. Add a getter to `AppLocalizations` that delegates to both
3. Use the getter anywhere via `AppLocalizations.of(settings.isTagalog).yourKey`

---

*Last updated: current development session. This document reflects the actual state of the codebase as implemented — not intended behaviour.*
