import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';

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

  // Kit sublabels render at 90% opacity on the primary card.
  static const double _subLabelOpacity = 0.9;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxCard(
      variant: MxCardVariant.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dashboardTodayEyebrow.toUpperCase(),
            style: const TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeSm,
              fontWeight: MxTypography.bold,
              letterSpacing: MxTypography.sizeSm * MxTypography.trackingWide,
            ),
          ),
          const SizedBox(height: MxSpacing.space2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _figure(time, l10n.dashboardTimeStudied),
              const SizedBox(width: MxSpacing.space7),
              _figure(words, l10n.dashboardWordsLearned),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: MxSpacing.space4),
            action!,
          ],
        ],
      ),
    );
  }

  Widget _figure(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: MxTypography.fontFamily,
            fontSize: MxTypography.size2xl,
            fontWeight: MxTypography.extrabold,
          ),
        ),
        Opacity(
          opacity: _subLabelOpacity,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeSm,
            ),
          ),
        ),
      ],
    );
  }
}
