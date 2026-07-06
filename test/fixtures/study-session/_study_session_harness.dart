import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';

import '../../harness/provider_harness.dart';

final DateTime _now = DateTime.utc(2026, 7, 3, 9);

Deck _deck(String id, String name) =>
    (Deck.create(id: DeckId(id), name: name) as Ok<Deck>).value;

Card _card(String id, String deckId, String term, String meaning) => (Card.create(
      id: CardId(id),
      deckId: DeckId(deckId),
      term: term,
      meanings: [
        (CardMeaning.create(id: CardMeaningId('m-$id'), language: 'en', text: meaning)
                as Ok<CardMeaning>)
            .value,
      ],
    ) as Ok<Card>)
    .value;

/// A new (unseen) card → the new-learn flow starts at stage 1.
List<Override> studySessionNewOverrides() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  store.cards['c1'] = _card('c1', 'd', '학교', 'school');
  store.srsByCard['c1'] = SrsState.newborn;
  return FakeHarness(store: store).overrides;
}

/// A card due for review → the due-review grading flow.
List<Override> studySessionDueOverrides() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  store.cards['c1'] = _card('c1', 'd', '학교', 'school');
  store.srsByCard['c1'] = SrsState(
    box: BoxLevel.firstBox,
    dueAt: _now.subtract(const Duration(hours: 1)),
  );
  return FakeHarness(store: store).overrides;
}
