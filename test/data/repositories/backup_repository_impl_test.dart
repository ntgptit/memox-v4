import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/data/repositories/backup_repository_impl.dart';
import 'package:memox_v4/domain/types/result.dart';

void main() {
  late AppDatabase db;
  late BackupRepositoryImpl repository;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    repository = BackupRepositoryImpl(db);
    tempDir = await Directory.systemTemp.createTemp('memox_backup_test');
  });
  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  test('backup then restore round-trips the data', () async {
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    final deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    await db
        .into(db.card)
        .insert(
          CardCompanion.insert(deckId: deckId, term: 'xin', createdAt: 1),
        );

    final path = '${tempDir.path}/backup.json';
    expect(await repository.backup(path), isA<Ok<void>>());
    expect(File(path).existsSync(), isTrue);

    // Wipe everything, then restore.
    await db.delete(db.card).go();
    await db.delete(db.deck).go();
    await db.delete(db.languagePair).go();
    expect(await db.select(db.card).get(), isEmpty);

    expect(await repository.restore(path), isA<Ok<void>>());
    final cards = await db.select(db.card).get();
    expect(cards, hasLength(1));
    expect(cards.single.term, 'xin');
    final decks = await db.select(db.deck).get();
    expect(decks.single.name, 'Deck');
  });

  test(
    'serialize/deserialize round-trips review_outcome (W9 in snapshot)',
    () async {
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

      final json = await repository.serialize();
      expect(json, isA<Ok<String>>());

      await db.delete(db.reviewOutcome).go();
      await db.delete(db.card).go();
      await db.delete(db.deck).go();
      await db.delete(db.languagePair).go();
      expect(await db.select(db.reviewOutcome).get(), isEmpty);

      expect(
        await repository.deserialize((json as Ok<String>).value),
        isA<Ok<void>>(),
      );
      expect(await db.select(db.reviewOutcome).get(), hasLength(1));
    },
  );
}
