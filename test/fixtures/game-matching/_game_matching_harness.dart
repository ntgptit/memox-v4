import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/presentation/features/game-matching/providers/matching_providers.dart';

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

// ── almost (near the end of the round) ──────────────────────────────────────
// "almost" is a board with all-but-one pair already matched — a position a fresh
// round can't be in without matching each pair first (the match order isn't
// deterministic). We subclass the PUBLIC MatchingController and hand it a fixed
// MatchingState (same pattern as the other games).

/// almost — 4 pairs, 3 matched, one still open.
const MatchingState matchingAlmost = MatchingState(
  left: [
    MatchTile(cardId: 'c1', text: 'means1'),
    MatchTile(cardId: 'c2', text: 'means2'),
    MatchTile(cardId: 'c3', text: 'means3'),
    MatchTile(cardId: 'c4', text: 'means4'),
  ],
  right: [
    MatchTile(cardId: 'c1', text: 'term1'),
    MatchTile(cardId: 'c2', text: 'term2'),
    MatchTile(cardId: 'c3', text: 'term3'),
    MatchTile(cardId: 'c4', text: 'term4'),
  ],
  selectedLeft: null,
  matchedLeft: {0, 1, 2},
  matchedRight: {0, 1, 2},
  correctLeft: null,
  correctRight: null,
  wrongLeft: null,
  wrongRight: null,
);

List<Override> matchingStateOverrides(MatchingState state) => [
  ...FakeHarness().overrides,
  matchingControllerProvider.overrideWith(() => _FixedMatching(state)),
];

class _FixedMatching extends MatchingController {
  _FixedMatching(this._state);

  final MatchingState _state;

  @override
  Future<MatchingState> build() async => _state;
}
