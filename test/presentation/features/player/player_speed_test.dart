import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/presentation/features/player/providers/player_providers.dart';

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
  store.cards['c1'] = _card('c1', 'd', 'term1', 'means1');
  return store;
}

/// Lets the fire-and-forget `_speak` future settle.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('the selected playback rate is applied to the spoken card', () async {
    final harness = FakeHarness(store: _store());
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);
    // Keep the async notifier alive (the screen would, via watch) so it does not
    // auto-dispose to AsyncLoading between reads.
    final sub = container.listen(playerControllerProvider, (_, _) {});
    addTearDown(sub.close);

    // Init speaks the first card at the default rate (1.0).
    await container.read(playerControllerProvider.future);
    await _settle();
    expect(harness.audio.lastSpoken, 'term1');
    expect(harness.audio.lastRate, 1.0);

    // Choosing 1.5x re-speaks the current card at that rate.
    container.read(playerControllerProvider.notifier).setSpeed('1.5');
    await _settle();
    expect(harness.audio.lastRate, 1.5);

    // And 0.75x.
    container.read(playerControllerProvider.notifier).setSpeed('0.75');
    await _settle();
    expect(harness.audio.lastRate, 0.75);
  });
}
