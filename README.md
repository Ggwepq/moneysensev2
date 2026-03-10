# MoneySense

**A free, offline, bilingual currency identifier for visually impaired Filipinos.**

MoneySense uses your phone's camera to detect Philippine peso bills and coins in real time, then announces the denomination out loud in Filipino or English. It works entirely offline and is built from the ground up for users with low vision, partial blindness, or complete blindness.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Setup](#setup)
- [Contributing](#contributing)
- [Naming Conventions](#naming-conventions)

---

## Features

| Category | Feature | Status |
|---|---|---|
| Scanning | Real-time bill and coin detection | ML wiring pending |
| Scanning | Multi-bill and multi-coin scanning | ML wiring pending |
| Scanning | Front and rear camera support | Done |
| Scanning | Flashlight toggle | Done |
| Scanning | Denomination-specific vibration patterns | Done |
| Audio | Text-to-speech voice guidance | Done |
| Audio | Bilingual support (Filipino and English) | Done |
| Audio | TTS verbosity control | Done |
| Accessibility | Vision profile (Low Vision / Partially Blind / Fully Blind) | Done |
| Accessibility | Contrast-adaptive accent colors per profile | Done |
| Accessibility | Adjustable font size with profile floor | Done |
| Accessibility | TalkBack compatibility | Done |
| Accessibility | Haptic feedback system | Done |
| Navigation | Gestural navigation (swipe left and right) | Done |
| Navigation | Inertial navigation (tilt) | Done |
| Navigation | Shake to go back | Done |
| Navigation | Auto go-back timer after a result | Done |
| UX | 6-page onboarding flow | Done |
| UX | Interactive feature tutorials | Done |
| UX | Settings persistence across sessions | Done |

---

## Architecture

MoneySense follows **feature-first Clean Architecture** with **Riverpod** for state management.

```
lib/
├── main.dart           # App entry point
├── app/                # Root widget and navigation shell
├── core/               # Shared constants, theme, l10n, and services
├── features/           # Self-contained feature slices
│   ├── onboarding/
│   ├── scanner/
│   ├── settings/
│   └── tutorial/
└── shared/             # Reusable UI widgets used across two or more features
```

Each feature owns its own `data/`, `domain/`, and `presentation/` layers so changes to one feature never affect another, and each layer can be tested on its own.

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Flutter 3.19+ | Cross-platform UI framework |
| Dart 3.0+ | Language |
| flutter_riverpod | Reactive state management |
| camera | Camera hardware access and lifecycle management |
| flutter_tts | Text-to-speech output |
| sensors_plus | Accelerometer for shake and tilt detection |
| vibration | Motor vibration for denomination feedback patterns |
| shared_preferences | Persistent settings storage |
| go_router | Named route constants (full integration pending) |
| intl + flutter_localizations | Internationalisation support |
| YOLOv8 | Real-time bill and coin detection model (pending) |
| MobileNet | Authenticity verification model (pending) |

---

## Setup

**Prerequisites**

- Flutter 3.19+ on the stable channel
- Android SDK (API level 24 or higher)
- A physical Android device is recommended for camera and sensor testing

**Install and run**

```bash
flutter pub get
flutter run
```

**Build a release APK**

```bash
flutter build apk --release
```

---

## Contributing

1. New features belong in `lib/features/<feature_name>/` with the standard `data/`, `domain/`, and `presentation/` structure.
2. Shared UI components go in `lib/shared/widgets/` and use the `Ms` prefix.
3. Every user-facing string must be added to both `lib/core/l10n/en.dart` and `tl.dart`.
4. New settings fields go into `AppSettings` first, then `AppSettingsNotifier`.
5. Never hardcode accent colors. Use `VisionConfig.accent(isDark)` so contrast boosts from the vision profile apply automatically everywhere.

---

## Naming Conventions

| Pattern | Meaning |
|---|---|
| `Ms*` | MoneySense shared widget, e.g. `MsToggleTile` |
| `App*` | App-wide constant or theme class, e.g. `AppColors` |
| `*Screen` | Full-page screen widget |
| `*Provider` | Riverpod provider file |
| `*Notifier` | Riverpod notifier class |
| `*Service` | Stateless platform abstraction |
| `*Tutorial` | Interactive feature tutorial widget |
