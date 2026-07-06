import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/presentation/features/game-typing/providers/typing_providers.dart';

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

/// A deck of 5 term/meaning cards — enough to run a round.
List<Override> gameRoundOverrides() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  for (var i = 1; i <= 5; i++) {
    store.cards['c$i'] = _card('c$i', 'd', 'term$i', 'means$i');
  }
  return FakeHarness(store: store).overrides;
}

// ── graded / complete states ────────────────────────────────────────────────
// `correct` needs the current answer already graded correct, and `complete`
// needs an emptied queue — neither is reachable from a fresh round without
// multi-step typing whose card order/target we'd have to track. We subclass the
// PUBLIC TypingController and hand it a fixed TypingState (same pattern as
// study-result / game-mc).

const TypingCard _typingCard1 = TypingCard(
  cardId: 'c1',
  term: 'term1',
  meaning: 'means1',
);
const TypingCard _typingCard2 = TypingCard(
  cardId: 'c2',
  term: 'term2',
  meaning: 'means2',
);

/// correct — the current word answered exactly → correct feedback + Next.
const TypingState typingCorrect = TypingState(
  queue: [_typingCard1, _typingCard2],
  total: 3,
  outcome: TypingOutcome.correct,
  submitted: 'term1',
  hintShown: false,
);

/// complete — the queue is empty (all words cleared) → round-finished summary.
const TypingState typingComplete = TypingState(
  queue: [],
  total: 3,
  outcome: TypingOutcome.none,
  submitted: '',
  hintShown: false,
);

List<Override> typingStateOverrides(TypingState state) => [
  ...FakeHarness().overrides,
  typingControllerProvider.overrideWith(() => _FixedTyping(state)),
];

class _FixedTyping extends TypingController {
  _FixedTyping(this._state);

  final TypingState _state;

  @override
  Future<TypingState> build() async => _state;
}
