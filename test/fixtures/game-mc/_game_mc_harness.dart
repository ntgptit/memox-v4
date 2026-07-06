import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/presentation/features/game-mc/providers/mc_providers.dart';

import '../../harness/provider_harness.dart';

Deck _deck(String id, String name) =>
    (Deck.create(id: DeckId(id), name: name) as Ok<Deck>).value;

Card _card(String id, String deckId, String term, String meaning) =>
    (Card.create(
              id: CardId(id),
              deckId: DeckId(deckId),
              term: term,
              meanings: [
                (CardMeaning.create(
                          id: CardMeaningId('m-$id'),
                          language: 'en',
                          text: meaning,
                        )
                        as Ok<CardMeaning>)
                    .value,
              ],
            )
            as Ok<Card>)
        .value;

/// A deck of 5 term/meaning cards.
List<Override> gameRoundOverrides() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  for (var i = 1; i <= 5; i++) {
    store.cards['c$i'] = _card('c$i', 'd', 'term$i', 'means$i');
  }
  return FakeHarness(store: store).overrides;
}

// ── interaction / complete states ───────────────────────────────────────────
// These need a specific IN-ROUND position (a choice already picked, or the round
// finished), which a fresh real controller can't be in without tapping a choice
// whose correct index is randomised per run. Instead we subclass the PUBLIC
// McController and hand it a fixed McState — the same "override the public
// notifier's build()" pattern used for study-result.

/// A fixed 3-question round; [chosen] is the picked choice on the current
/// question (null = unanswered), [index] the current question (== total when the
/// round is complete).
McState _round({required int index, int? chosen, required int correctCount}) =>
    McState(
      questions: const [
        McQuestion(
          cardId: 'c1',
          prompt: 'term1',
          choices: ['means1', 'means2', 'means3', 'means4'],
          correctIndex: 0,
        ),
        McQuestion(
          cardId: 'c2',
          prompt: 'term2',
          choices: ['means1', 'means2', 'means3', 'means4'],
          correctIndex: 1,
        ),
        McQuestion(
          cardId: 'c3',
          prompt: 'term3',
          choices: ['means1', 'means2', 'means3', 'means4'],
          correctIndex: 2,
        ),
      ],
      index: index,
      chosen: chosen,
      correctCount: correctCount,
    );

/// correct — the current question answered with the correct choice (== index 0).
final McState mcCorrect = _round(index: 0, chosen: 0, correctCount: 1);

/// wrong — answered with a wrong choice (correctIndex 0, picked 1 → re-queued).
final McState mcWrong = _round(index: 0, chosen: 1, correctCount: 0);

/// complete — past the last question → the round-finished summary.
final McState mcComplete = _round(index: 3, chosen: null, correctCount: 2);

List<Override> mcStateOverrides(McState state) => [
  ...FakeHarness().overrides,
  mcControllerProvider.overrideWith(() => _FixedMc(state)),
];

class _FixedMc extends McController {
  _FixedMc(this._state);

  final McState _state;

  @override
  Future<McState> build() async => _state;
}
