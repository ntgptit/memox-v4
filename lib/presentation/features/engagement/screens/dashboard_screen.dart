import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/models/engagement_summary.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck/viewmodels/library_notifier.dart';
import 'package:memox_v4/presentation/features/engagement/viewmodels/engagement_notifier.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_badge.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// Today tab — laid out to the design kit's Dashboard mockup: a primary "TODAY"
/// hero, a daily-goal ring, a streak/mastered grid, and the due-deck list.
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

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.summary});

  final EngagementSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = MxTheme.of(context).colors;
    final date = MaterialLocalizations.of(
      context,
    ).formatFullDate(DateTime.now());
    final decks = ref.watch(libraryProvider).value ?? const <DeckNode>[];
    final dueDecks = <DeckNode>[
      for (final node in decks)
        if (node.stats.due > 0) node,
    ];
    return MxContentBounds(
      child: ListView(
        key: const Key('dashboard'),
        padding: const EdgeInsets.all(MxSpacing.space4),
        children: <Widget>[
          MxText(
            date,
            role: MxTextRole.labelMedium,
            color: colors.textSecondary,
          ),
          MxText(
            _greeting(l10n),
            role: MxTextRole.displaySmall,
            weight: FontWeight.w800,
          ),
          const SizedBox(height: MxSpacing.space4),
          _TodayCard(summary: summary),
          const SizedBox(height: MxSpacing.space3),
          _GoalCard(summary: summary),
          const SizedBox(height: MxSpacing.space3),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: _StreakCard(summary: summary)),
                const SizedBox(width: MxSpacing.space3),
                Expanded(child: _MasteredCard(summary: summary)),
              ],
            ),
          ),
          const SizedBox(height: MxSpacing.space5),
          MxSectionHeader(
            title: l10n.dashboardContinueStudying,
            caption: l10n.dashboardDecksDue(dueDecks.length),
            action: l10n.commonSeeAll,
            onAction: () => context.go(RoutePaths.root),
          ),
          for (var i = 0; i < dueDecks.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: MxSpacing.space2),
              child: _DeckRow(node: dueDecks[i], tone: _toneFor(i)),
            ),
        ],
      ),
    );
  }

  MxIconTileTone _toneFor(int index) => switch (index % 3) {
    0 => MxIconTileTone.accent,
    1 => MxIconTileTone.warning,
    _ => MxIconTileTone.success,
  };
}

/// The primary "TODAY" hero card: time studied + words learned.
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.summary});

  final EngagementSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      variant: MxCardVariant.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MxText(
            l10n.dashboardTodayLabel,
            role: MxTextRole.labelMedium,
            weight: FontWeight.w700,
          ),
          const SizedBox(height: MxSpacing.space2),
          Row(
            children: <Widget>[
              _HeroStat(
                value: _formatDuration(summary.seconds),
                label: l10n.dashboardTimeStudiedLabel,
              ),
              const SizedBox(width: MxSpacing.space7),
              _HeroStat(
                value: '${summary.words}',
                label: l10n.dashboardWordsLearned,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      MxText(value, role: MxTextRole.displaySmall, weight: FontWeight.w800),
      MxText(label, role: MxTextRole.bodySmall),
    ],
  );
}

/// Daily goal card: a progress ring + the goal copy.
class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.summary});

  final EngagementSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = MxTheme.of(context).colors;
    if (!summary.goal.hasGoal) {
      return MxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MxText.title(l10n.dashboardGoalTitle),
            const SizedBox(height: MxSpacing.space1),
            MxText(
              l10n.dashboardGoalNone,
              key: const Key('dashboardGoalNone'),
              role: MxTextRole.bodyMedium,
              color: colors.textSecondary,
            ),
          ],
        ),
      );
    }
    return MxCard(
      child: Row(
        children: <Widget>[
          _GoalRing(progress: summary.goalProgress),
          const SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText.title(l10n.dashboardGoalTitle),
                const SizedBox(height: MxSpacing.space1),
                MxText(
                  summary.goalMet
                      ? l10n.dashboardGoalMet
                      : l10n.dashboardGoalHint,
                  role: MxTextRole.bodySmall,
                  color: colors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = MxTheme.of(context).colors;
    return SizedBox(
      width: MxSpacing.space11,
      height: MxSpacing.space11,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: MxSpacing.space2 - 1,
              backgroundColor: colors.surfaceSunken,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          MxText(
            '${(progress * 100).round()}%',
            role: MxTextRole.labelLarge,
            weight: FontWeight.w800,
          ),
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
    final days = summary.streak.days;
    return MxCard(
      variant: MxCardVariant.primarySoft,
      padding: MxCardPadding.sm,
      child: Row(
        children: <Widget>[
          const Icon(Icons.local_fire_department, size: MxSpacing.space6),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  '$days',
                  role: MxTextRole.titleLarge,
                  weight: FontWeight.w800,
                ),
                MxText(
                  days > 0 ? l10n.dashboardDayStreak : l10n.dashboardStreakNone,
                  key: const Key('dashboardStreak'),
                  role: MxTextRole.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteredCard extends StatelessWidget {
  const _MasteredCard({required this.summary});

  final EngagementSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = MxTheme.of(context).colors;
    final percent = (summary.masteredProgress * 100).round();
    return MxCard(
      variant: MxCardVariant.muted,
      padding: MxCardPadding.sm,
      child: Row(
        children: <Widget>[
          Icon(Icons.verified, size: MxSpacing.space6, color: colors.success),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  '$percent%',
                  role: MxTextRole.titleLarge,
                  weight: FontWeight.w800,
                ),
                MxText(
                  l10n.dashboardMasteredLabel,
                  role: MxTextRole.labelSmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A due-deck row under "Continue studying".
class _DeckRow extends StatelessWidget {
  const _DeckRow({required this.node, required this.tone});

  final DeckNode node;
  final MxIconTileTone tone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = MxTheme.of(context).colors;
    return MxCard(
      padding: MxCardPadding.sm,
      interactive: true,
      onTap: () => context.push(
        RoutePaths.studyLocation(node.deck.id, StudyEntry.dueReview),
      ),
      child: Row(
        children: <Widget>[
          MxIconTile(icon: Icons.translate, tone: tone),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  node.deck.name,
                  role: MxTextRole.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                MxText(
                  l10n.deckCardsDue(node.stats.words, node.stats.due),
                  role: MxTextRole.labelSmall,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: MxSpacing.space1),
                ClipRRect(
                  borderRadius: MxRadius.pillRadius,
                  child: LinearProgressIndicator(
                    value: node.stats.progress,
                    minHeight: MxSpacing.space1,
                    backgroundColor: colors.surfaceSunken,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: MxSpacing.space3),
          MxBadge(
            label: '${node.stats.due}',
            tone: MxBadgeTone.warning,
            soft: true,
          ),
        ],
      ),
    );
  }
}

String _greeting(AppLocalizations l10n) {
  final hour = DateTime.now().hour;
  if (hour < 12) return l10n.dashboardGreetingMorning;
  if (hour < 18) return l10n.dashboardGreetingAfternoon;
  return l10n.dashboardGreetingEvening;
}

String _formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}';
}

/// A rounded surface used by the loading/error blocks.
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

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) => MxContentBounds(
    child: ListView(
      padding: const EdgeInsets.all(MxSpacing.space4),
      children: <Widget>[
        for (var i = 0; i < 3; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: MxSpacing.space3),
            child: _Card(
              child: SizedBox(
                height: MxSpacing.space12,
                width: double.infinity,
              ),
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
          MxText(message),
          const SizedBox(height: MxSpacing.space3),
          MxButton(label: retryLabel, onPressed: onRetry),
        ],
      ),
    ),
  );
}
