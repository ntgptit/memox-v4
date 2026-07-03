import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';

/// Study-result local (kit `StreakGoalCard`): the day streak + today's goal
/// progress, on a primary-soft card. Copy is from ARB.
class StreakGoalCard extends StatelessWidget {
  const StreakGoalCard({
    required this.streakLabel,
    required this.streakCaption,
    required this.goalLabel,
    required this.goalValue,
    required this.goalPercent,
    super.key,
  });

  final String streakLabel;
  final String streakCaption;
  final String goalLabel;
  final String goalValue;
  final double goalPercent;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final foreground = mx.onPrimarySoft;

    return MxCard(
      variant: MxCardVariant.primarySoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department,
                  size: MxIconSize.lg, color: foreground),
              const SizedBox(width: MxSpacing.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streakLabel,
                      style: TextStyle(
                        fontFamily: MxTypography.fontFamily,
                        fontSize: MxTypography.sizeMd,
                        fontWeight: MxTypography.extrabold,
                        color: foreground,
                      ),
                    ),
                    Text(
                      streakCaption,
                      style: TextStyle(
                        fontFamily: MxTypography.fontFamily,
                        fontSize: MxTypography.sizeSm,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MxSpacing.space3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goalLabel,
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeSm,
                  color: foreground,
                ),
              ),
              Text(
                goalValue,
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeSm,
                  color: foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: MxSpacing.space2),
          MxProgressBar(value: goalPercent, color: foreground),
        ],
      ),
    );
  }
}
