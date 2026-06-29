import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/models/game_card.dart';
import 'package:memox_v4/presentation/features/game/round.dart';

/// Guess: show a term, pick the correct meaning. Wrong re-queues the card (D-015).
class MultipleChoiceGame extends StatelessWidget {
  const MultipleChoiceGame({
    super.key,
    required this.round,
    required this.actions,
  });

  final RoundState round;
  final RoundActions actions;

  @override
  Widget build(BuildContext context) {
    final current = round.current;
    if (current == null) return const SizedBox.shrink();
    final options = _options(round, current);
    return ListView(
      padding: const EdgeInsets.all(MxSpacing.space5),
      children: <Widget>[
        Card(
          key: const ValueKey('mx-node:game-mc/prompt'),
          child: Padding(
            padding: const EdgeInsets.all(MxSpacing.space6),
            child: Center(
              child: Text(
                current.term,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          ),
        ),
        const SizedBox(height: MxSpacing.space4),
        Column(
          key: const ValueKey('mx-node:game-mc/options'),
          children: <Widget>[
            for (final option in options)
              Padding(
                padding: const EdgeInsets.only(bottom: MxSpacing.space2),
                child: OutlinedButton(
                  key: option == current.meaning
                      ? const Key('mcCorrect')
                      : null,
                  onPressed: () {
                    if (option == current.meaning) {
                      actions.markCorrect(current.cardId);
                    } else {
                      actions.markWrong(current.cardId);
                    }
                  },
                  child: Text(option),
                ),
              ),
          ],
        ),
      ],
    );
  }

  List<String> _options(RoundState round, GameCard current) {
    final options = <String>{current.meaning};
    for (final card in round.cards) {
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
