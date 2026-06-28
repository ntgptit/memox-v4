import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/models/engagement_summary.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/engagement/viewmodels/engagement_notifier.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';

/// Today tab — effort, daily goal, streak and shortcuts (`02-dashboard.md`).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(engagementProvider);
    return summary.when(
      loading: () => const _DashboardSkeleton(),
      error: (_, _) => _DashboardError(
        message: l10n.dashboardError,
        onRetry: () => ref.read(engagementProvider.notifier).refresh(),
        retryLabel: l10n.commonRetry,
      ),
      data: (data) => _DashboardBody(summary: data),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.summary});

  final EngagementSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = MaterialLocalizations.of(
      context,
    ).formatFullDate(DateTime.now());
    return MxContentBounds(
      child: ListView(
        key: const Key('dashboard'),
        padding: const EdgeInsets.all(MxSpacing.space4),
        children: <Widget>[
          Text(
            l10n.dashboardGreeting,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(date, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: MxSpacing.space4),
          _ActivityCard(summary: summary),
          const SizedBox(height: MxSpacing.space3),
          _GoalCard(summary: summary),
          const SizedBox(height: MxSpacing.space3),
          _StreakCard(summary: summary),
          const SizedBox(height: MxSpacing.space3),
          _ShortcutsCard(summary: summary),
        ],
      ),
    );
  }
}

/// A rounded surface used by every dashboard block.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: MxRadius.cardRadius,
    ),
    child: Padding(
      padding: const EdgeInsets.all(MxSpacing.space4),
      child: child,
    ),
  );
}

String _formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}';
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.summary});

  final EngagementSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.drawerActivityTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: MxSpacing.space3),
          Row(
            children: <Widget>[
              Expanded(
                child: _Metric(
                  icon: Icons.timer_outlined,
                  label: l10n.dashboardTimeStudied,
                  value: _formatDuration(summary.seconds),
                ),
              ),
              Expanded(
                child: _Metric(
                  icon: Icons.translate,
                  label: l10n.dashboardWords,
                  value: '${summary.words}',
                ),
              ),
            ],
          ),
          if (!summary.hasActivity) ...<Widget>[
            const SizedBox(height: MxSpacing.space3),
            Text(
              l10n.dashboardEmptyHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: MxSpacing.space1),
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

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.summary});

  final EngagementSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.dashboardGoalTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (summary.goalMet)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: MxSpacing.space3),
          if (!summary.goal.hasGoal)
            Text(
              l10n.dashboardGoalNone,
              key: const Key('dashboardGoalNone'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...<Widget>[
            ClipRRect(
              borderRadius: MxRadius.pillRadius,
              child: LinearProgressIndicator(
                value: summary.goalProgress,
                minHeight: MxSpacing.space2,
              ),
            ),
            const SizedBox(height: MxSpacing.space2),
            Text(
              summary.goalMet ? l10n.dashboardGoalMet : l10n.dashboardGoalHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.summary});

  final EngagementSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final days = summary.streak.days;
    return _Card(
      child: Row(
        children: <Widget>[
          Icon(
            Icons.local_fire_department,
            size: MxSpacing.space8,
            color: days > 0
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.dashboardStreakTitle,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  days > 0
                      ? l10n.dashboardStreakDays(days)
                      : l10n.dashboardStreakNone,
                  key: const Key('dashboardStreak'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutsCard extends StatelessWidget {
  const _ShortcutsCard({required this.summary});

  final EngagementSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final masteredPercent = (summary.masteredProgress * 100).round();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.dashboardDueCount(summary.dueCount),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: MxSpacing.space1),
          Text(
            l10n.dashboardMastered(masteredPercent),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: MxSpacing.space3),
          FilledButton.icon(
            key: const Key('dashboardContinue'),
            onPressed: () => context.go(RoutePaths.root),
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.dashboardContinue),
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) => MxContentBounds(
    child: ListView(
      padding: const EdgeInsets.all(MxSpacing.space4),
      children: <Widget>[
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: MxSpacing.space3),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: MxRadius.cardRadius,
              ),
              child: const SizedBox(height: 96, width: double.infinity),
            ),
          ),
      ],
    ),
  );
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) => MxContentBounds(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message),
          const SizedBox(height: MxSpacing.space3),
          FilledButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    ),
  );
}
