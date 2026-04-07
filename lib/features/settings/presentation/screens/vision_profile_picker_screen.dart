import 'package:flutter/material.dart';
import 'package:moneysensev2/features/settings/domain/entities/app_settings.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/earcon_service.dart';

/// Opened from [SimpleSettingsScreen] when the user taps Vision Profile.
/// Shows 3 large cards. Tapping a card pops with the chosen [VisionProfile].
class VisionProfilePickerScreen extends StatelessWidget {
  const VisionProfilePickerScreen({
    super.key,
    required this.current,
    required this.l10n,
  });

  final VisionProfile current;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final profiles = [
      _ProfileOption(
        profile: VisionProfile.lowVision,
        label: l10n.visionLowVision,
        description: l10n.visionLowVisionDesc, 
        icon: Icons.visibility_rounded,
      ),
      _ProfileOption(
        profile: VisionProfile.partiallyBlind,
        label: l10n.visionPartiallyBlind,
        description: l10n.visionPartiallyBlindDesc,
        icon: Icons.visibility_off_rounded,
      ),
      _ProfileOption(
        profile: VisionProfile.fullyBlind,
        label: l10n.visionFullyBlind,
        description: l10n.visionFullyBlindDesc,
        icon: Icons.blind_rounded,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.visionProfileTitle)),
      body: Column(
        children: [
          // ── Scrollable cards ───────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final option in profiles) ...[
                    _ProfileCard(
                      option: option,
                      isSelected: current == option.profile,
                      onTap: () {
                        EarconService.instance.play(
                          EarconEvent.actionConfirmed,
                        );
                        Navigator.of(context).pop(option.profile);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
          ),

          // ── Back button pinned at bottom ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.sm,
              AppSpacing.pagePadding,
              AppSpacing.xl,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD600),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                  ),
                ),
                onPressed: () {
                  EarconService.instance.play(EarconEvent.navBack);
                  Navigator.of(context).maybePop();
                },

                label: Text(
                  'Back',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption {
  const _ProfileOption({
    required this.profile,
    required this.label,
    required this.description,
    required this.icon,
  });

  final VisionProfile profile;
  final String label;
  final String description;
  final IconData icon;
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _ProfileOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  final backgroundColor = isSelected
      ? theme.colorScheme.primary
      : theme.colorScheme.surface;
  final textColor = isSelected
      ? theme.colorScheme.onPrimary
      : theme.colorScheme.onSurface;
  final iconBackground = isSelected
      ? textColor.withOpacity(0.08)
      : textColor.withOpacity(0.12);

  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
      child: Semantics(  // ← MOVED INSIDE InkWell
        label: '${option.label}. ${option.description}.'
            '${isSelected ? ' Currently selected.' : ''} Button',
        button: true,
        selected: isSelected,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(option.icon, size: 28, color: textColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: textColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
