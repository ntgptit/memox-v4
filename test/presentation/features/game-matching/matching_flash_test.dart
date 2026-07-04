import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/presentation/features/game-matching/providers/matching_providers.dart';

import '../../../harness/provider_harness.dart';

Deck _deck(String id, String name) =>
    (Deck.create(id: DeckId(id), name: name) as Ok<Deck>).value;

Card _card(String id, String deckId, String term, String meaning) =>
    (Card.create(
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

FakeStore _store() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  for (var i = 1; i <= 3; i++) {
    store.cards['c$i'] = _card('c$i', 'd', 'term$i', 'means$i');
  }
  return store;
}

void main() {
  test('a correct pair flashes correct, then commits to matched', () async {
    final container = ProviderContainer(overrides: FakeHarness(store: _store()).overrides);
    addTearDown(container.dispose);
    final sub = container.listen(matchingControllerProvider, (_, _) {});
    addTearDown(sub.close);

    final data = await container.read(matchingControllerProvider.future);
    const leftIndex = 0;
    final cardId = data.left[leftIndex].cardId;
    final rightIndex = data.right.indexWhere((t) => t.cardId == cardId);
    expect(rightIndex, isNonNegative);

    final ctrl = container.read(matchingControllerProvider.notifier);
    ctrl.selectLeft(leftIndex);
    ctrl.selectRight(rightIndex);

    // Immediately: the pair flashes `correct` and is NOT yet matched.
    var s = container.read(matchingControllerProvider).value!;
    expect(s.correctLeft, leftIndex);
    expect(s.correctRight, rightIndex);
    expect(s.matchedLeft.contains(leftIndex), isFalse);

    // After the flash: the pair is matched and the correct flag is cleared.
    await Future<void>.delayed(matchFlashDuration + const Duration(milliseconds: 100));
    s = container.read(matchingControllerProvider).value!;
    expect(s.matchedLeft.contains(leftIndex), isTrue);
    expect(s.matchedRight.contains(rightIndex), isTrue);
    expect(s.correctLeft, isNull);
    expect(s.correctRight, isNull);
  });
}
