import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Phase 3: Earcon system.
//
// Earcons are short non-speech audio cues that fire faster than TTS and
// give instant feedback for scanner events without needing a spoken sentence.
//
// Coexistence rules:
//   - When TalkBack/VoiceOver is active: earcons are SILENCED entirely.
//     The AT has its own audio cues; playing over them creates confusion.
//   - When earcons are disabled in Settings: all play() calls are no-ops.
//   - When TTS is speaking: earcons duck under TTS — AudioPlayer streams are
//     independently routed so they do not interrupt the speech engine.
//   - No two earcons overlap: each play() cancels the previous.
//
// PLACEHOLDER NOTE: The WAV files in assets/audio/ are silent stubs (300ms
// silence). Replace them with real sounds before shipping. See EARCON_GUIDE.md
// in assets/audio/ for recommended characteristics per event.

/// All earcon events the app can fire.
///
/// Grouped by category so it is easy to see where each one belongs:
///   Scanner  — scan lifecycle events
///   Camera   — camera open/close
///   Navigation — screen transitions
///   Action   — toggle on, toggle off, action confirmed
enum EarconEvent {
  // ── Scanner ───────────────────────────────────────────────────────────────
  /// The scan button was pressed and the scanner has started looking.
  scanStart,

  /// A denomination was successfully identified.
  scanSuccess,

  /// The scanner gave up without identifying anything.
  scanFail,

  // ── Camera ────────────────────────────────────────────────────────────────
  /// The camera stream started (camera button tapped → camera opens).
  cameraOpen,

  /// The camera stream stopped.
  cameraClose,

  // ── Navigation ────────────────────────────────────────────────────────────
  /// A screen was pushed onto the navigator stack (Settings, Tutorial, etc.).
  navForward,

  /// The user went back (shake, inertial tilt, or back button).
  navBack,

  // ── Scanner ─ extras ──────────────────────────────────────────────────────
  /// The flashlight was toggled via swipe gesture on the scanner screen.
  flashToggled,

  // ── Onboarding ────────────────────────────────────────────────────────────
  /// The user advanced to the next onboarding page (Next button).
  onboardingNext,

  // ── Tutorial ──────────────────────────────────────────────────────────────
  /// A page was turned inside a multi-page tutorial (Next or Back button).
  tutorialPageTurn,

  // ── Action ────────────────────────────────────────────────────────────────
  /// A toggle or feature was switched ON.
  actionEnabled,

  /// A toggle or feature was switched OFF.
  actionDisabled,

  /// A selection was confirmed (segmented selector changed, onboarding step
  /// advanced, form submitted).
  actionConfirmed,
}

extension _EarconAsset on EarconEvent {
  String get assetPath {
    switch (this) {
      case EarconEvent.scanStart:
        return 'audio/earcon_scan_start.wav';
      case EarconEvent.scanSuccess:
        return 'audio/earcon_scan_success.wav';
      case EarconEvent.scanFail:
        return 'audio/earcon_scan_fail.wav';
      case EarconEvent.cameraOpen:
        return 'audio/earcon_camera_open.wav';
      case EarconEvent.cameraClose:
        return 'audio/earcon_camera_close.wav';
      case EarconEvent.flashToggled:
        return 'audio/earcon_action_confirmed.wav';
      case EarconEvent.onboardingNext:
        return 'audio/earcon_nav_forward.wav';
      case EarconEvent.tutorialPageTurn:
        return 'audio/earcon_nav_back.wav';
      case EarconEvent.navForward:
        return 'audio/earcon_nav_forward.wav';
      case EarconEvent.navBack:
        return 'audio/earcon_nav_back.wav';
      case EarconEvent.actionEnabled:
        return 'audio/earcon_action_enabled.wav';
      case EarconEvent.actionDisabled:
        return 'audio/earcon_action_disabled.wav';
      case EarconEvent.actionConfirmed:
        return 'audio/earcon_action_confirmed.wav';
    }
  }
}

class EarconService {
  EarconService._();
  static final EarconService instance = EarconService._();

  // Single player — stops the previous earcon before playing the next.
  // We use a low-latency mode to keep the gap between events and sound tight.
  final AudioPlayer _player = AudioPlayer();

  bool _enabled = true;
  bool _talkBackActive = false;

  static const MethodChannel _accessibilityChannel = MethodChannel(
    'flutter/accessibility',
  );

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _player.setPlayerMode(PlayerMode.lowLatency);
    await _player.setReleaseMode(ReleaseMode.stop);
    await _detectTalkBack();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  // ── Configuration ─────────────────────────────────────────────────────────

  /// Called by the earcon settings toggle. When false, all play() calls
  /// become no-ops immediately.
  void setEnabled(bool value) {
    _enabled = value;
  }

  /// Called after TTS re-init so the earcon service stays in sync with the
  /// accessibility state of the device.
  Future<void> refreshTalkBackState() async {
    await _detectTalkBack();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Play an earcon for [event].
  ///
  /// Silently dropped if:
  ///   - earcons are disabled in settings ([_enabled] = false), or
  ///   - TalkBack / VoiceOver is active ([_talkBackActive] = true).
  Future<void> play(EarconEvent event) async {
    if (!_enabled) return;
    if (_talkBackActive) return;

    try {
      // Stop any in-flight earcon before starting the next one.
      await _player.stop();
      await _player.play(AssetSource(event.assetPath));
    } catch (e) {
      debugPrint('[EarconService] play error (${event.name}): $e');
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _detectTalkBack() async {
    try {
      final result = await _accessibilityChannel.invokeMethod<bool>(
        'isAccessibilityServiceEnabled',
      );
      _talkBackActive = result ?? false;
    } catch (_) {
      _talkBackActive = false;
    }
  }
}
