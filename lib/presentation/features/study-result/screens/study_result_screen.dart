import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/study-result/providers/study_result_providers.dart';
import 'package:memox_v4/presentation/features/study-result/widgets/cta.dart';
import 'package:memox_v4/presentation/features/study-result/widgets/finalizing_view.dart';
import 'package:memox_v4/presentation/features/study-result/widgets/result_hero.dart';
import 'package:memox_v4/presentation/features/study-result/widgets/streak_goal_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';

/// Fixed height for the finalize-error box (icon + copy + a two-button column).
const double _errorBoxHeight = 460;

/// The Study result (S.21): the post-session summary — a headline shaped by
/// today's goal progress, the day's stats, the streak + goal card, and a
/// state-dependent CTA pair. Reads through [studyResultControllerProvider],
/// rendered with `AsyncValue.when` — the loading branch is the finalizing view, a
/// failed read is the finalize-error surface. No `setState`. Copy is from ARB.
class StudyResultScreen extends ConsumerWidget {
  const StudyResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(studyResultControllerProvider);
    // A loading pass that follows a Retry is a re-attempt → "Retrying…".
    final retrying = ref.watch(finalizeRetryingProvider);

    return async.when(
      loading: () =>
          FinalizingView(retry: retrying, onClose: () => _home(context)),
      error: (_, _) => MxScaffold(
        appBar: _bar(context, l10n),
        children: [
          SizedBox(
            height: _errorBoxHeight,
            child: MxEmptyState(
              icon: Icons.cloud_off,
              tone: MxIconTileTone.error,
              title: l10n.resultErrorTitle,
              text: l10n.resultErrorText,
              action: SizedBox(
                width: MxSizes.size3xl,
                child: Column(
                  children: [
                    MxButton(
                      label: l10n.resultErrorRetry,
                      icon: Icons.refresh,
                      block: true,
                      onPressed: () {
                        // Reframe the next finalizing pass as a re-attempt.
                        ref
                            .read(finalizeRetryingProvider.notifier)
                            .markRetry();
                        ref.invalidate(studyResultControllerProvider);
                      },
                    ),
                    const SizedBox(height: MxSpacing.space3),
                    MxButton(
                      label: l10n.resultErrorLater,
                      variant: MxButtonVariant.ghost,
                      block: true,
                      onPressed: () => _home(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      data: (data) => _content(context, l10n, data),
    );
  }

  MxAppBar _bar(BuildContext context, AppLocalizations l10n) => MxAppBar(
        title: l10n.resultTitle,
        leading: MxIconButton(
          icon: Icons.close,
          semanticLabel: l10n.resultClose,
          onPressed: () => _home(context),
        ),
      );

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    StudyResultData data,
  ) {
    final (icon, tone, title, text) = _head(l10n, data.head);

    return MxScaffold(
      appBar: _bar(context, l10n),
      children: [
        ResultHero(icon: icon, tone: tone, title: title, text: text),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: l10n.resultStatWords(data.words),
                label: l10n.resultStatWordsLabel,
              ),
            ),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: _StatTile(
                value: l10n.resultStatMinutes(data.minutes),
                label: l10n.resultStatMinutesLabel,
              ),
            ),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: _StatTile(
                value: l10n.resultPercent(data.goalPercentInt),
                label: l10n.resultStatGoalLabel,
              ),
            ),
          ],
        ),
        StreakGoalCard(
          streakLabel: l10n.resultStreakDays(data.streak.current),
          streakCaption:
              data.goalMet ? l10n.resultStreakCaptionPlus : l10n.resultStreakCaption,
          goalLabel: l10n.resultGoalToday,
          goalValue: _goalValue(l10n, data),
          goalPercent: data.goalPercent,
        ),
        Cta(
          head: data.head,
          wrongCount: data.wrongCount,
          onPrimary: () => context.go(Routes.study),
          onSecondary: () => data.head == ResultHead.goalMissed
              ? _home(context)
              : context.go(Routes.library),
        ),
      ],
    );
  }

  (IconData, MxIconTileTone, String, String) _head(
    AppLocalizations l10n,
    ResultHead head,
  ) =>
      switch (head) {
        ResultHead.manyWrong => (
            Icons.replay,
            MxIconTileTone.error,
            l10n.resultManyWrongTitle,
            l10n.resultManyWrongText,
          ),
        ResultHead.goalMet => (
            Icons.celebration,
            MxIconTileTone.success,
            l10n.resultGoalMetTitle,
            l10n.resultGoalMetText,
          ),
        ResultHead.goalMissed => (
            Icons.trending_up,
            MxIconTileTone.warning,
            l10n.resultGoalMissedTitle,
            l10n.resultGoalMissedText,
          ),
        ResultHead.standard => (
            Icons.task_alt,
            MxIconTileTone.accent,
            l10n.resultStandardTitle,
            l10n.resultStandardText,
          ),
      };

  String _goalValue(AppLocalizations l10n, StudyResultData data) {
    final DailyGoal goal = data.goal;
    final minutesTarget = goal.minutesTarget;
    if (minutesTarget != null) {
      return l10n.resultGoalMinutes(data.minutes, minutesTarget);
    }
    final wordsTarget = goal.wordsTarget;
    if (wordsTarget != null) {
      return l10n.resultGoalWords(data.words, wordsTarget);
    }
    return l10n.resultGoalNone;
  }

  void _home(BuildContext context) => context.go(Routes.today);
}

/// One stat tile in the result summary (kit `study-result/stat-*`).
class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      variant: MxCardVariant.muted,
      padding: MxCardPadding.small,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeXl,
              fontWeight: MxTypography.extrabold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: MxSpacing.space1),
          Text(
            label,
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
