import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_component.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';

/// Dashboard-local streak stat (kit `dashboard/streak`): a flame icon beside the
/// current day-streak count on the primary-soft surface. Colours inherit the
/// card's foreground; copy is from ARB.
class StreakCard extends StatelessWidget {
  const StreakCard({required this.streak, super.key});

  final int streak;

  // Kit sublabel renders at 85% opacity on the primary-soft card.
  static const double _labelOpacity = MxOpacity.labelSoft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxCard(
      variant: MxCardVariant.primarySoft,
      padding: MxCardPadding.small,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department, size: MxIconSize.md),
          const SizedBox(width: MxSpacing.space3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$streak',
                style: const TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxIconSize.md,
                  fontWeight: MxTypography.extrabold,
                  height: MxTypography.lineHeightNone,
                ),
              ),
              Opacity(
                opacity: _labelOpacity,
                child: Text(
                  l10n.dashboardStreakLabel,
                  style: const TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeXs,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
