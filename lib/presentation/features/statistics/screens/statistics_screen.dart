import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/statistics/providers/statistics_providers.dart';
import 'package:memox_v4/presentation/features/statistics/widgets/bars.dart';
import 'package:memox_v4/presentation/features/statistics/widgets/donut.dart';
import 'package:memox_v4/presentation/features/statistics/widgets/heatmap.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_section_header.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// Fixed height for the insufficient / error boxes.
const double _stateBoxHeight = 360;

/// The Statistics screen (S.09): streak, study heatmap, weekly time, Leitner
/// distribution, mastery, and a library overview. Reads the stats use cases +
/// activity history through [statisticsControllerProvider], rendered with
/// `AsyncValue.when` (loading · loaded · insufficient · error). No `setState`.
/// Scope + accuracy are documented gaps. Copy is from ARB.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appBar = MxAppBar(large: true, title: l10n.statsTitle);
    final async = ref.watch(statisticsControllerProvider);

    return async.when(
      loading: () => MxScaffold(appBar: appBar, children: _loadingBody()),
      error: (_, _) => MxScaffold(
        appBar: appBar,
        children: [
          SizedBox(
            height: _stateBoxHeight,
            child: _ErrorBody(
              onRetry: () => ref.invalidate(statisticsControllerProvider),
            ),
          ),
        ],
      ),
      data: (data) => data.hasActivity
          ? _loaded(context, appBar, data)
          : _insufficient(context, appBar),
    );
  }

  Widget _insufficient(BuildContext context, MxAppBar appBar) {
    final l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: appBar,
      children: [
        SizedBox(
          height: _stateBoxHeight,
          child: MxEmptyState(
            icon: Icons.bar_chart,
            title: l10n.statsInsufficientTitle,
            text: l10n.statsInsufficientText,
          ),
        ),
      ],
    );
  }

  Widget _loaded(BuildContext context, MxAppBar appBar, StatisticsData data) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final weekdayInitials = [
      l10n.reminderDayMon,
      l10n.reminderDayTue,
      l10n.reminderDayWed,
      l10n.reminderDayThu,
      l10n.reminderDayFri,
      l10n.reminderDaySat,
      l10n.reminderDaySun,
    ].map((d) => d.substring(0, 1)).toList();

    final leitnerValues = [
      for (var box = BoxLevel.firstScheduled; box <= BoxLevel.max; box++)
        data.leitner[box] ?? 0,
    ];
    final leitnerLabels = [
      for (var box = BoxLevel.firstScheduled; box <= BoxLevel.max; box++) '$box',
    ];

    return MxScaffold(
      appBar: appBar,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  value: '${data.currentStreak}',
                  label: l10n.statsCurrentStreak,
                  variant: MxCardVariant.primarySoft,
                ),
              ),
              const SizedBox(width: MxSpacing.space3),
              Expanded(
                child: _StatTile(
                  value: '${data.longestStreak}',
                  label: l10n.statsLongest,
                  variant: MxCardVariant.muted,
                ),
              ),
            ],
          ),
        ),
        MxSectionHeader(
          title: l10n.statsCalendar,
          caption: l10n.statsCalendarCaption,
        ),
        MxCard(child: Heatmap(days: data.heatmapDays)),
        MxSectionHeader(title: l10n.statsWeekly, caption: l10n.statsWeeklyCaption),
        MxCard(child: Bars(data: data.weeklyMinutes, labels: weekdayInitials)),
        MxSectionHeader(title: l10n.statsLeitner, caption: l10n.statsLeitnerCaption),
        MxCard(
          child: Bars(
            data: leitnerValues,
            labels: leitnerLabels,
            color: scheme.secondary,
          ),
        ),
        MxSectionHeader(title: l10n.statsMastery),
        MxCard(child: Donut(percent: data.masteryPercent, label: l10n.statsMasteryLabel)),
        MxSectionHeader(title: l10n.statsOverview),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  value: '${data.totalCards}',
                  label: l10n.statsTotal,
                  variant: MxCardVariant.muted,
                ),
              ),
              const SizedBox(width: MxSpacing.space3),
              Expanded(
                child: _StatTile(
                  value: '${data.masteredCards}',
                  label: l10n.statsMastered,
                  variant: MxCardVariant.muted,
                ),
              ),
              const SizedBox(width: MxSpacing.space3),
              Expanded(
                child: _StatTile(
                  value: '${data.dueCards}',
                  label: l10n.statsDue,
                  variant: MxCardVariant.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _loadingBody() {
    return [
      const MxCard(child: MxSkeleton(height: 40)),
      for (var i = 0; i < 3; i++)
        const MxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MxSkeleton(width: 140, height: 14),
              SizedBox(height: MxSpacing.space3),
              MxSkeleton(height: 110),
            ],
          ),
        ),
    ];
  }
}

/// A centered number + label stat card (kit `Stat`).
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.variant,
  });

  final String value;
  final String label;
  final MxCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);

    return MxCard(
      variant: variant,
      padding: MxCardPadding.small,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.size2xl,
              fontWeight: MxTypography.extrabold,
              height: MxTypography.lineHeightNone,
            ),
          ),
          const SizedBox(height: MxSpacing.space1),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeSm,
              color: mx.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      icon: Icons.error_outline,
      tone: MxIconTileTone.error,
      title: l10n.statsErrorTitle,
      text: l10n.statsErrorText,
      action: MxButton(
        label: l10n.actionRetry,
        icon: Icons.refresh,
        onPressed: onRetry,
      ),
    );
  }
}
