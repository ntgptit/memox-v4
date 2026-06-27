import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/models/game_card.dart';
import 'package:memox_v4/presentation/features/game/viewmodels/game_session_notifier.dart';

/// Guess: show a term, pick the correct meaning. Wrong re-queues the card (D-015).
class MultipleChoiceGame extends ConsumerWidget {
  const MultipleChoiceGame({super.key, required this.request});

  final GameRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameSessionNotifierProvider(request)).valueOrNull;
    final current = state?.current;
    if (state == null || current == null) return const SizedBox.shrink();
    final notifier = ref.read(gameSessionNotifierProvider(request).notifier);
    final options = _options(state, current);
    return ListView(
      padding: const EdgeInsets.all(MxSpacing.space5),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(MxSpacing.space6),
            child: Center(
              child: Text(
                current.term,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ),
        const SizedBox(height: MxSpacing.space4),
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(bottom: MxSpacing.space2),
            child: OutlinedButton(
              key: option == current.meaning ? const Key('mcCorrect') : null,
              onPressed: () {
                if (option == current.meaning) {
                  notifier.markCorrect(current.cardId);
                } else {
                  notifier.markWrong(current.cardId);
                }
              },
              child: Text(option),
            ),
          ),
      ],
    );
  }

  List<String> _options(GameSessionState state, GameCard current) {
    final options = <String>{current.meaning};
    for (final card in state.cards) {
      if (options.length >= 4) break;
      if (card.cardId != current.cardId && card.meaning.isNotEmpty) {
        options.add(card.meaning);
      }
    }
    final list = options.toList()
      ..sort(
        (a, b) => (a.hashCode ^ current.cardId).compareTo(
          b.hashCode ^ current.cardId,
        ),
      );
    return list;
  }
}
