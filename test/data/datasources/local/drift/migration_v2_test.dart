import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

void main() {
  Future<bool> hasTable(AppDatabase db, String name) async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$name'",
        )
        .get();
    return rows.isNotEmpty;
  }

  test('schema 1→2 migration adds review_outcome', () async {
    final db = AppDatabase.forTesting(openInMemoryDatabase());
    // Simulate a v1 database (before review_outcome existed).
    await db.customStatement('DROP TABLE review_outcome');
    expect(await hasTable(db, 'review_outcome'), isFalse);

    // Run the 1 → 2 upgrade step.
    await db.migration.onUpgrade(db.createMigrator(), 1, 2);

    expect(await hasTable(db, 'review_outcome'), isTrue);
    // The table is usable + the v1 data (e.g. cards) is untouched.
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
        .insert(
          CardCompanion.insert(deckId: deckId, term: 'xin', createdAt: 1),
        );
    await db
        .into(db.reviewOutcome)
        .insert(
          ReviewOutcomeCompanion.insert(
            cardId: cardId,
            pairId: pairId,
            ts: 1000,
            correct: 1,
            mode: 'dueReview',
          ),
        );
    expect(await db.select(db.reviewOutcome).get(), hasLength(1));

    await db.close();
  });
}
