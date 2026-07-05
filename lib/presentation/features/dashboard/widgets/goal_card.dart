import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_stat_ring.dart';

/// Dashboard-local goal card (kit `dashboard/goal`): a progress ring beside the
/// daily-goal title, progress line, and rule caption. Copy is from ARB.
class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.goal,
    required this.minutes,
    required this.words,
    required this.percent,
    required this.met,
    super.key,
  });

  final DailyGoal goal;
  final int minutes;
  final int words;

  /// Progress toward the goal, 0..1.
  final double percent;
  final bool met;

  static const int _percentScale = 100;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MxStatRing(
            percent: percent,
            value: '${(percent * _percentScale).round()}%',
          ),
          const SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.dashboardGoalTitle,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeMd,
                    fontWeight: MxTypography.extrabold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: MxSpacing.space1),
                Text(
                  _progressText(l10n),
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeBase,
                    color: mx.textSecondary,
                  ),
                ),
                const SizedBox(height: MxSpacing.space1),
                Text(
                  l10n.dashboardGoalRule,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeSm,
                    color: mx.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _progressText(AppLocalizations l10n) {
    final minutesTarget = goal.minutesTarget;
    if (minutesTarget != null) {
      return met
          ? l10n.dashboardGoalMinutesMet(minutes, minutesTarget)
          : l10n.dashboardGoalMinutes(minutes, minutesTarget);
    }
    final wordsTarget = goal.wordsTarget;
    if (wordsTarget != null) {
      return met
          ? l10n.dashboardGoalWordsMet(words, wordsTarget)
          : l10n.dashboardGoalWords(words, wordsTarget);
    }
    return l10n.dashboardGoalUnset;
  }
}
