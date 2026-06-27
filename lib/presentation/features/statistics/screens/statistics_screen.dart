import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/models/statistics_summary.dart';
import 'package:memox_v4/domain/types/stats_scope.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/statistics/viewmodels/statistics_notifier.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';

/// Stats tab — library overview, box distribution, due forecast, activity, with
/// a current-pair ↔ all-app scope toggle (`16-statistics.md`).
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scope = ref.watch(statsScopeProvider);
    final stats = ref.watch(statisticsProvider(scope));
    return MxContentBounds(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(MxSpacing.space4),
            child: SegmentedButton<StatsScope>(
              segments: <ButtonSegment<StatsScope>>[
                ButtonSegment<StatsScope>(
                  value: StatsScope.currentPair,
                  label: Text(l10n.statsScopeCurrentPair),
                ),
                ButtonSegment<StatsScope>(
                  value: StatsScope.allApp,
                  label: Text(l10n.statsScopeAllApp),
                ),
              ],
              selected: <StatsScope>{scope},
              onSelectionChanged: (selected) =>
                  ref.read(statsScopeProvider.notifier).set(selected.first),
            ),
          ),
          Expanded(
            child: stats.when(
              loading: () => const _StatsSkeleton(),
              error: (_, _) => _StatsError(
                message: l10n.statsError,
                retryLabel: l10n.commonRetry,
                onRetry: () => ref.invalidate(statisticsProvider(scope)),
              ),
              data: (summary) => summary.hasEnoughData
                  ? _StatsBody(summary: summary)
                  : _StatsInsufficient(message: l10n.statsInsufficient),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.summary});

  final StatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      key: const Key('statistics'),
      padding: const EdgeInsets.fromLTRB(
        MxSpacing.space4,
        0,
        MxSpacing.space4,
        MxSpacing.space4,
      ),
      children: <Widget>[
        _OverviewCard(summary: summary),
        const SizedBox(height: MxSpacing.space3),
        _StatsCard(
          title: l10n.statsBoxTitle,
          child: _BarList(
            values: summary.boxCounts,
            labels: <String>[
              l10n.cardStatusNew,
              for (var i = 1; i <= 8; i++) '$i',
            ],
          ),
        ),
        const SizedBox(height: MxSpacing.space3),
        _StatsCard(
          title: l10n.statsForecastTitle,
          child: _BarList(
            values: summary.dueForecast,
            labels: <String>[
              for (var i = 0; i < summary.dueForecast.length; i++)
                l10n.statsDayOffset(i),
            ],
          ),
        ),
        const SizedBox(height: MxSpacing.space3),
        _StatsCard(
          title: l10n.statsActivityTitle,
          child: _ActivityBars(activity: summary.activity),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: MxRadius.cardRadius,
    ),
    child: Padding(
      padding: const EdgeInsets.all(MxSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: MxSpacing.space3),
          child,
        ],
      ),
    ),
  );
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.summary});

  final StatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final masteredPercent = (summary.masteredProgress * 100).round();
    return _StatsCard(
      title: l10n.statsOverviewTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _Stat(value: '${summary.pairs}', label: l10n.statsPairs),
              ),
              Expanded(
                child: _Stat(value: '${summary.decks}', label: l10n.statsDecks),
              ),
              Expanded(
                child: _Stat(
                  value: '${summary.words}',
                  label: l10n.dashboardWords,
                ),
              ),
            ],
          ),
          const SizedBox(height: MxSpacing.space3),
          ClipRRect(
            borderRadius: MxRadius.pillRadius,
            child: LinearProgressIndicator(
              value: summary.masteredProgress,
              minHeight: MxSpacing.space2,
            ),
          ),
          const SizedBox(height: MxSpacing.space1),
          Text(
            l10n.dashboardMastered(masteredPercent),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Text(value, style: theme.textTheme.headlineSmall),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Horizontal bars normalized to the largest value.
class _BarList extends StatelessWidget {
  const _BarList({required this.values, required this.labels});

  final List<int> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = values.fold<int>(1, (m, v) => v > m ? v : m);
    return Column(
      children: <Widget>[
        for (var i = 0; i < values.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: MxSpacing.space2),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: MxSpacing.space9,
                  child: Text(labels[i], style: theme.textTheme.bodySmall),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: MxRadius.pillRadius,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: (values[i] / max).clamp(0.0, 1.0),
                        child: Container(
                          height: MxSpacing.space3,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MxSpacing.space7,
                  child: Text(
                    '${values[i]}',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Vertical activity bars (seconds per day).
class _ActivityBars extends StatelessWidget {
  const _ActivityBars({required this.activity});

  final List<ActivityPoint> activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = activity.fold<int>(1, (m, a) => a.seconds > m ? a.seconds : m);
    return SizedBox(
      height: MxSpacing.space11,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (final point in activity)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: FractionallySizedBox(
                  heightFactor: (point.seconds / max).clamp(0.02, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: point.seconds > 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHigh,
                      borderRadius: MxRadius.controlRadius,
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

class _StatsInsufficient extends StatelessWidget {
  const _StatsInsufficient({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(MxSpacing.space6),
      child: Text(
        message,
        key: const Key('statsInsufficient'),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(
      MxSpacing.space4,
      0,
      MxSpacing.space4,
      MxSpacing.space4,
    ),
    children: <Widget>[
      for (var i = 0; i < 3; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: MxSpacing.space3),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: MxRadius.cardRadius,
            ),
            child: const SizedBox(height: 120, width: double.infinity),
          ),
        ),
    ],
  );
}

class _StatsError extends StatelessWidget {
  const _StatsError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(message),
        const SizedBox(height: MxSpacing.space3),
        FilledButton(onPressed: onRetry, child: Text(retryLabel)),
      ],
    ),
  );
}
