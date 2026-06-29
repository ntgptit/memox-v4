import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/domain/models/statistics_summary.dart';
import 'package:memox_v4/domain/types/stats_scope.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/statistics/viewmodels/statistics_notifier.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/inputs/mx_segmented_control.dart';

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
        key: const ValueKey('mx-node:statistics/screen'),
        children: <Widget>[
          Padding(
            key: const ValueKey('mx-node:statistics/appbar'),
            padding: const EdgeInsets.all(MxSpacing.space4),
            child: MxSegmentedControl(
              segments: <MxSegment>[
                (
                  value: StatsScope.currentPair.name,
                  label: l10n.statsScopeCurrentPair,
                  icon: null,
                ),
                (
                  value: StatsScope.allApp.name,
                  label: l10n.statsScopeAllApp,
                  icon: null,
                ),
              ],
              value: scope.name,
              onChanged: (v) => ref
                  .read(statsScopeProvider.notifier)
                  .set(StatsScope.values.byName(v)),
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
        if (summary.hasReviews) ...<Widget>[
          const SizedBox(height: MxSpacing.space3),
          _StatsCard(
            headKey: const ValueKey('mx-node:statistics/accuracy-head'),
            title: l10n.statsAccuracyTitle,
            child: _Accuracy(summary: summary),
          ),
        ],
        const SizedBox(height: MxSpacing.space3),
        _StatsCard(
          headKey: const ValueKey('mx-node:statistics/leitner-head'),
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
          headKey: const ValueKey('mx-node:statistics/weekly-head'),
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
          headKey: const ValueKey('mx-node:statistics/heatmap-head'),
          title: l10n.statsHeatmapTitle,
          child: _Heatmap(activity: summary.activity),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.title, required this.child, this.headKey});

  final String title;
  final Widget child;
  final Key? headKey;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    // The kit treats each section head as its surface card (bg:surface r:20), so
    // the head node identity lives on the card root.
    key: headKey,
    decoration: BoxDecoration(
      color: MxTheme.of(context).colors.surface,
      borderRadius: MxRadius.cardRadius,
    ),
    child: Padding(
      padding: const EdgeInsets.all(MxSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MxText.title(title),
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
      headKey: const ValueKey('mx-node:statistics/overview-head'),
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
          MxText(
            l10n.dashboardMastered(masteredPercent),
            role: MxTextRole.bodySmall,
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
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      MxText.headline(value),
      MxText(
        label,
        role: MxTextRole.bodySmall,
        color: MxTheme.of(context).colors.textSecondary,
      ),
    ],
  );
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
                  child: MxText(labels[i], role: MxTextRole.bodySmall),
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
                  child: MxText(
                    '${values[i]}',
                    role: MxTextRole.bodySmall,
                    textAlign: TextAlign.end,
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
/// Review-accuracy ratio (correct / total) for the scope.
class _Accuracy extends StatelessWidget {
  const _Accuracy({required this.summary});

  final StatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percent = (summary.accuracy * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: MxRadius.pillRadius,
                child: LinearProgressIndicator(
                  value: summary.accuracy,
                  minHeight: MxSpacing.space2,
                ),
              ),
            ),
            const SizedBox(width: MxSpacing.space3),
            MxText.title('$percent%'),
          ],
        ),
        const SizedBox(height: MxSpacing.space1),
        MxText(
          l10n.statsAccuracyDetail(
            summary.accuracyCorrect,
            summary.accuracyTotal,
          ),
          role: MxTextRole.bodySmall,
          color: MxTheme.of(context).colors.textSecondary,
        ),
      ],
    );
  }
}

/// A calendar heatmap: one square per day, shaded by time studied.
class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.activity});

  final List<ActivityPoint> activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = activity.fold<int>(1, (m, a) => a.seconds > m ? a.seconds : m);
    return Wrap(
      spacing: MxSpacing.space1,
      runSpacing: MxSpacing.space1,
      children: <Widget>[
        for (final point in activity)
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: MxRadius.controlRadius,
              color: point.seconds == 0
                  ? theme.colorScheme.surfaceContainerHigh
                  : theme.colorScheme.primary.withValues(
                      alpha: (0.3 + 0.7 * (point.seconds / max)).clamp(
                        0.0,
                        1.0,
                      ),
                    ),
            ),
            child: const SizedBox(
              width: MxSpacing.space3,
              height: MxSpacing.space3,
            ),
          ),
      ],
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
      child: MxText(
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
        MxText(message),
        const SizedBox(height: MxSpacing.space3),
        MxButton(label: retryLabel, onPressed: onRetry),
      ],
    ),
  );
}
