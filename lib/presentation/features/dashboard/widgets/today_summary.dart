import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_section_label.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_stat.dart';

/// Dashboard-local hero card (kit `dashboard/today`): today's time studied + words
/// learned on the primary surface. [action] carries the optional Start CTA shown
/// only in the empty state. Colours come from the primary [MxCard]'s foreground;
/// this widget owns only sizes/weights. Copy is from ARB.
class TodaySummary extends StatelessWidget {
  const TodaySummary({
    required this.time,
    required this.words,
    this.action,
    super.key,
  });

  final String time;
  final String words;
  final Widget? action;


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final action = this.action;

    return MxCard(
      variant: MxCardVariant.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxSectionLabel(
            text: l10n.dashboardTodayEyebrow,
            uppercase: true,
            onTint: true,
          ),
          const SizedBox(height: MxSpacing.space2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MxStat(
                value: time,
                label: l10n.dashboardTimeStudied,
                size: MxStatSize.large,
                alignStart: true,
                onTint: true,
              ),
              const SizedBox(width: MxSpacing.space7),
              MxStat(
                value: words,
                label: l10n.dashboardWordsLearned,
                size: MxStatSize.large,
                alignStart: true,
                onTint: true,
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: MxSpacing.space4),
            action,
          ],
        ],
      ),
    );
  }

}
