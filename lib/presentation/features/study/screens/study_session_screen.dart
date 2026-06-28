import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/game/round.dart';
import 'package:memox_v4/presentation/features/game/widgets/matching_game.dart';
import 'package:memox_v4/presentation/features/game/widgets/multiple_choice_game.dart';
import 'package:memox_v4/presentation/features/game/widgets/recall_game.dart';
import 'package:memox_v4/presentation/features/game/widgets/typing_game.dart';
import 'package:memox_v4/presentation/features/study/viewmodels/study_session_notifier.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';

/// Scheduled study session. NewLearn runs 5 stages over the cards — stage 1 is a
/// learn pass (term + meaning), stages 2–5 reuse the real W5 game widgets
/// (matching / guess / recall / fill-in) driven by the study session via
/// `RoundActions`. DueReview is a single recall pass that grades SRS (D-014).
class StudySessionScreen extends ConsumerStatefulWidget {
  const StudySessionScreen({
    super.key,
    required this.nodeId,
    required this.entry,
  });

  final int nodeId;
  final StudyEntry entry;

  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen> {
  StudyRequest get _request =>
      StudyRequest(nodeId: widget.nodeId, entry: widget.entry);

  StudySessionNotifier get _notifier =>
      ref.read(studySessionProvider(_request).notifier);

  Future<void> _onExit() async {
    if (widget.entry == StudyEntry.newLearn) {
      final l10n = AppLocalizations.of(context);
      final exit = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.studyExitTitle),
          content: Text(l10n.studyExitBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.studyExitConfirm),
            ),
          ],
        ),
      );
      if (!mounted || exit != true) return;
    }
    if (mounted) await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(studySessionProvider(_request));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('studyExit'),
          icon: const Icon(Icons.close),
          onPressed: () => unawaited(_onExit()),
        ),
        title: Text(_stageLabel(l10n, async.value)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _message(l10n.libraryError),
        data: (state) {
          if (state.isEmpty) return _message(l10n.reviewEnd);
          if (state.finished) return _result(l10n, state);
          return Column(
            children: <Widget>[
              LinearProgressIndicator(value: state.progress),
              Expanded(child: _body(l10n, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _body(AppLocalizations l10n, StudySessionState state) {
    final round = RoundState(cards: state.cards, pending: state.pending);
    if (round.current == null) return const SizedBox.shrink();
    if (state.entry == StudyEntry.dueReview) {
      return RecallGame(round: round, actions: _notifier);
    }
    // NewLearn: stage 1 learns, stages 2–5 are the real games.
    return switch (state.stageIndex) {
      0 => _learnStage(l10n, round),
      1 => MatchingGame(round: round, actions: _notifier),
      2 => MultipleChoiceGame(round: round, actions: _notifier),
      3 => RecallGame(round: round, actions: _notifier),
      _ => TypingGame(round: round, actions: _notifier),
    };
  }

  Widget _learnStage(AppLocalizations l10n, RoundState round) {
    final theme = Theme.of(context);
    final current = round.current!;
    return Padding(
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Column(
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(MxSpacing.space6),
              child: Center(
                child: Text(current.term, style: theme.textTheme.headlineSmall),
              ),
            ),
          ),
          const SizedBox(height: MxSpacing.space4),
          Text(current.meaning, style: theme.textTheme.bodyLarge),
          const Spacer(),
          FilledButton(
            key: const Key('studyLearnNext'),
            onPressed: () => _notifier.markCorrect(current.cardId),
            child: Text(l10n.studyContinue),
          ),
        ],
      ),
    );
  }

  Widget _result(AppLocalizations l10n, StudySessionState state) {
    final theme = Theme.of(context);
    return MxContentBounds(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.check_circle_outline,
              size: MxSpacing.space10,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: MxSpacing.space4),
            Text(l10n.studyResultTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: MxSpacing.space2),
            Text(l10n.studyResultWords(state.cards.length)),
            Text(l10n.studyResultAccuracy((state.accuracy * 100).round())),
            const SizedBox(height: MxSpacing.space5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  key: const Key('studyContinue'),
                  onPressed: () =>
                      ref.invalidate(studySessionProvider(_request)),
                  child: Text(l10n.studyContinue),
                ),
                const SizedBox(width: MxSpacing.space3),
                FilledButton(
                  onPressed: () => context.go(RoutePaths.root),
                  child: Text(l10n.studyToLibrary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(String text) =>
      MxContentBounds(child: Center(child: Text(text)));

  String _stageLabel(AppLocalizations l10n, StudySessionState? state) {
    if (state == null) return '';
    if (state.entry != StudyEntry.newLearn) {
      return l10n.studyDueReview(state.cards.length);
    }
    return <String>[
      l10n.studyStageReview,
      l10n.gameMatching,
      l10n.gameMultipleChoice,
      l10n.gameRecall,
      l10n.gameTyping,
    ][state.stageIndex];
  }
}
