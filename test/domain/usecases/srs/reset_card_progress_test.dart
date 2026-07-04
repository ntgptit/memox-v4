import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_repositories.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/usecases/srs/reset_card_progress.dart';

void main() {
  test('resets a scheduled card back to New (box 0, unscheduled)', () async {
    final store = seedFakeStore();
    final repo = FakeReviewRepository(store);
    const cardId = CardId('card-1'); // seeded as a due (scheduled) card
    final asOf = DateTime.utc(2026, 7, 3, 9);

    // Precondition: the card is scheduled (not New) and due.
    final before = (await repo.currentBox(cardId) as Ok<BoxLevel>).value;
    expect(before.isNew, isFalse);
    final dueBefore =
        (await repo.dueQueue(asOf: asOf) as Ok<List<Card>>).value;
    expect(dueBefore.map((c) => c.id.value), contains('card-1'));

    final result = await ResetCardProgress(repo).call(cardId);
    expect(result, isA<Ok<void>>());

    // After: back to box 0 and off the schedule (no longer due).
    final after = (await repo.currentBox(cardId) as Ok<BoxLevel>).value;
    expect(after, BoxLevel.newCard);
    final dueAfter = (await repo.dueQueue(asOf: asOf) as Ok<List<Card>>).value;
    expect(dueAfter.map((c) => c.id.value), isNot(contains('card-1')));
  });
}
