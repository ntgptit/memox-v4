import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(openInMemoryDatabase()));
  tearDown(() => db.close());

  test('onCreate builds the current schema (v2)', () async {
    expect(db.schemaVersion, 2);
    final names = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
        .get();
    final tables = names.map((r) => r.read<String>('name')).toSet();
    expect(
      tables,
      containsAll(<String>[
        'language_pair',
        'deck',
        'card',
        'card_meaning',
        'srs_state',
        'daily_activity',
        'settings',
      ]),
    );
  });

  test('schema indexes from tables.drift are created', () async {
    final idx = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='index'")
        .get();
    final names = idx.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll(<String>[
        'idx_deck_tree',
        'idx_card_deck_order',
        'idx_meaning_card',
        'idx_srs_due',
      ]),
    );
  });

  test(
    'card_meaning stores the free-text meaning in column `content`',
    () async {
      final cols = await db
          .customSelect('PRAGMA table_info(card_meaning)')
          .get();
      final colNames = cols.map((r) => r.read<String>('name')).toSet();
      expect(colNames, contains('content'));
    },
  );

  test('deck self-nests via parent_deck_id', () async {
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    final rootId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Root'));
    final childId = await db
        .into(db.deck)
        .insert(
          DeckCompanion.insert(
            pairId: pairId,
            name: 'Child',
            parentDeckId: Value(rootId),
          ),
        );

    final child = await (db.select(
      db.deck,
    )..where((d) => d.id.equals(childId))).getSingle();
    expect(child.parentDeckId, rootId);
  });

  test('deleting a deck cascades to cards, meanings and srs_state', () async {
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    final deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    final cardId = await db
        .into(db.card)
        .insert(CardCompanion.insert(deckId: deckId, term: '안녕', createdAt: 1));
    await db
        .into(db.cardMeaning)
        .insert(
          CardMeaningCompanion.insert(
            cardId: cardId,
            lang: 'vi',
            content: 'xin chào',
          ),
        );
    await db
        .into(db.srsState)
        .insert(SrsStateCompanion.insert(cardId: Value(cardId)));

    await (db.delete(db.deck)..where((d) => d.id.equals(deckId))).go();

    expect(await db.select(db.card).get(), isEmpty);
    expect(await db.select(db.cardMeaning).get(), isEmpty);
    expect(await db.select(db.srsState).get(), isEmpty);
  });

  test('settings key-value round-trips', () async {
    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(
            key: 'new_cards_per_day',
            value: const Value('20'),
          ),
        );
    final row = await (db.select(
      db.settings,
    )..where((s) => s.key.equals('new_cards_per_day'))).getSingle();
    expect(row.value, '20');
  });
}
