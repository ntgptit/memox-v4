import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_stat.dart';

/// Dashboard-local streak stat (kit `dashboard/streak`): a flame icon beside the
/// current day-streak count on the primary-soft surface. Colours inherit the
/// card's foreground; copy is from ARB.
class StreakCard extends StatelessWidget {
  const StreakCard({required this.streak, super.key});

  final int streak;


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
          MxStat(
            value: '$streak',
            label: l10n.dashboardStreakLabel,
            alignStart: true,
            onTint: true,
          ),
        ],
      ),
    );
  }
}
