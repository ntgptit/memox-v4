import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_repositories.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/usecases/srs/reset_deck_progress.dart';

void main() {
  test('resets every card in the deck back to New (box 0, unscheduled)',
      () async {
    final store = seedFakeStore();
    final reviews = FakeReviewRepository(store);
    final cards = FakeCardRepository(store);
    // deck-food holds card-1 (box 1, due), card-2 (box 3, scheduled ahead),
    // card-3 (already New).
    const deckId = DeckId('deck-food');
    final asOf = DateTime.utc(2026, 7, 3, 9);

    // Precondition: at least one card is scheduled (not New) and due.
    final box1Before = (await reviews.currentBox(const CardId('card-1'))
            as Ok<BoxLevel>)
        .value;
    expect(box1Before.isNew, isFalse);
    final dueBefore =
        (await reviews.dueQueue(asOf: asOf) as Ok<List<Card>>).value;
    expect(dueBefore.map((c) => c.id.value), contains('card-1'));

    final result = await ResetDeckProgress(cards, reviews).call(deckId);
    expect(result, isA<Ok<void>>());

    // After: every card in the deck is back to box 0 and off the schedule.
    for (final id in ['card-1', 'card-2', 'card-3']) {
      final box =
          (await reviews.currentBox(CardId(id)) as Ok<BoxLevel>).value;
      expect(box, BoxLevel.newCard, reason: '$id should be New');
    }
    final dueAfter =
        (await reviews.dueQueue(asOf: asOf) as Ok<List<Card>>).value;
    expect(dueAfter.map((c) => c.id.value),
        isNot(anyElement(isIn(['card-1', 'card-2', 'card-3']))));
  });
}
