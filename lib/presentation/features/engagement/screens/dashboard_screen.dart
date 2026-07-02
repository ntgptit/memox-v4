import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
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
    final decks = ref.watch(libraryProvider).value ?? const <DeckNode>[];
    final dueDecks = <DeckNode>[
      for (final node in decks)
        if (node.stats.due > 0) node,
    ];
    final status = _DashboardStatus.from(summary);
    return MxContentBounds(
      applyGutter: false,
      child: ListView(
        key: const Key('dashboard'),
        padding: const EdgeInsets.fromLTRB(
          MxSpacing.gutter,
          MxSpacing.space4,
          MxSpacing.gutter,
          MxSpacing.space6,
        ),
        children: <Widget>[
          if (status == _DashboardStatus.empty) ...<Widget>[
            _DashboardNote(
              icon: Icons.bolt,
              text: l10n.dashboardEmptyHint,
              tone: _DashboardNoteTone.accent,
            ),
            const SizedBox(height: MxSpacing.space3),
          ],
          if (status == _DashboardStatus.goalMet) ...<Widget>[
            _DashboardNote(
              icon: Icons.check_circle,
              text: l10n.dashboardGoalMetBanner,
              tone: _DashboardNoteTone.success,
            ),
            const SizedBox(height: MxSpacing.space3),
          ],
          if (status == _DashboardStatus.streakReset) ...<Widget>[
            _DashboardNote(
              icon: Icons.local_fire_department,
              text: l10n.dashboardStreakResetHint,
              tone: _DashboardNoteTone.warning,
            ),
            const SizedBox(height: MxSpacing.space3),
          ],
          _TodayCard(
            summary: summary,
            empty: status == _DashboardStatus.empty,
            onStart: () => context.go(RoutePaths.root),
          ),
          // The kit's empty state is minimal — only the note + TODAY/Start card.
          // The goal / streak-mastered / decks stack appears once there is activity.
          if (status != _DashboardStatus.empty) ...<Widget>[
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
              key: const ValueKey('mx-node:dashboard/decks-head'),
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

enum _DashboardStatus {
  empty,
  progressing,
  goalMet,
  streakReset;

  static _DashboardStatus from(EngagementSummary summary) {
    if (!summary.hasActivity) return _DashboardStatus.empty;
    if (summary.goalMet) return _DashboardStatus.goalMet;
    if (summary.streak.days == 0) return _DashboardStatus.streakReset;
    return _DashboardStatus.progressing;
  }
}

/// The primary "TODAY" hero card: time studied + words learned.
class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.summary,
    required this.empty,
    required this.onStart,
  });

  final EngagementSummary summary;
  final bool empty;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      key: const ValueKey('mx-node:dashboard/today'),
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
          if (empty) ...<Widget>[
            const SizedBox(height: MxSpacing.space4),
            MxButton(
              key: const ValueKey('mx-node:dashboard/start'),
              label: l10n.dashboardStartStudying,
              onPressed: onStart,
              variant: MxButtonVariant.contrast,
              icon: Icons.play_arrow,
              block: true,
            ),
          ],
        ],
      ),
    );
  }
}

enum _DashboardNoteTone { accent, success, warning }

class _DashboardNote extends StatelessWidget {
  const _DashboardNote({
    required this.icon,
    required this.text,
    required this.tone,
  });

  final IconData icon;
  final String text;
  final _DashboardNoteTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = MxTheme.of(context).colors;
    final (background, foreground) = switch (tone) {
      _DashboardNoteTone.accent => (colors.primarySoft, colors.onPrimarySoft),
      _DashboardNoteTone.success => (colors.successSoft, colors.onSuccessSoft),
      _DashboardNoteTone.warning => (colors.warningSoft, colors.onWarningSoft),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: MxRadius.controlRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MxSpacing.space4,
          vertical: MxSpacing.space3,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: foreground, size: MxSpacing.space5),
            const SizedBox(width: MxSpacing.space2),
            Expanded(
              child: MxText(
                text,
                role: MxTextRole.bodySmall,
                color: foreground,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
        key: const ValueKey('mx-node:dashboard/goal'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // kit: font-size-md/extrabold (17/800) — titleLarge is the same 17px
            // step; only the weight needs the override.
            MxText(
              l10n.dashboardGoalTitle,
              role: MxTextRole.titleLarge,
              weight: FontWeight.w800,
            ),
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
    final goal = summary.goal;
    final met = summary.goalMet;
    // Progress in the goal's own unit (minutes if set, else words) — the kit's
    // "14/20 min" line, with a "· complete" suffix when met.
    final progress = goal.minutes != null && goal.minutes! > 0
        ? l10n.dashboardGoalProgressMinutes(
            summary.seconds ~/ 60,
            goal.minutes!,
            '$met',
          )
        : l10n.dashboardGoalProgressWords(summary.words, goal.words!, '$met');
    return MxCard(
      key: const ValueKey('mx-node:dashboard/goal'),
      child: Row(
        children: <Widget>[
          _GoalRing(progress: summary.goalProgress),
          const SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // kit: font-size-md/extrabold (17/800) — titleLarge is the same 17px
                // step; only the weight needs the override.
                MxText(
                  l10n.dashboardGoalTitle,
                  role: MxTextRole.titleLarge,
                  weight: FontWeight.w800,
                ),
                const SizedBox(height: MxSpacing.space1),
                MxText(
                  progress,
                  role: MxTextRole.bodyMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: MxSpacing.space1),
                MxText(
                  l10n.dashboardGoalHint,
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
    // The kit ring shows the percentage in the centre for every state (no check
    // icon) — "complete" is signalled by the full ring + the success note banner.
    // Diameter = the kit element-size token `--memox-size-md` (56), NOT a spacing
    // step — the ring is a fixed-size visual element, not layout spacing.
    return SizedBox(
      width: MxSizes.sizeMd,
      height: MxSizes.sizeMd,
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
      key: const ValueKey('mx-node:dashboard/streak'),
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
                // kit: the stat figure borrows --memox-icon-size-md (22px), not a
                // type-scale step — headlineSmall(20) is the nearest role for
                // weight/line-height/tracking; fontSize overrides just the px.
                MxText(
                  '$days',
                  role: MxTextRole.headlineSmall,
                  weight: FontWeight.w800,
                  fontSize: MxIconSize.md,
                ),
                MxText(
                  l10n.dashboardDayStreak,
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
      key: const ValueKey('mx-node:dashboard/mastered'),
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
                // kit: same icon-size-md (22px) stat-figure borrow as streak.
                MxText(
                  '$percent%',
                  role: MxTextRole.headlineSmall,
                  weight: FontWeight.w800,
                  fontSize: MxIconSize.md,
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
          const SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // kit: 15/700 — titleMedium is the same 15px step; only the
                // weight needs the override.
                MxText(
                  node.deck.name,
                  role: MxTextRole.titleMedium,
                  weight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // kit: 13/400 — bodySmall matches both size and weight exactly.
                MxText(
                  l10n.deckCardsDue(node.stats.words, node.stats.due),
                  role: MxTextRole.bodySmall,
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
          const SizedBox(width: MxSpacing.space4),
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
