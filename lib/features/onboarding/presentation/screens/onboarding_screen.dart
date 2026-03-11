import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/speech_scripts.dart';
import '../../../../core/services/tts_service.dart';
import '../../../scanner/data/datasources/camera_service.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/domain/entities/vision_config.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

// 6-page onboarding flow shown on first launch. The user picks their vision
// profile, language, and navigation preferences before entering the app.
// Accent colors update live as the profile is selected on page 1.

enum _NavStyle { standard, gestural, inertial }
enum _PermStatus { unknown, requesting, granted, denied }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final void Function({bool launchTutorial}) onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _total = 6;

  final _pageCtrl = PageController();
  int _page = 0;

  VisionProfile _profile  = VisionProfile.lowVision;
  AppLanguage   _language = AppLanguage.english;
  _NavStyle     _nav      = _NavStyle.standard;
  _PermStatus   _perm     = _PermStatus.unknown;

  // ── TTS ───────────────────────────────────────────────────────────────────

  void _say(TtsMessage msg) => ref.read(ttsServiceProvider).enqueue(
        msg, enabled: true, currentVerbosity: TtsVerbosity.standard,
      );

  AppLocalizations get _l10n =>
      AppLocalizations.of(_language == AppLanguage.tagalog);

  void _narrate(int page) {
    switch (page) {
      case 0: _say(OnboardingSpeech.welcome(_l10n));
      case 1: _say(OnboardingSpeech.visionStep(_l10n));
      case 2: _say(OnboardingSpeech.languageStep(_l10n));
      default: break;
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _narrate(0));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── Page navigation ───────────────────────────────────────────────────────

  void _goTo(int page) {
    if (page < 0 || page >= _total) return;
    _pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() => _goTo(_page + 1);
  void _back() => _goTo(_page - 1);

  void _finish({required bool launchTutorial}) {
    final n = ref.read(appSettingsProvider.notifier);
    n.setVisionProfile(_profile);
    n.setLanguage(_language);
    switch (_nav) {
      case _NavStyle.standard:
        n.toggleGesturalNavigation(false);
        n.toggleInertialNavigation(false);
      case _NavStyle.gestural:
        n.toggleGesturalNavigation(true);
        n.toggleInertialNavigation(false);
      case _NavStyle.inertial:
        n.toggleGesturalNavigation(false);
        n.toggleInertialNavigation(true);
    }
    final cfg = VisionConfig.from(_profile);
    if (cfg.preferAudioPrimary) {
      n.toggleTts(true);
      n.setTtsVerbosity(cfg.defaultTtsVerbosity);
    }
    widget.onComplete(launchTutorial: launchTutorial);
  }

  // ── Camera permission ─────────────────────────────────────────────────────

  Future<void> _requestPerm() async {
    setState(() => _perm = _PermStatus.requesting);
    try {
      final cameras = ref.read(availableCamerasProvider);
      if (cameras.isEmpty) {
        if (mounted) setState(() => _perm = _PermStatus.denied);
        return;
      }
      final ctrl = CameraController(cameras.first, ResolutionPreset.low);
      await ctrl.initialize();
      await ctrl.dispose();
      if (mounted) setState(() => _perm = _PermStatus.granted);
    } on CameraException catch (e) {
      if (!mounted) return;
      final denied = e.code == 'CameraAccessDenied' ||
          e.code == 'cameraPermission' ||
          e.code == 'CAMERA_ACCESS_DENIED';
      setState(() => _perm = denied ? _PermStatus.denied : _PermStatus.granted);
    } catch (_) {
      if (mounted) setState(() => _perm = _PermStatus.denied);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Re-read VisionConfig live so accent colours update immediately when
    // the user selects a new vision profile on page 1.
    final cfg    = VisionConfig.from(_profile);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = cfg.accent(isDark);
    final accentFg = cfg.accentForeground(isDark);
    final l10n   = _l10n;
    final bg     = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            _ProgressBar(current: _page, total: _total, accent: accent),

            // Pages: user can also swipe freely between them
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (p) {
                  setState(() => _page = p);
                  _narrate(p);
                },
                children: [
                  _WelcomePage(l10n: l10n),
                  _VisionPage(
                    l10n: l10n, selected: _profile, isDark: isDark, cfg: cfg,
                    onSelect: (p) => setState(() => _profile = p),
                  ),
                  _LanguagePage(
                    l10n: l10n, selected: _language, isDark: isDark, cfg: cfg,
                    onSelect: (v) => setState(() => _language = v),
                  ),
                  _NavPage(
                    l10n: l10n, selected: _nav, isDark: isDark, cfg: cfg,
                    onSelect: (v) => setState(() => _nav = v),
                  ),
                  _PermPage(
                    l10n: l10n, status: _perm, isDark: isDark, cfg: cfg,
                    onRequest: _requestPerm,
                  ),
                  _FinishPage(l10n: l10n),
                ],
              ),
            ),

            // Bottom buttons
            _BottomBar(
              page: _page,
              total: _total,
              accent: accent,
              accentFg: accentFg,
              isDark: isDark,
              permStatus: _perm,
              l10n: l10n,
              onBack: _back,
              onNext: _next,
              onTour: () => _finish(launchTutorial: true),
              onSkip: () => _finish(launchTutorial: false),
            ),
          ],
        ),
      ),
    );
  }
}


class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.current, required this.total, required this.accent});
  final int current, total;
  final Color accent;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.base, AppSpacing.xl, 0),
        child: Row(
          children: List.generate(total, (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: i <= current ? accent : accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          )),
        ),
      );
}


class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.page,
    required this.total,
    required this.accent,
    required this.accentFg,
    required this.isDark,
    required this.permStatus,
    required this.l10n,
    required this.onBack,
    required this.onNext,
    required this.onTour,
    required this.onSkip,
  });

  final int page, total;
  final Color accent, accentFg;
  final bool isDark;
  final _PermStatus permStatus;
  final AppLocalizations l10n;
  final VoidCallback onBack, onNext, onTour, onSkip;

  ButtonStyle get _filledStyle => FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: accentFg,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.base + 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
      );

  // A secondary filled button that uses a distinct surface color: never
  // OutlinedButton, which is transparent and breaks on light backgrounds.
  ButtonStyle _secondaryStyle(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final fg      = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    return FilledButton.styleFrom(
      backgroundColor: surface,
      foregroundColor: fg,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base + 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        side: BorderSide(color: accent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Finish page: two distinct primary actions
    if (page == total - 1) {
      return _pad(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: _filledStyle,
              onPressed: onTour,
              child: Text(l10n.onboardingFinishTour,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: _secondaryStyle(context),
              onPressed: onSkip,
              child: Text(l10n.onboardingFinishSkip,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ));
    }

    // All other pages: optional Back + primary Next/Skip
    final String nextLabel = () {
      if (page != 4) return l10n.next;
      return permStatus == _PermStatus.granted
          ? l10n.next
          : l10n.onboardingPermissionSkip;
    }();

    return _pad(Row(
      children: [
        if (page > 0) ...[
          Expanded(
            child: FilledButton(
              style: _secondaryStyle(context),
              onPressed: onBack,
              child: const Text('Back',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          flex: 2,
          child: FilledButton(
            style: _filledStyle,
            onPressed: onNext,
            child: Text(nextLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    ));
  }

  Widget _pad(Widget child) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
        child: child,
      );
}


class _OptionCard<T> extends StatelessWidget {
  const _OptionCard({
    required this.value,
    required this.selected,
    required this.onSelect,
    required this.label,
    required this.description,
    required this.icon,
    required this.cfg,
    required this.isDark,
  });
  final T value, selected;
  final ValueChanged<T> onSelect;
  final String label, description;
  final IconData icon;
  final VisionConfig cfg;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    final accent  = cfg.accent(isDark);
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final subColor = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Semantics(
      button: true, selected: isSelected, label: '$label. $description',
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: isSelected ? accent.withValues(alpha: 0.12) : surface,
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(
              color: isSelected ? accent : AppColors.darkBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isSelected ? 0.2 : 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    color: accent.withValues(alpha: isSelected ? 1.0 : 0.45), size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? accent : null,
                    )),
                    const SizedBox(height: 2),
                    Text(description, style: TextStyle(
                      fontSize: 13, color: subColor, height: 1.4,
                    )),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.check_circle_rounded, color: accent, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


Widget _pageScroll({required List<Widget> children}) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );



class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.l10n});
  final AppLocalizations l10n;
  @override
  Widget build(BuildContext context) => _pageScroll(children: [
        const SizedBox(height: AppSpacing.xl),
        Image.asset(
          'assets/images/moneysense-favicon.png',
          width: 88,
          height: 88,
          semanticLabel: 'MoneySense',
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.onboardingWelcomeTitle,
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppSpacing.base),
        Text(l10n.onboardingWelcomeSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
      ]);
}


class _VisionPage extends StatelessWidget {
  const _VisionPage({
    required this.l10n, required this.selected,
    required this.isDark, required this.cfg, required this.onSelect,
  });
  final AppLocalizations l10n;
  final VisionProfile selected;
  final bool isDark;
  final VisionConfig cfg;
  final ValueChanged<VisionProfile> onSelect;

  @override
  Widget build(BuildContext context) => _pageScroll(children: [
        Text(l10n.onboardingVisionTitle,
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.onboardingVisionSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
        const SizedBox(height: AppSpacing.xl),
        _OptionCard(
          value: VisionProfile.lowVision, selected: selected, onSelect: onSelect,
          label: l10n.visionLowVision,
          description: 'I can see but need larger text or higher contrast.',
          icon: Icons.visibility_rounded, cfg: cfg, isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.md),
        _OptionCard(
          value: VisionProfile.partiallyBlind, selected: selected, onSelect: onSelect,
          label: l10n.visionPartiallyBlind,
          description: 'I rely on audio cues alongside some vision.',
          icon: Icons.visibility_off_outlined, cfg: cfg, isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.md),
        _OptionCard(
          value: VisionProfile.fullyBlind, selected: selected, onSelect: onSelect,
          label: l10n.visionFullyBlind,
          description: 'I navigate entirely by audio and touch.',
          icon: Icons.blind_rounded, cfg: cfg, isDark: isDark,
        ),
      ]);
}


class _LanguagePage extends StatelessWidget {
  const _LanguagePage({
    required this.l10n, required this.selected,
    required this.isDark, required this.cfg, required this.onSelect,
  });
  final AppLocalizations l10n;
  final AppLanguage selected;
  final bool isDark;
  final VisionConfig cfg;
  final ValueChanged<AppLanguage> onSelect;

  @override
  Widget build(BuildContext context) => _pageScroll(children: [
        Text(l10n.language,
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppSpacing.xl),
        _OptionCard(
          value: AppLanguage.english, selected: selected, onSelect: onSelect,
          label: l10n.languageEnglish,
          description: 'App text and audio in English.',
          icon: Icons.language_rounded, cfg: cfg, isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.md),
        _OptionCard(
          value: AppLanguage.tagalog, selected: selected, onSelect: onSelect,
          label: l10n.languageTagalog,
          description: 'Teksto at audio ng app sa Filipino.',
          icon: Icons.language_rounded, cfg: cfg, isDark: isDark,
        ),
      ]);
}


class _NavPage extends StatelessWidget {
  const _NavPage({
    required this.l10n, required this.selected,
    required this.isDark, required this.cfg, required this.onSelect,
  });
  final AppLocalizations l10n;
  final _NavStyle selected;
  final bool isDark;
  final VisionConfig cfg;
  final ValueChanged<_NavStyle> onSelect;

  @override
  Widget build(BuildContext context) => _pageScroll(children: [
        Text(l10n.onboardingNavTitle,
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.onboardingNavSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
        const SizedBox(height: AppSpacing.xl),
        _OptionCard(
          value: _NavStyle.standard, selected: selected, onSelect: onSelect,
          label: l10n.onboardingNavNormal,
          description: l10n.onboardingNavNormalDesc,
          icon: Icons.touch_app_rounded, cfg: cfg, isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.md),
        _OptionCard(
          value: _NavStyle.gestural, selected: selected, onSelect: onSelect,
          label: l10n.onboardingNavGestural,
          description: l10n.onboardingNavGesturalDesc,
          icon: Icons.swipe_rounded, cfg: cfg, isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.md),
        _OptionCard(
          value: _NavStyle.inertial, selected: selected, onSelect: onSelect,
          label: l10n.onboardingNavInertial,
          description: l10n.onboardingNavInertialDesc,
          icon: Icons.screen_rotation_rounded, cfg: cfg, isDark: isDark,
        ),
      ]);
}


class _PermPage extends StatelessWidget {
  const _PermPage({
    required this.l10n, required this.status,
    required this.isDark, required this.cfg, required this.onRequest,
  });
  final AppLocalizations l10n;
  final _PermStatus status;
  final bool isDark;
  final VisionConfig cfg;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final granted   = status == _PermStatus.granted;
    final denied    = status == _PermStatus.denied;
    final accent    = cfg.accent(isDark);
    final accentFg  = cfg.accentForeground(isDark);
    final iconColor = granted ? AppColors.success : denied ? AppColors.error : accent;

    return _pageScroll(children: [
      Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.13), shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt_rounded, size: 40, color: iconColor),
          ),
          if (granted)
            const Positioned(right: 0, bottom: 0,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.success,
                  child: Icon(Icons.check, size: 14, color: Colors.white),
                )),
        ],
      ),
      const SizedBox(height: AppSpacing.xl),
      Text(l10n.onboardingPermissionTitle,
          style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: AppSpacing.base),
      Text(
        denied ? l10n.onboardingPermissionDenied
            : granted ? l10n.onboardingPermissionGranted
            : l10n.onboardingPermissionSubtitle,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
      ),
      const SizedBox(height: AppSpacing.xxxl),
      if (!granted)
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: denied ? AppColors.warning : accent,
              foregroundColor: denied ? Colors.black : accentFg,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.base + 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
            ),
            onPressed: status == _PermStatus.requesting ? null : onRequest,
            icon: status == _PermStatus.requesting
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(denied ? Icons.settings_rounded : Icons.camera_alt_rounded),
            label: Text(
              denied ? 'Open device Settings' : l10n.onboardingPermissionGrant,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
    ]);
  }
}


class _FinishPage extends StatelessWidget {
  const _FinishPage({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => _pageScroll(children: [
        const SizedBox(height: AppSpacing.xl),
        const Icon(Icons.check_circle_rounded, size: 72, color: AppColors.success),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.onboardingFinishTitle,
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppSpacing.base),
        Text(l10n.onboardingFinishSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
        const SizedBox(height: AppSpacing.xl),
        _FeatureRow(icon: Icons.crop_free_rounded,
            text: 'The Scanner screen and how to identify bills'),
        const SizedBox(height: AppSpacing.md),
        _FeatureRow(icon: Icons.settings_rounded,
            text: 'Settings and preferences'),
        const SizedBox(height: AppSpacing.md),
        _FeatureRow(icon: Icons.swipe_rounded,
            text: 'Navigation gestures and shortcuts'),
        const SizedBox(height: AppSpacing.md),
        _FeatureRow(icon: Icons.school_rounded,
            text: 'All interactive feature tutorials'),
      ]);
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text,
              style: Theme.of(context).textTheme.bodyLarge)),
        ],
      );
}
