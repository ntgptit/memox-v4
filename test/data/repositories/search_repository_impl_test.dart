import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/search_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show
        AppDatabase,
        CardCompanion,
        CardMeaningCompanion,
        DeckCompanion,
        LanguagePairCompanion,
        SrsStateCompanion;
import 'package:memox_v4/data/repositories/search_repository_impl.dart';
import 'package:memox_v4/domain/types/card_status.dart';
import 'package:memox_v4/domain/types/result.dart';

void main() {
  late AppDatabase db;
  late SearchRepositoryImpl repository;
  late int pairId;
  late int deckId;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    repository = SearchRepositoryImpl(SearchDao(db));
    pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
  });
  tearDown(() => db.close());

  Future<int> card(String term, String meaning, {bool hidden = false}) async {
    final id = await db
        .into(db.card)
        .insert(
          CardCompanion.insert(
            deckId: deckId,
            term: term,
            createdAt: 1,
            hidden: Value(hidden),
          ),
        );
    await db
        .into(db.cardMeaning)
        .insert(
          CardMeaningCompanion.insert(cardId: id, lang: 'vi', content: meaning),
        );
    return id;
  }

  test('D-019: matches on both term and meaning', () async {
    final byTerm = await card('xin', 'please');
    final byMeaning = await card('hello', 'xin chào');
    final other = await card('bye', 'tạm biệt');

    final results = (await repository.search(
      pairId: pairId,
      query: 'xin',
    )).valueOrNull!;
    final ids = results.map((r) => r.cardId).toSet();
    expect(ids, containsAll(<int>[byTerm, byMeaning]));
    expect(ids.contains(other), isFalse);
  });

  test('D-019: multi-token query ANDs across term and meaning', () async {
    final split = await card('xin', 'chào bạn'); // 'xin' term, 'bạn' meaning
    final onlyTerm = await card('xin', 'cảm ơn'); // matches 'xin' but not 'bạn'

    final results = (await repository.search(
      pairId: pairId,
      query: 'xin bạn',
    )).valueOrNull!;
    final ids = results.map((r) => r.cardId).toSet();
    expect(ids, contains(split));
    expect(ids.contains(onlyTerm), isFalse);
  });

  test('D-028: results include hidden cards', () async {
    final hidden = await card('mesa', 'bàn', hidden: true);
    final results = (await repository.search(
      pairId: pairId,
      query: 'mesa',
    )).valueOrNull!;
    expect(results.firstWhere((r) => r.cardId == hidden).hidden, isTrue);
  });

  test('D-028: status derives new vs due for the filter', () async {
    final fresh = await card('word1', 'm1');
    final due = await card('word2', 'm2');
    await db
        .into(db.srsState)
        .insert(
          SrsStateCompanion.insert(
            cardId: Value(due),
            box: const Value(2),
            dueAt: const Value(5000),
          ),
        );

    final results = (await repository.search(
      pairId: pairId,
      query: 'word',
    )).valueOrNull!;
    final byId = {for (final r in results) r.cardId: r};
    expect(byId[fresh]!.status(10000), CardStatus.newCard);
    expect(byId[due]!.status(10000), CardStatus.due);
  });

  test('search is scoped to the pair and excludes non-matches', () async {
    await card('apple', 'táo');
    final results = (await repository.search(
      pairId: pairId,
      query: 'zzz',
    )).valueOrNull!;
    expect(results, isEmpty);
  });
}
