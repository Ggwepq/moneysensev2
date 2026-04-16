# MoneySense

**A free, offline, bilingual currency identifier for visually impaired Filipinos.**

MoneySense uses your phone's camera to detect Philippine Peso bills and coins in real time, then announces the denomination out loud in Filipino or English. It works entirely offline, processes everything on-device, and is built from the ground up for users with low vision, partial blindness, or complete blindness.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Codebase Overview](#codebase-overview)
- [Getting the App](#getting-the-app)
- [Building from Source](#building-from-source)
- [Contributing](#contributing)
- [Naming Conventions](#naming-conventions)

---

## Overview

In the Philippines, cash is still the dominant payment method for everyday transactions. For the estimated 2.5 million visually impaired Filipinos, identifying currency accurately is a persistent daily challenge. MoneySense was built to fill the gap left by existing apps — which typically scan only one bill at a time, require internet, and offer no Filipino-language audio.

**For detailed system and feature documentation, see [SYSTEM.md](./SYSTEM.md).**

---

## Features

| Category | Feature |
|---|---|
| **Scanning** | Real-time bill and coin detection (YOLOv8-Nano on-device) |
| **Scanning** | Multi-stage authenticity verification (ResNet-18 + Siamese + OCR) |
| **Scanning** | Front and rear camera support |
| **Scanning** | Flashlight toggle |
| **Scanning** | Denomination-specific vibration patterns |
| **Audio** | Text-to-speech voice guidance with priority queue |
| **Audio** | Bilingual support (Filipino and English) |
| **Audio** | TTS verbosity control (Minimal / Standard / Full) |
| **Audio** | Non-speech earcon audio cues |
| **Accessibility** | Vision profile (Low Vision / Partially Blind / Fully Blind) |
| **Accessibility** | Contrast-adaptive accent colors per profile |
| **Accessibility** | Adjustable font size with profile floor |
| **Accessibility** | TalkBack compatibility with explicit semantics |
| **Accessibility** | Haptic feedback system (3 intensity levels) |
| **Navigation** | Gestural navigation (swipe left and right) |
| **Navigation** | Inertial navigation (tilt) |
| **Navigation** | Shake to go back |
| **Navigation** | Auto go-back timer after a result |
| **Navigation** | Voice commands ("Hey MoneySense") — bilingual |
| **UX** | 6-page onboarding flow |
| **UX** | Interactive feature tutorials with live sensor input |
| **UX** | Settings persistence across sessions |
| **UX** | Share MoneySense via QR code |

---

## Architecture

MoneySense follows **feature-first Clean Architecture** with **Riverpod** for state management.

```
lib/
├── main.dart           App entry point (pre-flight setup & DI bootstrap)
├── app/                Root widget, navigation shell, route constants
├── core/               Shared constants, theme, l10n, and platform services
├── features/           Self-contained feature slices
│   ├── onboarding/     First-launch flow
│   ├── scanner/        Camera + ML pipeline + result display
│   ├── settings/       Preferences, vision profiles, persistence
│   └── tutorial/       Interactive feature walkthroughs
└── shared/             Reusable UI widgets used across ≥2 features
```

Each feature owns its own `data/`, `domain/`, and `presentation/` layers so changes to one feature never affect another, and each layer can be tested independently.

```
features/<name>/
├── data/         Platform & storage access
├── domain/       Pure Dart entities & enums (no Flutter imports, fully testable)
└── presentation/ Providers (state logic) + screens + widgets
```

See [SYSTEM.md → Architecture Overview](./SYSTEM.md#3-architecture-overview) for the full rationale behind these design choices.

---

## Codebase Overview

| File / Folder | Responsibility |
|---|---|
| `main.dart` | Pre-flight: initializes SharedPreferences, camera list, and haptics before the first frame. Injects them via `ProviderScope.overrides`. |
| `app/app.dart` | Root `MaterialApp`. Applies font scale globally via `MediaQuery` override. Initializes TTS. |
| `app/home_shell.dart` | Persistent home `Scaffold`. Manages bottom nav, voice command engine lifecycle, and onboarding exit flow. |
| `core/services/tts_service.dart` | Priority-queued TTS engine. Handles TalkBack coexistence, debouncing, and language switching. |
| `core/services/haptic_service.dart` | Vibration & HapticFeedback control. Three intensity levels, denomination-specific patterns. |
| `core/services/inertial_service.dart` | Tilt navigation from accelerometer. Includes flat-guard, dominance margin, hold timer, and cooldown. |
| `core/services/shake_service.dart` | Shake-to-go-back. Requires two confirmed jolts to reject incidental motion. |
| `core/services/voice/` | Full voice command pipeline: `VoiceCommandService` (STT) → `VoiceIntentParser` → `VoiceCommandExecutor`. |
| `core/l10n/en.dart` + `tl.dart` | All user-facing strings in English and Tagalog. |
| `features/scanner/data/datasources/camera_service.dart` | Camera hardware lifecycle. Separate `suspend` and `close` methods for correct resume-after-background behavior. |
| `features/scanner/data/datasources/authenticity_service.dart` | Multi-stage verification: ResNet-18 classifier + Siamese feature extractor + Google ML Kit OCR. Consensus engine. |
| `features/scanner/presentation/providers/scanner_provider.dart` | `cameraOpenProvider` (intent) and `scannerStateProvider` (current hardware state). |
| `features/settings/domain/entities/app_settings.dart` | Immutable value object holding all 18 user preferences. |
| `features/settings/domain/entities/vision_config.dart` | Computed from `VisionProfile`. Single source of truth for contrast, font floor, TTS defaults, and accent colors. |
| `features/settings/presentation/providers/settings_provider.dart` | Riverpod notifier. All mutations go through named methods; persists on every change. |
| `features/tutorial/` | Tutorial hub, `TutorialNavigator`, `MsTutorialScaffold`, and 5 interactive tutorials. |
| `shared/widgets/` | Reusable `Ms*` components: toggle tiles, slider tiles, segmented selectors, settings cards, bottom nav. |

For a full file-by-file reference, see [CODEBASE.md](./CODEBASE.md).

---

## Getting the App

### Option 1 — GitHub Releases

Download the latest APK directly from the [Releases page](../../releases/latest).

1. Open the **Releases** page on this repository.
2. Under the latest release, download `moneysense-universal.apk`.
3. Install it on your Android device (you may need to allow installs from unknown sources in your device settings).

### Option 2 — Share MoneySense QR Code

Inside the MoneySense app itself, go to **Settings → Share MoneySense**. This displays a QR code that links directly to the latest APK download. Scan it with any QR reader to download immediately — no searching required.

> [!NOTE]
> MoneySense is an Android-only application. A physical Android device running **API level 24 (Android 7.0)** or higher is required.

---

## Building from Source

**Prerequisites**

- Flutter 3.19+ on the stable channel
- Android SDK (API level 24 or higher)
- A physical Android device is strongly recommended for camera and sensor testing

**Install dependencies and run**

```bash
flutter pub get
flutter run
```

**Build a release APK**

```bash
flutter build apk --release
```

**Build a universal APK (all ABIs, larger but compatible with all devices)**

```bash
flutter build apk --release --split-per-abi
# or for a single universal file:
flutter build apk --release
```

---

## Contributing

1. **New features** belong in `lib/features/<feature_name>/` with the standard `data/`, `domain/`, and `presentation/` structure.
2. **Shared UI components** go in `lib/shared/widgets/` and must use the `Ms` prefix.
3. **Every user-facing string** must be added to both `lib/core/l10n/en.dart` and `tl.dart` with the same key name.
4. **New settings fields** go into `AppSettings` first, then `AppSettingsNotifier`. Never add a setting without a corresponding persistence key in `SettingsStorage`.
5. **Never hardcode accent colors.** Use `VisionConfig.accent(isDark)` so contrast boosts from the vision profile apply automatically everywhere.
6. **Never write state directly** to a Riverpod provider from a widget. All mutations go through named methods on the notifier.

### Document Structure

| File | Purpose |
|---|---|
| `README.md` | Project overview, installation, and contribution guide (this file) |
| `SYSTEM.md` | Full system and feature documentation |
| `ARCHITECTURE.md` | Architecture rationale and design decisions |
| `CODEBASE.md` | File-by-file codebase reference |
| `SCANNING.md` | Deep-dive into the ML identification and verification pipeline |

---

## Naming Conventions

| Pattern | Meaning | Example |
|---|---|---|
| `Ms*` | MoneySense shared widget | `MsToggleTile`, `MsBottomNav` |
| `App*` | App-wide constant or theme class | `AppColors`, `AppSpacing` |
| `*Screen` | Full-page screen widget | `ScannerScreen`, `ResultScreen` |
| `*Provider` | Riverpod provider file | `settingsProvider` |
| `*Notifier` | Riverpod notifier class | `AppSettingsNotifier` |
| `*Service` | Stateless platform abstraction | `TtsService`, `HapticService` |
| `*Tutorial` | Interactive feature tutorial widget | `ShakeTutorial` |

---

*MoneySense © 2026 · Built for accessibility-first Filipino users · All identification is performed on-device; no camera data ever leaves the phone.*
