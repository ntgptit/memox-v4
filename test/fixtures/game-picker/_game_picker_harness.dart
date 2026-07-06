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

Card _card(String id, String deckId, String term) =>
    (Card.create(
              id: CardId(id),
              deckId: DeckId(deckId),
              term: term,
              meanings: [
                (CardMeaning.create(
                          id: CardMeaningId('m-$id'),
                          language: 'en',
                          text: 'means $id',
                        )
                        as Ok<CardMeaning>)
                    .value,
              ],
            )
            as Ok<Card>)
        .value;

/// A store with one deck of 5 cards — enough to enable the All-cards games.
List<Override> gamePickerFullOverrides() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  for (var i = 1; i <= 5; i++) {
    store.cards['c$i'] = _card('c$i', 'd', 'term$i');
  }
  return FakeHarness(store: store).overrides;
}
