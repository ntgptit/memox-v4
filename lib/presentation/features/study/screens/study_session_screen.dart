import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/study/viewmodels/study_session_notifier.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';

/// Scheduled study session (NewLearn 5 stages / DueReview). A unified self-grade
/// drives the round; the per-stage game widgets are reused from W5 in a follow-up
/// (they bind to the game notifier — see NIGHT-LOG).
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
    final theme = Theme.of(context);
    final current = state.current;
    if (current == null) return const SizedBox.shrink();
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
          if (state.revealed)
            Text(current.meaning, style: theme.textTheme.bodyLarge),
          const Spacer(),
          if (!state.revealed)
            FilledButton(
              key: const Key('studyShow'),
              onPressed: _notifier.reveal,
              child: Text(l10n.gameShow),
            )
          else
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    key: const Key('studyForgot'),
                    onPressed: () => unawaited(_notifier.grade(false)),
                    child: Text(l10n.gameForgot),
                  ),
                ),
                const SizedBox(width: MxSpacing.space3),
                Expanded(
                  child: FilledButton(
                    key: const Key('studyRemembered'),
                    onPressed: () => unawaited(_notifier.grade(true)),
                    child: Text(l10n.gameRemembered),
                  ),
                ),
              ],
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
