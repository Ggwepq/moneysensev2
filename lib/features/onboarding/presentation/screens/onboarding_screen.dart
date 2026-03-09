import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/speech_scripts.dart';
import '../../../../core/services/tts_service.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/domain/entities/vision_config.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

// ---------------------------------------------------------------------------
// OnboardingScreen
// ---------------------------------------------------------------------------
//
// TTS BEHAVIOUR
//   Each step is narrated automatically when it appears.
//   Verbosity is forced to [standard] during onboarding regardless of settings,
//   because this is the first thing a blind user experiences — they need audio
//   even before they've had a chance to configure anything.
//
//   Profile selection: if the user picks partiallyBlind or fullyBlind,
//   TTS is automatically enabled and set to the profile's default verbosity.
//   This means a fully blind user can complete onboarding by audio alone.
//
// STEPS
//   0 — Welcome
//   1 — Vision profile
//   2 — Language

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  VisionProfile _selectedProfile = VisionProfile.lowVision;
  AppLanguage   _selectedLanguage = AppLanguage.english;

  // ── TTS helpers ────────────────────────────────────────────────────────────

  /// During onboarding we always speak at standard+ verbosity.
  /// We force-enable TTS for the narration regardless of the current setting
  /// so first-run blind users hear the instructions.
  void _say(TtsMessage msg) {
    ref.read(ttsServiceProvider).enqueue(
          msg,
          enabled: true,            // always on during onboarding
          currentVerbosity: TtsVerbosity.standard,
        );
  }

  AppLocalizations get _l10n =>
      AppLocalizations.of(_selectedLanguage == AppLanguage.tagalog);

  // ── Step narration ─────────────────────────────────────────────────────────

  void _narrateCurrentStep() {
    switch (_step) {
      case 0:
        _say(OnboardingSpeech.welcome(_l10n));
      case 1:
        _say(OnboardingSpeech.visionStep(_l10n));
      case 2:
        _say(OnboardingSpeech.languageStep(_l10n));
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Narrate the welcome step after the first frame so TTS is initialised.
    WidgetsBinding.instance.addPostFrameCallback((_) => _narrateCurrentStep());
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _nextStep() {
    if (_step < 2) {
      setState(() => _step++);
      // Narrate new step after the frame settles
      WidgetsBinding.instance.addPostFrameCallback((_) => _narrateCurrentStep());
    } else {
      _complete();
    }
  }

  void _complete() {
    final notifier = ref.read(appSettingsProvider.notifier);
    notifier.setVisionProfile(_selectedProfile);
    notifier.setLanguage(_selectedLanguage);

    // Auto-configure TTS based on vision profile so blind users don't have
    // to manually go to Settings to hear the app.
    final config = VisionConfig.from(_selectedProfile);
    if (config.preferAudioPrimary) {
      notifier.toggleTts(true);
      notifier.setTtsVerbosity(config.defaultTtsVerbosity);
    }

    widget.onComplete();
  }

  // ── Profile selection ──────────────────────────────────────────────────────

  void _selectProfile(VisionProfile p) {
    setState(() => _selectedProfile = p);
    // Speak a short confirmation in the current language
    _say(OnboardingSpeech.profileSelected(_l10n));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n   = _l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress dots
              Row(
                children: List.generate(3, (i) => _Dot(active: i == _step)),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Step content
              Expanded(child: _buildStep(l10n, isDark)),

              // Next / Get Started button
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: _step < 2 ? l10n.next : l10n.getStarted,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.base + 4),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                    ),
                    onPressed: _nextStep,
                    child: Text(
                      _step < 2 ? l10n.next : l10n.getStarted,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(AppLocalizations l10n, bool isDark) {
    switch (_step) {
      case 0:
        return _WelcomeStep(l10n: l10n);
      case 1:
        return _VisionStep(
          l10n: l10n,
          selected: _selectedProfile,
          onSelect: _selectProfile,
        );
      case 2:
        return _LanguageStep(
          l10n: l10n,
          selected: _selectedLanguage,
          onSelect: (lang) => setState(() => _selectedLanguage = lang),
        );
      default:
        return const SizedBox();
    }
  }
}

// ── Step Widgets ──────────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.currency_exchange_rounded, size: 72),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.onboardingWelcomeTitle,
              style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: AppSpacing.base),
          Text(l10n.onboardingWelcomeSubtitle,
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      );
}

class _VisionStep extends StatelessWidget {
  const _VisionStep({
    required this.l10n,
    required this.selected,
    required this.onSelect,
  });
  final AppLocalizations l10n;
  final VisionProfile selected;
  final ValueChanged<VisionProfile> onSelect;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboardingVisionTitle,
              style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.onboardingVisionSubtitle,
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xl),
          _ProfileOption(
            label: l10n.visionLowVision,
            icon: Icons.visibility,
            value: VisionProfile.lowVision,
            selected: selected,
            onSelect: onSelect,
          ),
          const SizedBox(height: AppSpacing.md),
          _ProfileOption(
            label: l10n.visionPartiallyBlind,
            icon: Icons.visibility_off_outlined,
            value: VisionProfile.partiallyBlind,
            selected: selected,
            onSelect: onSelect,
          ),
          const SizedBox(height: AppSpacing.md),
          _ProfileOption(
            label: l10n.visionFullyBlind,
            icon: Icons.visibility_off,
            value: VisionProfile.fullyBlind,
            selected: selected,
            onSelect: onSelect,
          ),
        ],
      );
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onSelect,
  });
  final String label;
  final IconData icon;
  final VisionProfile value;
  final VisionProfile selected;
  final ValueChanged<VisionProfile> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value == selected;
    final accent     = isDark ? AppColors.accentYellow : AppColors.accentBlue;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withOpacity(0.15)
                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(
              color: isSelected ? accent : AppColors.darkBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? accent : null),
              const SizedBox(width: AppSpacing.md),
              Text(label,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? accent : null,
                  )),
              const Spacer(),
              if (isSelected) Icon(Icons.check_circle_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageStep extends StatelessWidget {
  const _LanguageStep({
    required this.l10n,
    required this.selected,
    required this.onSelect,
  });
  final AppLocalizations l10n;
  final AppLanguage selected;
  final ValueChanged<AppLanguage> onSelect;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.language,
              style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: AppSpacing.xl),
          _LangOption(
            label: l10n.languageEnglish,
            flag: '🇺🇸',
            value: AppLanguage.english,
            selected: selected,
            onSelect: onSelect,
          ),
          const SizedBox(height: AppSpacing.md),
          _LangOption(
            label: l10n.languageTagalog,
            flag: '🇵🇭',
            value: AppLanguage.tagalog,
            selected: selected,
            onSelect: onSelect,
          ),
        ],
      );
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.label,
    required this.flag,
    required this.value,
    required this.selected,
    required this.onSelect,
  });
  final String label;
  final String flag;
  final AppLanguage value;
  final AppLanguage selected;
  final ValueChanged<AppLanguage> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value == selected;
    final accent     = isDark ? AppColors.accentYellow : AppColors.accentBlue;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withOpacity(0.15)
                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(
              color: isSelected ? accent : AppColors.darkBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.md),
              Text(label,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? accent : null,
                  )),
              const Spacer(),
              if (isSelected) Icon(Icons.check_circle_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Progress Dot ──────────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentYellow : AppColors.accentBlue;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 6),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? accent
            : (isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightBorder),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
