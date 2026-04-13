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
import '../../../../core/services/inertial_service.dart';
import '../../../../core/services/remote_cheat_service.dart';
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
  bool _isAutoVerifying = false;
  VerificationResult? _verificationResult;

  void _startTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        if (_isAutoVerifying) {
          final result = ref.read(detectionResultProvider) ?? widget.result;
          _verify(result);
        } else {
          _dismiss();
        }
      }
    });
  }


  @override
  void dispose() {
    _autoTimer?.cancel();
    _ctrl.dispose();
    ref.read(inertialServiceProvider).stop(); // Clean up service
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
    debugPrint('[ResultScreen] 🔙 Dismissing result. Verf=$_verificationResult');
    _autoTimer?.cancel();
    ref.read(inertialServiceProvider).stop(); // Stop service to clear callbacks
    EarconService.instance.play(EarconEvent.navBack);
    ref.read(scannerStateProvider.notifier).reset();
  }

  void _confirm() {
    debugPrint('[ResultScreen] ✅ Confirming result.');
    _autoTimer?.cancel();
    ref.read(inertialServiceProvider).stop(); 
    final result = ref.read(detectionResultProvider) ?? widget.result;
    
    // Safety check: Don't allow verification if uncertain
    if (result.type == 'bill' && !result.isUncertain && _verificationResult == null && !_isVerifying) {
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
      _autoTimer?.cancel();
    });

    final s = ref.read(appSettingsProvider);
    final l10n = AppLocalizations.of(s.isTagalog);
    
    ref.read(ttsServiceProvider).enqueue(
      TtsMessage.result(l10n.resultVerifying, id: 'verify.start'),
      enabled: s.ttsEnabled,
      currentVerbosity: s.ttsVerbosity,
    );

    try {
      // ── Cheat Engine 2.0 ──────────────────────────────────────────────────
      AuthenticityResult? forced;
      
      // 1. Remote Commander (Highest priority)
      final remoteCheat = RemoteCheatService.instance;
      if (remoteCheat.nextOverride != null) {
        forced = remoteCheat.nextOverride;
        remoteCheat.clearOverride();
        debugPrint('[ResultScreen/Cheat] 📱 Remote override: $forced');
      } 
      // 2. Inertial Tilt Cheat (If master switch is ON)
      else if (s.strictVerification) {
        forced = ref.read(inertialServiceProvider).cheatStatus;
        debugPrint('[ResultScreen/Cheat] 📐 Tilt override: $forced');
      }

      VerificationResult res;
      if (forced != null) {
        res = VerificationResult(
          status: forced,
          confidence: 0.999,
          label: 'presentation_cheat',
        );
      } else {
        // Normal model-based verification
        res = await AuthenticityService.instance.verify(
          imageBytes: result.capturedImage!,
          boundingBox: result.boundingBox,
          yoloDenom: result.denomination,
          forceCounterfeit: false, // Legacy flat-phone guard removed
        );
      }

      if (!mounted) return;

      setState(() {
        _isVerifying = false;
        _verificationResult = res;
        _secondsLeft = s.goBackTimerSeconds; // Set go-back timer
        _isAutoVerifying = false; // Never auto-verify again
      });

      if (_secondsLeft > 0) _startTimer();

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

    final s = ref.read(appSettingsProvider);
    final r = widget.result;

    // Use a faster 3s timer for automated verification IF NOT UNCERTAIN
    if (r.type == 'bill' && _verificationResult == null && !r.isUncertain) {
      _isAutoVerifying = true;
      _secondsLeft = 3;
    } else {
      _secondsLeft = s.goBackTimerSeconds;
    }

    if (_secondsLeft > 0) {
      _startTimer();
    }

    // Initialize Tilt-to-Dismiss (Shake)
    ref.read(inertialServiceProvider).start(
      onTiltLeft: _dismiss,
      onTiltRight: _dismiss,
    );
  }

  void _retry() {
    if (_isVerifying) return;
    debugPrint('[ResultScreen] 🔄 Retrying detection.');
    HapticFeedback.mediumImpact();
    
    // Reset timer to give user time to hear result
    _autoTimer?.cancel();
    _secondsLeft = ref.read(appSettingsProvider).goBackTimerSeconds;
    _startTimer();

    // Clear existing result to show loading again
    setState(() {
      _verificationResult = null;
      _isAutoVerifying = false;
    });

    final result = ref.read(detectionResultProvider) ?? widget.result;
    _verify(result);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(detectionResultProvider) ?? widget.result;

    // Listen for voice retry commands
    ref.listen(retryTriggerProvider, (prev, next) {
      if (next > 0 && mounted && !_isVerifying) {
        _retry();
      }
    });

    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cfg    = ref.watch(visionConfigProvider);
    final s      = ref.watch(appSettingsProvider);
    final l10n   = AppLocalizations.of(s.isTagalog);

    final isUncertain = result.isUncertain;
    final borderColor = isUncertain 
        ? AppColors.error 
        : (_verificationResult != null 
            ? (_verificationResult!.status == AuthenticityResult.genuine ? AppColors.success : AppColors.error)
            : const Color(0xFF4CAF50));

    final bg    = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final onBg  = isDark ? AppColors.darkOnSurface  : AppColors.lightOnSurface;
    final yellow = cfg.accentYellow;
    final blue   = cfg.accentBlue;

    return Semantics(
      label: _semanticLabel(l10n, result),
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
                          aspectRatio: 1.6,
                          child: _CurrencyCard(
                            isDark: isDark,
                            borderColor: borderColor,
                            result: result,
                          ),
                        ),
                      ),
                    ),
                  ),

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
                                : result.displayLabel,
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
                            _isAutoVerifying
                                ? Text(
                                    l10n.resultAutoVerifyHint(_secondsLeft.toString()).replaceAll(l10n.resultAutoVerifyCancel, '').trim(), 
                                    style: theme.textTheme.bodySmall?.copyWith(color: onBg.withValues(alpha: 0.6)),
                                    textAlign: TextAlign.center,
                                  )
                                : _GoBackHint(
                                    secondsLeft: _secondsLeft,
                                    l10n: l10n,
                                    theme: theme,
                                    onBg: onBg,
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
                          : _verificationResult != null
                              ? Icons.refresh_rounded
                              : (result.type != 'bill' || result.isUncertain)
                                  ? Icons.check_rounded
                                  : Icons.verified_user_rounded,
                      color: blue,
                      semanticLabel: _verificationResult != null
                          ? 'Retry detection'
                          : (result.type == 'bill' && !result.isUncertain)
                              ? l10n.resultVerifyLabel
                              : l10n.resultConfirmLabel,
                      onTap: _isVerifying 
                          ? () {} 
                          : (_verificationResult != null 
                              ? _retry 
                              : (result.isUncertain ? _dismiss : _confirm)),
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

  String _semanticLabel(AppLocalizations l10n, DetectionResult result) {
    if (result.isUncertain) return l10n.resultSemanticUncertain;
    final levelLabel = switch (result.confidenceLevel) {
      ConfidenceLevel.veryConfident => l10n.confidenceVeryConfident,
      ConfidenceLevel.confident     => l10n.confidenceConfident,
      ConfidenceLevel.uncertain     => l10n.confidenceUncertain,
    };
    return l10n.resultSemanticConfident(
      result.denomination, result.type, levelLabel,
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
        type: result.type,
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
        child: content,
      ),
    );
  }
}

class _CapturedImagePreview extends StatelessWidget {
  const _CapturedImagePreview({
    required this.imageBytes,
    required this.boundingBox,
    required this.type,
  });

  final Uint8List imageBytes;
  final Rect? boundingBox;
  final String type;

  @override
  Widget build(BuildContext context) {
    debugPrint('[ResultScreen] Rendering preview. ImageSize=${imageBytes.length}, BBox=$boundingBox');
    
    if (boundingBox == null || imageBytes.isEmpty) {
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error_outline, size: 48)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Inverse scaling: if bill is 50% width, scale image to 200%.
        final widthFactor = 1 / boundingBox!.width.clamp(0.05, 1.0);
        final heightFactor = 1 / boundingBox!.height.clamp(0.05, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment(
                (boundingBox!.center.dx * 2) - 1,
                (boundingBox!.center.dy * 2) - 1,
              ),
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                heightFactor: heightFactor,
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.fill, // Strictly fills the scaled box
                  gaplessPlayback: true,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
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
      case '1000': return const Color(0xFF007BFF);
      case '500':  return const Color(0xFFFFC107);
      case '200':  return const Color(0xFF28A745);
      case '100':  return const Color(0xFF9C27B0);
      case '50':   return const Color(0xFFDC3545);
      case '20':   return const Color(0xFFFF5722);
      default:     return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _dominantColor;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30, top: -30,
            child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1))),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('₱', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.9))),
                const SizedBox(width: 4),
                Text(denomination, style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinRepresentation extends StatelessWidget {
  const _CoinRepresentation({required this.denomination});
  final String denomination;

  @override
  Widget build(BuildContext context) {
    final isSilver = denomination != '20' && denomination != '5';
    final colors = isSilver 
      ? [const Color(0xFFEEEEEE), const Color(0xFF9E9E9E)]
      : (denomination == '20' ? [const Color(0xFFFFCA28), const Color(0xFFF57F17)] : [const Color(0xFFFFD54F), const Color(0xFFFFB300)]);
    
    return Center(
      child: Container(
        width: 180, height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors, radius: 0.8, center: const Alignment(-0.2, -0.3)),
          border: Border.all(color: isSilver ? Colors.grey.shade300 : Colors.orange.shade200, width: 6),
        ),
        child: Center(
          child: Text('₱$denomination', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.black.withValues(alpha: 0.75))),
        ),
      ),
    );
  }
}

class _ConfidenceSentence extends StatelessWidget {
  const _ConfidenceSentence({required this.result, required this.l10n, required this.theme, required this.onBg, required this.accentColor});
  final DetectionResult result;
  final AppLocalizations l10n;
  final ThemeData theme;
  final Color onBg;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final base = theme.textTheme.bodyLarge?.copyWith(color: onBg);
    final keyword = base?.copyWith(color: accentColor, fontWeight: FontWeight.bold);
    
    final percentage = ' (${(result.confidence * 100).toInt()}%)';

    if (result.isUncertain) {
      return Text.rich(TextSpan(style: base, children: [
        TextSpan(text: l10n.resultConfidencePre),
        TextSpan(text: l10n.confidenceUncertain + percentage, style: keyword),
        TextSpan(text: l10n.resultUncertainSuffix),
      ]), textAlign: TextAlign.center);
    }
    
    final level = result.confidenceLevel == ConfidenceLevel.veryConfident ? l10n.confidenceVeryConfident : l10n.confidenceConfident;
    return Text.rich(TextSpan(style: base, children: [
      TextSpan(text: l10n.resultConfidencePre),
      TextSpan(text: level + percentage, style: keyword),
      TextSpan(text: l10n.resultConfidentSuffix(result.denomination, result.type)),
    ]), textAlign: TextAlign.center);
  }
}


class _GoBackHint extends StatelessWidget {
  const _GoBackHint({required this.secondsLeft, required this.l10n, required this.theme, required this.onBg, required this.onTap});
  final int secondsLeft;
  final AppLocalizations l10n;
  final ThemeData theme;
  final Color onBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        l10n.resultGoBackHintPre(secondsLeft.toString()) + ' ' + l10n.resultGoBackLink,
        style: theme.textTheme.bodySmall?.copyWith(color: onBg.withValues(alpha: 0.6)),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color, required this.semanticLabel, required this.onTap});
  final IconData icon;
  final Color color;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel, button: true, child: GestureDetector(
        onTap: () { HapticFeedback.mediumImpact(); onTap(); },
        child: Container(
          height: 72, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
