import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/study-session/providers/study_session_providers.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/answer_save_error_dialog.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/exit_dialog.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/resume_error_state.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/stage_choice.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/stage_matching.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/stage_recall.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/stage_review.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/stage_typing.dart';
import 'package:memox_v4/presentation/shared/composites/mx_action_callout.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// The Study session (S.20): the "Học" 5-stage NewLearn flow + "Lặp lại"
/// due-card grading, stitched into one session (DM.5). Reads the plan through
/// [studySessionControllerProvider], rendered with `AsyncValue.when` — a failed
/// build is the resume-error surface. The typing answer lives in a local
/// [TextEditingController]; session state is Riverpod-owned — no `setState`.
class StudySessionScreen extends ConsumerStatefulWidget {
  const StudySessionScreen({super.key});

  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen> {
  final TextEditingController _typed = TextEditingController();
  bool _dialogOpen = false;

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  StudySessionController get _controller =>
      ref.read(studySessionControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    ref.listen(studySessionControllerProvider, (previous, next) {
      final data = next.asData?.value;
      if (data == null) return;
      if (data.isComplete) {
        context.pushReplacement(Routes.studyResult);
        return;
      }
      if (data.saveError && !_dialogOpen) _showSaveError();
    });

    final l10n = AppLocalizations.of(context);
    final async = ref.watch(studySessionControllerProvider);

    return async.when(
      loading: () => MxScaffold(
        appBar: _bar(context, l10n),
        children: const [MxSkeleton(height: 8), SizedBox(height: MxSpacing.space5), MxSkeleton(height: 280)],
      ),
      error: (_, _) => ResumeErrorState(
        onRestart: () => ref.invalidate(studySessionControllerProvider),
        onBack: () => context.pop(),
      ),
      data: (state) => _content(context, l10n, state),
    );
  }

  MxAppBar _bar(BuildContext context, AppLocalizations l10n) => MxAppBar(
        leading: MxIconButton(
          icon: Icons.close,
          semanticLabel: l10n.studyClose,
          onPressed: _confirmExit,
        ),
      );

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    StudySessionState state,
  ) {
    if (state.isEmpty) {
      return MxScaffold(
        appBar: _bar(context, l10n),
        children: [
          SizedBox(
            height: MxSizes.size4xl,
            child: MxEmptyState(
              icon: Icons.done_all,
              title: l10n.studyEmptyTitle,
              text: l10n.studyEmptyText,
            ),
          ),
        ],
      );
    }

    if (state.isComplete) {
      // A navigation to the result screen is scheduled by the listener.
      return MxScaffold(appBar: _bar(context, l10n), children: const [
        Center(child: Padding(padding: EdgeInsets.all(MxSpacing.space6), child: CircularProgressIndicator())),
      ]);
    }

    // Invariant: past the isEmpty / isComplete guards above the index is in
    // range, so StudySessionState.current is always present here.
    final step = state.current!;
    final pct = (state.progress * 100).round();
    return MxScaffold(
      appBar: _bar(context, l10n),
      children: [
        Row(
          children: [
            Expanded(child: MxProgressBar(value: state.progress)),
            const SizedBox(width: MxSpacing.space3),
            Text(
              l10n.studyPercent(pct),
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeSm,
                fontWeight: MxTypography.bold,
                color: MxTheme.of(context).textSecondary,
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            _stageLabel(l10n, step.kind),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeSm,
              fontWeight: MxTypography.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        _body(context, l10n, state, step),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    StudySessionState state,
    StudyStep step,
  ) {
    switch (step.kind) {
      case StudyStageKind.review:
        return StageReview(
          term: step.term,
          meaning: step.meaning,
          onNext: _controller.advance,
        );
      case StudyStageKind.matching:
        return StageMatching(
          terms: step.terms,
          meanings: step.meanings,
          matched: state.step.matched,
          selectedTermId: state.step.selectedTermId,
          onSelectTerm: _controller.selectTerm,
          onSelectMeaning: _controller.selectMeaning,
        );
      case StudyStageKind.choice:
        return StageChoice(
          term: step.term,
          choices: step.choices,
          correctChoice: step.correctChoice,
          chosen: state.step.chosen,
          wrong: state.step.wrongChoice,
          onChoose: _controller.choose,
        );
      case StudyStageKind.recall:
        return StageRecall(
          term: step.term,
          meaning: step.meaning,
          revealed: state.step.revealed,
          onReveal: _controller.reveal,
          onNext: _controller.advance,
        );
      case StudyStageKind.typing:
        return StageTyping(
          meaningLabel: l10n.studyMeaningLabel,
          meaning: step.meaning,
          controller: _typed,
          hintShown: state.step.hintShown,
          hint: l10n.studyTypingHint(
            step.term.characters.length,
            step.term.characters.isEmpty ? '' : step.term.characters.first,
          ),
          onHint: _controller.showHint,
          onCheck: _checkTyping,
        );
      case StudyStageKind.dueReview:
        return _DueReview(
          term: step.term,
          meaning: step.meaning,
          onRelearn: () => _controller.gradeDue(ReviewGrade.fail),
          onNext: () => _controller.gradeDue(ReviewGrade.pass),
        );
    }
  }

  void _checkTyping() {
    _typed.clear();
    _controller.checkTyping();
  }

  Future<void> _confirmExit() async {
    final leave = await ExitDialog.show(context);
    if (leave == true && mounted) context.pop();
  }

  Future<void> _showSaveError() async {
    _dialogOpen = true;
    final choice = await AnswerSaveErrorDialog.show(context);
    _dialogOpen = false;
    if (!mounted) return;
    if (choice == AnswerSaveErrorChoice.retry) {
      await _controller.retrySave();
      return;
    }
    _controller.dismissSaveError();
  }

  String _stageLabel(AppLocalizations l10n, StudyStageKind kind) => switch (kind) {
        StudyStageKind.review => l10n.studyStageReview,
        StudyStageKind.matching => l10n.studyStageMatching,
        StudyStageKind.choice => l10n.studyStageChoice,
        StudyStageKind.recall => l10n.studyStageRecall,
        StudyStageKind.typing => l10n.studyStageTyping,
        StudyStageKind.dueReview => l10n.studyStageDue,
      };
}

/// The inline due-review body (kit `due-review` state): a note, the card, and the
/// pass/fail grade controls.
class _DueReview extends StatelessWidget {
  const _DueReview({
    required this.term,
    required this.meaning,
    required this.onRelearn,
    required this.onNext,
  });

  final String term;
  final String meaning;
  final VoidCallback onRelearn;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxActionCallout(icon: Icons.schedule, text: l10n.studyDueNote),
        const SizedBox(height: MxSpacing.space4),
        MxCard(
          child: Container(
            constraints: const BoxConstraints(minHeight: MxSizes.size3xl),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  term,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.size4xl,
                    fontWeight: MxTypography.extrabold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: MxSpacing.space3),
                Text(
                  meaning,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.size2xl,
                    fontWeight: MxTypography.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: MxSpacing.space4),
        Row(
          children: [
            Expanded(
              child: MxButton(
                label: l10n.studyDueRelearn,
                icon: Icons.replay,
                variant: MxButtonVariant.ghost,
                onPressed: onRelearn,
              ),
            ),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: MxButton(
                label: l10n.studyDueNext,
                icon: Icons.arrow_forward,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
