# Earcon Sound Guide

The `.wav` files in this folder are **silent placeholders**.
Replace them with real sounds before shipping. This file explains what each
earcon should sound like and where to find suitable free assets.

---

## Events and sound recommendations

### Scanner group
| File | Event | Recommended character |
|---|---|---|
| `earcon_scan_start.wav` | Scan button pressed | Short ascending 2-tone blip (~120ms). "Ready and listening." |
| `earcon_scan_success.wav` | Denomination identified | Warm rising chime or double-beep (~180ms). Positive, satisfying. |
| `earcon_scan_fail.wav` | Could not identify | Single low descending tone (~200ms). Neutral, not harsh. |

### Camera group
| File | Event | Recommended character |
|---|---|---|
| `earcon_camera_open.wav` | Camera stream starts | Soft shutter-click or low blip (~80ms). Very subtle. |
| `earcon_camera_close.wav` | Camera stream stops | Inverse of camera open — descending click (~80ms). |

### Navigation group
| File | Event | Triggered by |
|---|---|---|
| `earcon_nav_forward.wav` | Screen pushed onto stack | Bottom nav tap, inertial tilt, swipe gesture, tutorial card tap |
| `earcon_nav_back.wav` | Screen popped | Shake-to-go-back, swipe-back in Settings, Settings back button |

**Recommended character:** navForward = subtle ascending tick (~100ms).
navBack = descending counterpart (~100ms). The pair should sound like "in / out"
or "open / close" — clearly distinct from each other but both understated so
they don't compete with TTS.

### Action group
| File | Event | Triggered by |
|---|---|---|
| `earcon_action_enabled.wav` | Toggle switched ON | Any settings toggle turned on |
| `earcon_action_disabled.wav` | Toggle switched OFF | Any settings toggle turned off |
| `earcon_action_confirmed.wav` | Selection confirmed | Vision profile, language, verbosity, haptic intensity, nav style, onboarding option picks |

**Recommended character:** actionEnabled = short rising click (~100ms).
actionDisabled = short falling click (~100ms). These fire on EVERY toggle —
keep them very subtle so they don't become fatiguing. actionConfirmed =
slightly warmer tick (~150ms), used when a selection from a group is chosen.

---

## Recommended audio characteristics (all files)

- **Format**: 44100 Hz, 16-bit, mono WAV or MP3
- **Duration**: Under 200ms for instantaneous events, up to 300ms for results
- **Volume**: Normalize to −12 dBFS so they sit below TTS speech naturally
- **No reverb/tail**: Long tails overlap with rapid scan events
- **No spoken words**: Earcons are pre-linguistic

---

## Coexistence behaviour

- **TalkBack active**: All earcons silenced automatically. AT uses its own cues.
- **earconEnabled = false**: All plays are no-ops; changed in Settings → Accessibility → Sound Effects.
- **TTS speaking**: Earcons duck under TTS — AudioPlayer and flutter_tts route independently.
- **Two earcons in quick succession**: The second cancels the first via `player.stop()`.

---

## Free asset sources

- **Freesound.org** — CC0 licensed UI sounds. Search "UI blip", "notification chime", "camera click"
- **Google Material Sound Kit** — https://m3.material.io/foundations/interaction/patterns
- **Mixkit** (mixkit.co) — free for commercial use, "Interface" and "Notification" categories
- **BBC Sound Effects** — https://sound-effects.bbcrewind.co.uk — CC BY 4.0, professional quality

## Tips for the nav/action pair

For the 5 navigation and action earcons, consider designing them as a family —
same synthesis style but pitch-shifted variants of a single base sound. This
makes the whole system feel cohesive rather than a collection of random effects.
A single triangle wave blip at different pitches works well:
- navForward: C5 (~523 Hz)
- navBack: A4 (~440 Hz)
- actionEnabled: E5 (~659 Hz)
- actionDisabled: G4 (~392 Hz)
- actionConfirmed: G5 (~784 Hz)
