import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/earcon_service.dart';
import '../../../../core/services/speech_scripts.dart';
import '../../../../core/services/tts_service.dart';
import '../../../settings/domain/entities/vision_config.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/datasources/authenticity_service.dart';
import '../../domain/entities/scanner_state.dart';
import '../providers/scanner_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.result});
  final DetectionResult result;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {

  Timer?  _autoTimer;
  int     _secondsLeft = 0;
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;
  
  bool _isVerifying = false;
  VerificationResult? _verificationResult;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _announce());
    HapticFeedback.mediumImpact();

    final timerSecs = ref.read(appSettingsProvider).goBackTimerSeconds;
    if (timerSecs > 0) {
      setState(() => _secondsLeft = timerSecs);
      _autoTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() => _secondsLeft--);
        if (_secondsLeft <= 0) { t.cancel(); _dismiss(); }
      });
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _announce() {
    final s    = ref.read(appSettingsProvider);
    final l10n = AppLocalizations.of(s.isTagalog);
    final r    = widget.result;
    final msg  = r.isUncertain
        ? ScannerSpeech.scanFailed(l10n)
        : ScannerSpeech.denominationResult(
            l10n: l10n,
            denomination: r.denomination,
            type: r.type,
            confidence: r.confidence,
            verbosity: s.ttsVerbosity,
          );
    ref.read(ttsServiceProvider).enqueue(
      msg, enabled: s.ttsEnabled, currentVerbosity: s.ttsVerbosity,
    );
  }

  void _dismiss() {
    _autoTimer?.cancel();
    EarconService.instance.play(EarconEvent.navBack);
    ref.read(scannerStateProvider.notifier).reset();
  }

  void _confirm() {
    _autoTimer?.cancel();
    final result = ref.read(detectionResultProvider) ?? widget.result;
    
    // If it's a bill and we haven't verified yet, trigger verification
    if (result.type == 'bill' && _verificationResult == null && !_isVerifying) {
      _verify(result);
      return;
    }

    EarconService.instance.play(EarconEvent.actionConfirmed);
    ref.read(scannerStateProvider.notifier).reset();
  }

  Future<void> _verify(DetectionResult result) async {
    if (result.capturedImage == null) {
      debugPrint('[ResultScreen] No captured image for verification.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _autoTimer?.cancel(); // Stop auto-return timer during verification
    });

    final s = ref.read(appSettingsProvider);
    final l10n = AppLocalizations.of(s.isTagalog);
    
    ref.read(ttsServiceProvider).enqueue(
      TtsMessage.result(l10n.resultVerifying, id: 'verify.start'),
      enabled: s.ttsEnabled,
      currentVerbosity: s.ttsVerbosity,
    );

    try {
      final res = await AuthenticityService.instance.verify(
        imageBytes: result.capturedImage!,
        boundingBox: result.boundingBox,
      );

      if (!mounted) return;

      setState(() {
        _isVerifying = false;
        _verificationResult = res;
      });

      final msg = res.status == AuthenticityResult.genuine
          ? l10n.resultGenuine
          : res.status == AuthenticityResult.counterfeit
              ? l10n.resultCounterfeit
              : l10n.resultVerificationFailed;

      ref.read(ttsServiceProvider).enqueue(
        TtsMessage.result(msg, id: 'verify.result'),
        enabled: s.ttsEnabled, 
        currentVerbosity: s.ttsVerbosity,
      );
      
      HapticFeedback.heavyImpact();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      ref.read(ttsServiceProvider).enqueue(
        TtsMessage.critical(l10n.resultVerificationFailed, id: 'verify.error'),
        enabled: s.ttsEnabled, 
        currentVerbosity: s.ttsVerbosity,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(detectionResultProvider) ?? widget.result;
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cfg    = ref.watch(visionConfigProvider);
    final s      = ref.watch(appSettingsProvider);
    final l10n   = AppLocalizations.of(s.isTagalog);

    final isUncertain = widget.result.isUncertain;
    final borderColor = isUncertain ? AppColors.error : const Color(0xFF4CAF50);
    final bg    = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onBg  = isDark ? AppColors.darkOnSurface  : AppColors.lightOnSurface;
    final yellow = cfg.accentYellow;
    final blue   = cfg.accentBlue;

    return Semantics(
      label: _semanticLabel(l10n),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Scaffold(
            backgroundColor: bg,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pagePadding,
                        AppSpacing.xl,
                        AppSpacing.pagePadding,
                        AppSpacing.md,
                      ),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: (result.boundingBox != null &&
                                  result.boundingBox!.width > 0 &&
                                  result.boundingBox!.height > 0)
                              ? result.boundingBox!.width /
                                  result.boundingBox!.height
                              : (result.type == 'coin' ? 1.0 : 1.6),
                          child: _CurrencyCard(
                            isDark: isDark,
                            borderColor: borderColor,
                            result: result,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Text zone ────────────────────────────────────
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isUncertain
                                ? l10n.resultUncertainLabel
                                : widget.result.displayLabel,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: onBg,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ConfidenceSentence(
                            result: result,
                            l10n: l10n,
                            theme: theme,
                            onBg: onBg,
                            accentColor: borderColor,
                          ),
                          if (_isVerifying) ...[
                            const SizedBox(height: AppSpacing.lg),
                            const CircularProgressIndicator(),
                            const SizedBox(height: AppSpacing.sm),
                            Text(l10n.resultVerifying, style: theme.textTheme.bodyMedium),
                          ],
                          if (_verificationResult != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: _verificationResult!.status == AuthenticityResult.genuine
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _verificationResult!.status == AuthenticityResult.genuine
                                      ? Colors.green
                                      : Colors.red,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                _verificationResult!.status == AuthenticityResult.genuine
                                    ? l10n.resultGenuine
                                    : l10n.resultCounterfeit,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: _verificationResult!.status == AuthenticityResult.genuine
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (_secondsLeft > 0) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _GoBackHint(
                              secondsLeft: _secondsLeft,
                              l10n: l10n,
                              accentColor: blue,
                              onTap: _dismiss,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding, AppSpacing.sm,
                  AppSpacing.pagePadding, AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(child: _ActionButton(
                      icon: Icons.close_rounded,
                      color: yellow,
                      semanticLabel: l10n.resultDismissLabel,
                      onTap: _dismiss,
                    )),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _ActionButton(
                      icon: _isVerifying
                          ? Icons.hourglass_empty_rounded
                          : _verificationResult != null || widget.result.type != 'bill'
                              ? Icons.check_rounded
                              : Icons.verified_user_rounded,
                      color: blue,
                      semanticLabel: result.type == 'bill' && _verificationResult == null
                          ? l10n.resultVerifyLabel
                          : l10n.resultConfirmLabel,
                      onTap: _isVerifying ? () {} : _confirm,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel(AppLocalizations l10n) {
    if (widget.result.isUncertain) return l10n.resultSemanticUncertain;
    final levelLabel = switch (widget.result.confidenceLevel) {
      ConfidenceLevel.veryConfident => l10n.confidenceVeryConfident,
      ConfidenceLevel.confident     => l10n.confidenceConfident,
      ConfidenceLevel.uncertain     => l10n.confidenceUncertain,
    };
    return l10n.resultSemanticConfident(
      widget.result.denomination, widget.result.type, levelLabel,
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard({
    required this.isDark,
    required this.borderColor,
    required this.result,
  });
  final bool isDark;
  final Color borderColor;
  final DetectionResult result;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (result.isUncertain) {
      content = Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: borderColor.withValues(alpha: 0.12),
            letterSpacing: 2,
          ),
        ),
      );
    } else if (result.capturedImage != null) {
      content = _CapturedImagePreview(
        imageBytes: result.capturedImage!,
        boundingBox: result.boundingBox,
        borderColor: borderColor,
      );
    } else if (result.type == 'coin') {
      content = _CoinRepresentation(denomination: result.denomination);
    } else {
      content = _BillRepresentation(denomination: result.denomination);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: KeyedSubtree(
            key: ValueKey(result.capturedImage == null ? 'placeholder' : 'image'),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _CapturedImagePreview extends StatelessWidget {
  const _CapturedImagePreview({
    required this.imageBytes,
    required this.boundingBox,
    required this.borderColor,
  });

  final Uint8List imageBytes;
  final Rect? boundingBox;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    if (boundingBox == null) {
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Visual cropping using Align + Fractional factors
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // The actual cropped image
            Align(
              alignment: Alignment(
                (boundingBox!.center.dx * 2) - 1,
                (boundingBox!.center.dy * 2) - 1,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / boundingBox!.width,
                heightFactor: 1 / boundingBox!.height,
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Subtle premium overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BillRepresentation extends StatelessWidget {
  const _BillRepresentation({required this.denomination});
  final String denomination;

  Color get _dominantColor {
    switch (denomination) {
      case '1000': return const Color(0xFF007BFF); // Vivid Blue
      case '500':  return const Color(0xFFFFC107); // Vivid Amber
      case '200':  return const Color(0xFF28A745); // Vivid Green
      case '100':  return const Color(0xFF9C27B0); // Vivid Purple
      case '50':   return const Color(0xFFDC3545); // Vivid Red
      case '20':   return const Color(0xFFFF5722); // Vivid Deep Orange
      default:     return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _dominantColor;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Watermark circle
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
            // Security thread
            Positioned(
              left: 40,
              top: 0,
              bottom: 0,
              child: Container(
                width: 12,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            // Denomination Text
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '₱',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    denomination,
                    style: TextStyle(
                      fontSize: 84,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -2,
                      shadows: [
                        Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinRepresentation extends StatelessWidget {
  const _CoinRepresentation({required this.denomination});
  final String denomination;

  List<Color> get _gradientColors {
    if (denomination == '20') {
      return [const Color(0xFFFFD54F), const Color(0xFFFF8F00)]; // High contrast Gold/Bronze
    } else if (denomination == '5') {
      return [const Color(0xFFFFE082), const Color(0xFFFFCA28)]; // Bright Pale Gold
    }
    // Very bright Silver (10, 1)
    return [const Color(0xFFFFFFFF), const Color(0xFFBDBDBD)];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradientColors;
    final isSilver = denomination != '20' && denomination != '5';
    final textColor = isSilver ? Colors.grey.shade800 : Colors.brown.shade900;
    
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: RadialGradient(
              colors: colors,
              center: const Alignment(-0.2, -0.3),
              radius: 0.8,
            ),
            border: Border.all(
              color: isSilver ? Colors.grey.shade400 : Colors.orange.shade300,
              width: 8,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₱$denomination',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    height: 1.0,
                    shadows: [
                      Shadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfidenceSentence extends StatelessWidget {
  const _ConfidenceSentence({
    required this.result,
    required this.l10n,
    required this.theme,
    required this.onBg,
    required this.accentColor,
  });
  final DetectionResult  result;
  final AppLocalizations l10n;
  final ThemeData        theme;
  final Color            onBg;
  final Color            accentColor;

  @override
  Widget build(BuildContext context) {
    final base    = theme.textTheme.bodyLarge?.copyWith(color: onBg, height: 1.5);
    final keyword = base?.copyWith(color: accentColor, fontWeight: FontWeight.w700);

    final TextSpan span;
    if (result.isUncertain) {
      span = TextSpan(style: base, children: [
        TextSpan(text: l10n.resultConfidencePre),
        TextSpan(text: l10n.confidenceUncertain, style: keyword),
        TextSpan(text: l10n.resultUncertainSuffix),
      ]);
    } else {
      final kw = result.confidenceLevel == ConfidenceLevel.veryConfident
          ? l10n.confidenceVeryConfident
          : l10n.confidenceConfident;
      final pct = (result.confidence * 100).toStringAsFixed(0);
      span = TextSpan(style: base, children: [
        TextSpan(text: l10n.resultConfidencePre),
        TextSpan(text: '$kw ($pct%)', style: keyword),
        TextSpan(text: l10n.resultConfidentSuffix(
            result.denomination, result.type)),
      ]);
    }
    return Text.rich(span, textAlign: TextAlign.center);
  }
}

class _GoBackHint extends StatelessWidget {
  const _GoBackHint({
    required this.secondsLeft,
    required this.l10n,
    required this.accentColor,
    required this.onTap,
  });
  final int              secondsLeft;
  final AppLocalizations l10n;
  final Color            accentColor;
  final VoidCallback     onTap;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtle = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Semantics(
      label: l10n.resultGoBackHintSemantic(secondsLeft.toString()),
      child: GestureDetector(
        onTap: onTap,
        child: Text.rich(
          TextSpan(
            style: theme.textTheme.bodySmall?.copyWith(color: subtle),
            children: [
              TextSpan(text: l10n.resultGoBackHintPre(secondsLeft.toString())),
              TextSpan(
                text: l10n.resultGoBackLink,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: accentColor,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.semanticLabel,
    required this.onTap,
  });
  final IconData     icon;
  final Color        color;
  final String       semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
