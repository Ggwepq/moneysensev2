# Earcon Sound Guide

The `.wav` files in this folder are **silent placeholders** (300ms of silence).
Replace them with real sounds before shipping. This file explains what each
earcon should sound like and where to find suitable free assets.

---

## Event guide

| File | Event | Recommended character |
|---|---|---|
| `earcon_scan_start.wav` | Scan button pressed, scanner is now looking | Short ascending two-tone blip (~120ms). Signals "ready and listening". |
| `earcon_scan_success.wav` | Denomination identified | Warm rising chime or double-beep (~180ms). Positive, satisfying. |
| `earcon_scan_fail.wav` | Scanner could not identify | Single low-pitched descending tone (~200ms). Neutral, not harsh. |
| `earcon_camera_open.wav` | Camera stream starts | Very soft shutter-click or low blip (~80ms). Subtle. |
| `earcon_camera_close.wav` | Camera stream stops | Inverse of camera open — a soft descending click (~80ms). |

---

## Recommended characteristics (all files)

- **Format**: 44100 Hz, 16-bit, mono WAV or MP3
- **Duration**: Under 300ms for instantaneous events, up to 500ms for results
- **Volume**: Normalize to -12 dBFS so they sit below TTS speech naturally
- **No reverb / tail**: Long tails cause overlap issues with rapid scan events
- **No spoken words**: Earcons are pre-linguistic — they should not say anything

---

## Free asset sources

- **Freesound.org** — CC0 licensed UI sounds. Search "UI blip", "notification chime", "camera click"
- **Google Material Sound Kit** — https://m3.material.io/foundations/interaction/patterns — includes earcon-style sounds designed for accessibility
- **Mixkit** (mixkit.co) — free for commercial use, "Interface" and "Notification" categories
- **BBC Sound Effects** — https://sound-effects.bbcrewind.co.uk — CC BY 4.0, professional quality

---

## Accessibility notes

- EarconService automatically silences all earcons when TalkBack or VoiceOver
  is active. AT has its own earcons; playing over them causes confusion.
- Keep `earcon_scan_success.wav` clearly distinct from `earcon_scan_fail.wav`
  — these are the two most critical signals for blind users.
- Do not use stereo panning effects — users may be wearing only one earbud.
