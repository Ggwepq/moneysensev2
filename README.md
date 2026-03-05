# PesoSense 🇵🇭

**An accessible, bilingual Philippine currency identifier for visually impaired users.**

---

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Features](#features)
- [Getting Started](#getting-started)
- [Contributing](#contributing)

---

## Overview

PesoSense uses real-time camera-based ML inference to identify and announce Philippine bills and coins. It is built with accessibility at the core — every feature is designed for users with low vision, partial blindness, or full blindness.

---

## Architecture

The project follows a **feature-first Clean Architecture** pattern, combined with **Riverpod** for state management.

```
Presentation  →  Domain  →  Data
  (UI/Riverpod)   (entities,   (repos,
                  use cases)   datasources)
```

Each feature is fully self-contained: `data`, `domain`, and `presentation` layers live inside the feature folder. Shared UI components live in `lib/shared/widgets/`.

### State Management

[Riverpod](https://riverpod.dev/) is used throughout:
- `NotifierProvider` — for complex mutable state (settings, scanner)
- `StateProvider` — for simple boolean/primitive state (camera open)

### Theming

Material 3 `ThemeData` is used. Both `light` and `dark` themes are defined in `lib/core/theme/app_theme.dart` and driven by the `AppSettings.themeMode` setting.

### Localisation

A lightweight, hand-written localisation layer (`AppLocalizations`) supports English and Tagalog. This can be migrated to ARB/gen_l10n in a later sprint.

---

## Project Structure

```
lib/
├── main.dart                          # Entry point
├── app/
│   ├── app.dart                       # MaterialApp root
│   ├── home_shell.dart                # Bottom-nav shell
│   └── routes/
│       └── routes.dart                # Named route constants
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Brand & semantic colors
│   │   ├── app_spacing.dart           # 4-pt spacing grid
│   │   └── app_typography.dart        # Text styles
│   ├── theme/
│   │   └── app_theme.dart             # Light & dark ThemeData
│   └── l10n/
│       ├── app_localizations.dart     # Accessor class
│       ├── en.dart                    # English strings
│       └── tl.dart                    # Tagalog strings
│
├── shared/
│   └── widgets/
│       ├── ps_bottom_nav.dart         # 3-button bottom bar
│       ├── ps_settings_card.dart      # Rounded tile group container
│       ├── ps_section_header.dart     # Section label
│       ├── ps_toggle_tile.dart        # Switch row + optional help btn
│       ├── ps_timer_tile.dart         # Switch + numeric counter
│       ├── ps_action_tile.dart        # Tappable icon row
│       ├── ps_segmented_selector.dart # Pill-style 2–3 option selector
│       └── ps_slider_tile.dart        # Slider row with ± buttons
│
└── features/
    ├── onboarding/
    │   └── presentation/screens/
    │       └── onboarding_screen.dart
    ├── scanner/
    │   ├── domain/entities/
    │   │   └── scanner_state.dart     # ScannerState enum, DetectionResult
    │   └── presentation/
    │       ├── providers/
    │       │   └── scanner_provider.dart
    │       ├── screens/
    │       │   └── scanner_screen.dart
    │       └── widgets/
    │           └── camera_viewfinder.dart
    ├── settings/
    │   ├── domain/entities/
    │   │   └── app_settings.dart      # AppSettings value object
    │   └── presentation/
    │       ├── providers/
    │       │   └── settings_provider.dart
    │       └── screens/
    │           └── settings_screen.dart
    └── tutorial/
        └── presentation/screens/
            └── tutorial_screen.dart
```

---

## Features

| Category | Feature | Status |
|---|---|---|
| General | Theme switching (light / dark / system) | ✅ Settings UI |
| General | Bilingual support (English / Tagalog) | ✅ Settings UI |
| General | Font size scaling | ✅ Settings UI |
| Scanning | Front/rear camera toggle | ✅ Settings UI |
| Scanning | Flashlight toggle | ✅ Settings UI |
| Scanning | Denomination-specific vibration | ✅ Settings UI |
| Scanning | Real-time ML scanning | 🔧 Placeholder |
| Navigation | Gestural navigation (swipe) | ✅ Implemented |
| Navigation | Inertial navigation (tilt) | ✅ Settings UI |
| Navigation | Shake to go back | ✅ Settings UI |
| Navigation | Go back timer on result | ✅ Settings UI |
| Accessibility | TTS / voice guidance | 🔧 Placeholder |
| Accessibility | Haptic feedback | 🔧 Placeholder |
| Accessibility | Vision profile onboarding | ✅ Implemented |
| Accessibility | TalkBack compatibility | ✅ Semantics added |
| UX | Onboarding flow | ✅ Implemented |
| UX | Tutorial screen | 🔧 Placeholder |

---

## Getting Started

### Prerequisites
- Flutter 3.19+ (stable channel)
- Android SDK (API 24+)

### Setup
```bash
flutter pub get
flutter run
```

### Build
```bash
flutter build apk --release
```

---

## Contributing

1. Each new feature belongs in `lib/features/<feature_name>/`
2. New shared UI components go in `lib/shared/widgets/` with the `Ps` prefix
3. All strings must be added to both `en.dart` and `tl.dart`
4. New settings fields must be added to `AppSettings` + `AppSettingsNotifier`
5. Follow Material 3 patterns; custom components are named `Ps*`

---

## Naming Conventions

| Prefix | Meaning |
|---|---|
| `Ps` | PesoSense custom widget (e.g. `PsToggleTile`) |
| `App` | App-wide constant/theme (e.g. `AppColors`) |
| `*Screen` | Full-page screen widget |
| `*Provider` | Riverpod provider file |
| `*Notifier` | Riverpod notifier class |
