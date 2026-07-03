import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  Future<void> seedPair() => db.into(db.languagePairs).insert(
        LanguagePairsCompanion.insert(
          id: 'lp',
          learningLanguage: 'ko',
          nativeLanguage: 'en',
          createdAt: 0,
          isActive: const Value(true),
        ),
      );

  Future<void> seedDeck(String id, {String? parentId}) =>
      db.into(db.decks).insert(DecksCompanion.insert(
            id: id,
            name: 'Deck $id',
            languagePairId: 'lp',
            createdAt: 0,
            parentId: Value(parentId),
          ));

  Future<void> seedCard(String id, String deckId) =>
      db.into(db.cards).insert(CardsCompanion.insert(
            id: id,
            deckId: deckId,
            term: 'term-$id',
            createdAt: 0,
          ));

  test('every table accepts an insert and read', () async {
    await seedPair();
    await seedDeck('d');
    await seedCard('c1', 'd');
    await db.into(db.cardMeanings).insert(CardMeaningsCompanion.insert(
        id: 'm1', cardId: 'c1', language: 'en', content: 'meaning'));
    await db.into(db.srsStates).insert(
        SrsStatesCompanion.insert(cardId: 'c1', box: 1, dueAt: const Value(10)));
    await db.into(db.reviewLogs).insert(ReviewLogsCompanion.insert(
        id: 'r1', cardId: 'c1', grade: 'pass', reviewedAt: 5));
    await db.into(db.studySessions).insert(StudySessionsCompanion.insert(
        id: 's1',
        deckId: 'd',
        mode: 'new_learn',
        startedAt: 0,
        durationMinutes: 6,
        wordsStudied: 3));
    await db.into(db.dailyActivity).insert(DailyActivityCompanion.insert(
        day: const Value(0), minutes: const Value(6), words: const Value(3)));
    await db.into(db.settings).insert(
        SettingsCompanion.insert(key: 'srs.new_cards_per_day', value: '20'));
    await db.into(db.backupMetadata).insert(BackupMetadataCompanion.insert(
        id: 'b1', schemaVersion: 1, createdAt: 0));

    expect((await db.select(db.cards).get()).single.term, 'term-c1');
    expect((await db.select(db.srsStates).get()).single.box, 1);
    expect((await db.select(db.settings).get()).single.value, '20');
  });

  test('foreign keys are enforced (PRAGMA foreign_keys = ON)', () async {
    final result = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(result.data.values.first, 1);
  });

  test('deleting a deck cascades to its subtree (D-024)', () async {
    await seedPair();
    await seedDeck('parent');
    await seedDeck('child', parentId: 'parent');
    await seedCard('c1', 'child');
    await db.into(db.cardMeanings).insert(CardMeaningsCompanion.insert(
        id: 'm1', cardId: 'c1', language: 'en', content: 'meaning'));
    await db.into(db.srsStates).insert(SrsStatesCompanion.insert(cardId: 'c1', box: 1));
    await db.into(db.reviewLogs).insert(ReviewLogsCompanion.insert(
        id: 'r1', cardId: 'c1', grade: 'pass', reviewedAt: 0));

    await (db.delete(db.decks)..where((d) => d.id.equals('parent'))).go();

    expect(await db.select(db.decks).get(), isEmpty); // child gone too
    expect(await db.select(db.cards).get(), isEmpty);
    expect(await db.select(db.cardMeanings).get(), isEmpty);
    expect(await db.select(db.srsStates).get(), isEmpty);
    expect(await db.select(db.reviewLogs).get(), isEmpty);
  });

  test('the box CHECK rejects an out-of-range Leitner box', () async {
    await seedPair();
    await seedDeck('d');
    await seedCard('c1', 'd');

    expect(
      () => db.into(db.srsStates).insert(
          SrsStatesCompanion.insert(cardId: 'c1', box: 9)),
      throwsA(isA<Exception>()),
    );
  });

  test('a card FK to a missing deck is rejected', () async {
    await seedPair();
    expect(
      () => seedCard('c1', 'nope'),
      throwsA(isA<Exception>()),
    );
  });
}
