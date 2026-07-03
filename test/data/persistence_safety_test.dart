import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/repositories/drift_card_repository.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/ids.dart';

/// Realizes the two persistence-safety policies the DT.0.1 skeletons only
/// described (`docs/database/persistence-safety.md`) — the scenarios not covered
/// by the DT.1–DT.4 tests:
/// - **Policy 1** — a multi-table write that fails partway rolls back completely.
/// - **Policy 3** — a list query has a total, stable order with an `id` tie-break.
class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

CardMeaning _meaning(String id, String text) => (CardMeaning.create(
      id: CardMeaningId(id),
      language: 'en',
      text: text,
    ) as Ok<CardMeaning>)
    .value;

void main() {
  late AppDatabase db;
  late DriftCardRepository cards;

  setUp(() async {
    db = AppDatabase.memory();
    await db.into(db.languagePairs).insert(LanguagePairsCompanion.insert(
        id: 'lp', learningLanguage: 'ko', nativeLanguage: 'en', createdAt: 0));
    await db.into(db.decks).insert(DecksCompanion.insert(
        id: 'd', name: 'Deck', languagePairId: 'lp', createdAt: 0));
    cards = DriftCardRepository(db, _FixedClock(DateTime.utc(2026, 7, 4, 9)));
  });
  tearDown(() => db.close());

  group('Policy 1 — atomic multi-table write rolls back on failure', () {
    test('a card save that throws mid-transaction persists nothing', () async {
      // Two meanings share a primary key, so the second `card_meanings` insert
      // violates the PK *inside* the save transaction (after the card row + the
      // first meaning were already written).
      final card = (Card.create(
        id: const CardId('c1'),
        deckId: const DeckId('d'),
        term: '학교',
        meanings: [_meaning('dup', 'school'), _meaning('dup', 'again')],
      ) as Ok<Card>)
          .value;

      final result = await cards.save(card);
      expect(result is Err, isTrue); // the write failed …

      // … and rolled back fully: neither the card nor any meaning survived.
      expect(await cards.getById(const CardId('c1')) is Err, isTrue);
      expect(await db.select(db.cards).get(), isEmpty);
      expect(await db.select(db.cardMeanings).get(), isEmpty);
    });

    test('the DB transaction primitive itself rolls back a thrown body', () async {
      Future<void> body() => db.transaction(() async {
            await db.into(db.settings).insert(
                SettingsCompanion.insert(key: 'k', value: 'v'));
            throw StateError('boom'); // abort after a valid write
          });
      await expectLater(body, throwsA(isA<StateError>()));
      expect(await db.select(db.settings).get(), isEmpty); // nothing committed
    });
  });

  group('Policy 3 — deterministic ordering with an id tie-break', () {
    Future<void> seedCard(String id, {required int createdAt}) async {
      await db.into(db.cards).insert(CardsCompanion.insert(
          id: id, deckId: 'd', term: 'term-$id', createdAt: createdAt));
      await db.into(db.cardMeanings).insert(CardMeaningsCompanion.insert(
          id: 'm-$id', cardId: id, language: 'en', content: 'means-$id'));
    }

    test('equal sort keys fall back to id (not insertion order)', () async {
      // Same createdAt, inserted out of id order.
      await seedCard('c-charlie', createdAt: 5);
      await seedCard('c-alpha', createdAt: 5);
      await seedCard('c-bravo', createdAt: 5);

      final ids =
          (await db.cardDao.watchByDeck('d').first).map((c) => c.id).toList();
      expect(ids, ['c-alpha', 'c-bravo', 'c-charlie']); // id ASC tie-break
    });

    test('the same query over the same data is stable across runs', () async {
      await seedCard('c2', createdAt: 20);
      await seedCard('c1', createdAt: 10);
      await seedCard('c3', createdAt: 10); // ties c1 on createdAt

      final first =
          (await db.cardDao.watchByDeck('d').first).map((c) => c.id).toList();
      final second =
          (await db.cardDao.watchByDeck('d').first).map((c) => c.id).toList();
      expect(first, second); // reproducible
      expect(first, ['c1', 'c3', 'c2']); // (createdAt, id): 10/c1, 10/c3, 20/c2
    });
  });
}
