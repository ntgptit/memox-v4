import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/dashboard/providers/dashboard_providers.dart';
import 'package:memox_v4/presentation/features/dashboard/widgets/continue_deck_card.dart';
import 'package:memox_v4/presentation/features/dashboard/widgets/goal_card.dart';
import 'package:memox_v4/presentation/features/dashboard/widgets/streak_card.dart';
import 'package:memox_v4/presentation/features/dashboard/widgets/today_summary.dart';
import 'package:memox_v4/presentation/shared/composites/mx_action_callout.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_section_header.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_avatar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// The Today screen (S.01) — the app's pilot feature screen. Reads DM.5 use-case
/// state through [dashboardControllerProvider] and renders every kit state
/// (`docs/design/screen-state-matrix.md`, dashboard rows) with `AsyncValue.when`.
/// State lives in the provider (no `setState`); navigation stays here, out of the
/// provider. All copy is from ARB.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  /// Time-of-day thresholds for the greeting (local hours).
  static const int _afternoonHour = 12;
  static const int _eveningHour = 18;

  /// Minutes/percent formatting helpers.
  static const int _minutesPerHour = 60;
  static const int _percentScale = 100;

  /// Presentational icon + tone per due-deck row — the deck entity has no art, so
  /// the screen cycles the kit's palette by position (documented gap).
  static const List<(IconData, MxIconTileTone)> _deckPalette = [
    (Icons.translate, MxIconTileTone.accent),
    (Icons.menu_book, MxIconTileTone.warning),
    (Icons.record_voice_over, MxIconTileTone.success),
    (Icons.style, MxIconTileTone.primary),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).now();
    final async = ref.watch(dashboardControllerProvider);
    final appBar = _appBar(context, now);

    return async.when(
      loading: () => MxScaffold(appBar: appBar, children: _loadingBody()),
      error: (_, _) =>
          MxScaffold(appBar: appBar, children: [_ErrorBody(onRetry: () => _retry(ref))]),
      data: (data) => _loaded(context, appBar, data),
    );
  }

  void _retry(WidgetRef ref) => ref.invalidate(dashboardControllerProvider);

  // ── App bar (constant across states) ───────────────────────────────────────

  MxAppBar _appBar(BuildContext context, DateTime now) {
    final l10n = AppLocalizations.of(context);
    return MxAppBar(
      large: true,
      eyebrow: DateFormat('EEEE · d MMM').format(now),
      title: _greeting(l10n, now),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxIconButton(
            icon: Icons.notifications_outlined,
            semanticLabel: l10n.dashboardNotifications,
            onPressed: () => context.push(Routes.reminder),
          ),
          const SizedBox(width: MxSpacing.space2),
          // Decorative in v1 — there is no account/profile entity yet, so the
          // avatar carries no initials; the Profile tab owns navigation.
          const MxAvatar(size: MxAvatarSize.small),
        ],
      ),
    );
  }

  String _greeting(AppLocalizations l10n, DateTime now) {
    if (now.hour < _afternoonHour) return l10n.dashboardGreetingMorning;
    if (now.hour < _eveningHour) return l10n.dashboardGreetingAfternoon;
    return l10n.dashboardGreetingEvening;
  }

  // ── Loaded / empty / goal-met / streak-reset ───────────────────────────────

  Widget _loaded(BuildContext context, MxAppBar appBar, DashboardData data) {
    final isEmpty = data.status == DashboardStatus.empty;

    return MxScaffold(
      appBar: appBar,
      fab: isEmpty ? null : _reviewFab(context),
      children: [
        ?_banner(context, data.status),
        TodaySummary(
          time: _formatTime(data.minutes),
          words: '${data.words}',
          action: isEmpty ? _startButton(context) : null,
        ),
        if (!isEmpty) ...[
          GoalCard(
            goal: data.goal,
            minutes: data.minutes,
            words: data.words,
            percent: data.goalPercent,
            met: data.goalMet,
          ),
          _statRow(data),
          _continueHeader(context, data.dueDecks.length),
          for (final (index, deck) in data.dueDecks.indexed)
            _deckCard(context, deck, index),
        ],
      ],
    );
  }

  Widget? _banner(BuildContext context, DashboardStatus status) {
    final l10n = AppLocalizations.of(context);
    return switch (status) {
      DashboardStatus.empty => MxActionCallout(
          tone: MxCalloutTone.primary,
          icon: Icons.bolt,
          text: l10n.dashboardEmptyBanner,
        ),
      DashboardStatus.goalMet => MxActionCallout(
          tone: MxCalloutTone.success,
          icon: Icons.celebration,
          text: l10n.dashboardGoalMetBanner,
        ),
      DashboardStatus.streakReset => MxActionCallout(
          tone: MxCalloutTone.warning,
          icon: Icons.local_fire_department,
          text: l10n.dashboardStreakResetBanner,
        ),
      DashboardStatus.loaded => null,
    };
  }

  Widget _statRow(DashboardData data) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: StreakCard(streak: data.streak.current)),
          const SizedBox(width: MxSpacing.space3),
          Expanded(child: _MasteredCard(percent: data.masteredPercent)),
        ],
      ),
    );
  }

  Widget _continueHeader(BuildContext context, int dueDeckCount) {
    final l10n = AppLocalizations.of(context);
    return MxSectionHeader(
      title: l10n.dashboardContinueTitle,
      caption: l10n.dashboardDecksDueCaption(dueDeckCount),
      actionLabel: l10n.dashboardSeeAll,
      onAction: () => context.go(Routes.library),
    );
  }

  Widget _deckCard(BuildContext context, DashboardDeck deck, int index) {
    final (icon, tone) = _deckPalette[index % _deckPalette.length];
    return ContinueDeckCard(
      deck: deck,
      icon: icon,
      tone: tone,
      onPressed: () => context.go(Routes.deckDetail(deck.id.value)),
    );
  }

  Widget _reviewFab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxFab(
      icon: Icons.bolt,
      label: l10n.dashboardReview,
      onPressed: () => context.push(Routes.review),
    );
  }

  Widget _startButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxButton(
      label: l10n.dashboardStartStudying,
      variant: MxButtonVariant.contrast,
      icon: Icons.play_arrow,
      block: true,
      onPressed: () => context.push(Routes.study),
    );
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ _minutesPerHour;
    final m = minutes % _minutesPerHour;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  // ── Loading skeleton ───────────────────────────────────────────────────────

  List<Widget> _loadingBody() {
    return [
      const MxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MxSkeleton(width: 120, height: 12),
            SizedBox(height: MxSpacing.space2),
            MxSkeleton(width: 180, height: 30),
          ],
        ),
      ),
      const IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _SkeletonMini()),
            SizedBox(width: MxSpacing.space3),
            Expanded(child: _SkeletonMini()),
          ],
        ),
      ),
      const MxSkeleton(width: 160, height: 16),
      const _SkeletonRow(),
      const _SkeletonRow(),
    ];
  }
}

/// The mastered-percentage stat (kit `dashboard/mastered`) — sits beside the
/// streak card. Inline to the screen (not one of the four named local
/// components). Copy is from ARB.
class _MasteredCard extends StatelessWidget {
  const _MasteredCard({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      variant: MxCardVariant.muted,
      padding: MxCardPadding.small,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.verified, size: MxIconSize.md, color: mx.success),
          const SizedBox(width: MxSpacing.space3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(percent * DashboardScreen._percentScale).round()}%',
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxIconSize.md,
                  fontWeight: MxTypography.extrabold,
                  height: MxTypography.lineHeightNone,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                l10n.dashboardMasteredLabel,
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeXs,
                  color: mx.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Localized error surface for a failed dashboard load (the cause is logged in
/// [dashboardControllerProvider]). Offers a retry that re-runs the load.
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MxSpacing.space8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: MxIconSize.lg, color: scheme.error),
          const SizedBox(height: MxSpacing.space3),
          Text(
            l10n.dashboardErrorTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeMd,
              fontWeight: MxTypography.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: MxSpacing.space1),
          Text(
            l10n.dashboardErrorBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeBase,
              color: mx.textSecondary,
            ),
          ),
          const SizedBox(height: MxSpacing.space4),
          MxButton(
            label: l10n.actionRetry,
            variant: MxButtonVariant.secondary,
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _SkeletonMini extends StatelessWidget {
  const _SkeletonMini();

  @override
  Widget build(BuildContext context) {
    return const MxCard(
      padding: MxCardPadding.small,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxSkeleton(width: 80, height: 22),
          SizedBox(height: MxSpacing.space2),
          MxSkeleton(width: 60, height: 10),
        ],
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const MxCard(
      padding: MxCardPadding.small,
      child: Row(
        children: [
          MxSkeleton(width: 48, height: 48, radius: 16),
          SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxSkeleton(width: 140, height: 14),
                SizedBox(height: MxSpacing.space2),
                MxSkeleton(width: 90, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
