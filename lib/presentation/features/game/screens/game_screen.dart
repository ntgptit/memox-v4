import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/types/game_type.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/game/round.dart';
import 'package:memox_v4/presentation/features/game/viewmodels/game_session_notifier.dart';
import 'package:memox_v4/presentation/features/game/widgets/matching_game.dart';
import 'package:memox_v4/presentation/features/game/widgets/multiple_choice_game.dart';
import 'package:memox_v4/presentation/features/game/widgets/recall_game.dart';
import 'package:memox_v4/presentation/features/game/widgets/typing_game.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';

/// Runs one game round: the frame (app bar + progress) plus the body for the
/// chosen game, and the complete / not-enough states.
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key, required this.request});

  final GameRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(gameSessionProvider(request));
    return Scaffold(
      appBar: AppBar(title: Text(_gameName(l10n, request.type))),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(l10n.libraryError)),
        data: (state) {
          if (state.isEmpty) return _notEnough(context, l10n);
          if (state.isComplete) return _complete(context, ref, l10n);
          final round = RoundState(
            cards: state.cards,
            pending: state.pending,
            lastWrong: state.lastWrong,
          );
          final actions = ref.read(gameSessionProvider(request).notifier);
          return Column(
            children: <Widget>[
              LinearProgressIndicator(value: state.progress),
              Expanded(child: _body(request.type, round, actions)),
            ],
          );
        },
      ),
    );
  }

  Widget _body(GameType type, RoundState round, RoundActions actions) =>
      switch (type) {
        GameType.matching => MatchingGame(round: round, actions: actions),
        GameType.multipleChoice => MultipleChoiceGame(
          round: round,
          actions: actions,
        ),
        GameType.recall => RecallGame(round: round, actions: actions),
        GameType.typing => TypingGame(round: round, actions: actions),
      };

  Widget _notEnough(BuildContext context, AppLocalizations l10n) =>
      MxContentBounds(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(l10n.gameNotEnoughTitle),
              const SizedBox(height: MxSpacing.space4),
              FilledButton(
                onPressed: () => unawaited(Navigator.of(context).maybePop()),
                child: Text(l10n.commonBack),
              ),
            ],
          ),
        ),
      );

  Widget _complete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) => MxContentBounds(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.celebration_outlined,
            size: MxSpacing.space10,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: MxSpacing.space4),
          Text(
            l10n.gameComplete,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: MxSpacing.space5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlinedButton(
                key: const Key('gamePlayAgain'),
                onPressed: () => ref.invalidate(gameSessionProvider(request)),
                child: Text(l10n.gamePlayAgain),
              ),
              const SizedBox(width: MxSpacing.space3),
              FilledButton(
                onPressed: () => unawaited(Navigator.of(context).maybePop()),
                child: Text(l10n.gameDone),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  String _gameName(AppLocalizations l10n, GameType type) => switch (type) {
    GameType.matching => l10n.gameMatching,
    GameType.multipleChoice => l10n.gameMultipleChoice,
    GameType.recall => l10n.gameRecall,
    GameType.typing => l10n.gameTyping,
  };
}
