import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';

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

/// A single-deck library whose first (target) deck already holds "사과" — so
/// pasting that term reaches the preview with a soft-duplicate warning.
List<Override> importDuplicateOverrides() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  store.cards['c1'] = _card('c1', 'd', '사과', 'apple');
  return FakeHarness(store: store).overrides;
}
