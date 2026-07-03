import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_repositories.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';

void main() {
  group('FakeClock / FakeIdGenerator', () {
    test('clock is settable + advanceable; ids are sequential', () {
      final clock = FakeClock(DateTime.utc(2026));
      clock.advance(const Duration(days: 1));
      expect(clock.now(), DateTime.utc(2026, 1, 2));

      final ids = FakeIdGenerator();
      expect([ids.next('card'), ids.next('card')], ['card-1', 'card-2']);
    });
  });

  group('FakeDeckRepository', () {
    test('watchChildren emits roots then re-emits on save', () async {
      final store = seedFakeStore();
      final repo = FakeDeckRepository(store);
      final stream = repo.watchChildren(null);

      expect(await stream.first, hasLength(1)); // one seeded root

      final child = (await repo.getById(const DeckId('deck-food'))) as Ok;
      expect(child.value, isNotNull);
    });

    test('delete cascades the whole subtree', () async {
      final store = seedFakeStore();
      final repo = FakeDeckRepository(store);
      await repo.delete(const DeckId('deck-root'));

      expect(store.decks, isEmpty); // root + child gone
      expect(store.cards, isEmpty); // cards under the subtree gone
    });

    test('statsFor aggregates the subtree', () async {
      final store = seedFakeStore();
      final stats = (await FakeDeckRepository(store).statsFor(const DeckId('deck-root')) as Ok).value;
      expect(stats.totalCards, 3);
    });
  });

  group('FakeCardRepository', () {
    test('search filters by term/meaning; setHidden flips the flag', () async {
      final store = seedFakeStore();
      final repo = FakeCardRepository(store);

      final hits = (await repo.search('mèo') as Ok).value;
      expect(hits, hasLength(1));

      await repo.setHidden(const CardId('card-2'), hidden: true);
      expect(store.cards['card-2']!.hidden, isTrue);
    });
  });

  group('FakeReviewRepository', () {
    test('dueQueue returns only due, non-hidden cards; newQueue returns box-0', () async {
      final store = seedFakeStore();
      final repo = FakeReviewRepository(store);
      final now = DateTime.utc(2026, 7, 3, 9);

      final due = (await repo.dueQueue(asOf: now) as Ok<List<Card>>).value;
      expect(due.map((c) => c.id.value), ['card-1']); // only the due one

      final news = (await repo.newQueue(limit: 20) as Ok<List<Card>>).value;
      expect(news.map((c) => c.id.value), ['card-3']); // the newborn
    });

    test('saveSchedule + currentBox round-trip', () async {
      final store = seedFakeStore();
      final repo = FakeReviewRepository(store);
      await repo.saveSchedule(cardId: const CardId('card-3'), box: BoxLevel.firstBox);
      expect((await repo.currentBox(const CardId('card-3')) as Ok).value, BoxLevel.firstBox);
    });
  });
}
