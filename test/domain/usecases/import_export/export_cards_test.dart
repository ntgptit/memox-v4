import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/card_dao.dart';
import 'package:memox_v4/data/datasources/local/daos/deck_dao.dart';
import 'package:memox_v4/data/datasources/local/daos/srs_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show AppDatabase, DeckCompanion, LanguagePairCompanion;
import 'package:memox_v4/data/repositories/card_repository_impl.dart';
import 'package:memox_v4/data/repositories/deck_repository_impl.dart';
import 'package:memox_v4/data/repositories/srs_repository_impl.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/models/card_draft.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/import_export/export_cards.dart';

void main() {
  late AppDatabase db;
  late ExportCardsUseCase useCase;
  late CardRepositoryImpl cards;
  late int pairId;
  late int deckId;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    cards = CardRepositoryImpl(CardDao(db), const SystemClock());
    useCase = ExportCardsUseCase(
      cards,
      DeckRepositoryImpl(DeckDao(db), const SystemClock()),
      SrsRepositoryImpl(SrsDao(db)),
    );
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

  test('D-026: header + a row per card', () async {
    await cards.create(
      CardDraft(
        deckId: deckId,
        term: 'xin',
        meanings: const <CardMeaning>[
          CardMeaning(lang: 'vi', content: 'please'),
        ],
      ),
    );

    final rows = (await useCase.call(deckId: deckId)).valueOrNull!;
    expect(rows.first, <String>['term', 'meaning']);
    expect(rows[1][0], 'xin');
    expect(rows[1][1], 'please');
  });

  test('includeSubtree gathers cards from child decks (bulk)', () async {
    await cards.create(
      CardDraft(
        deckId: deckId,
        term: 'parent',
        meanings: const <CardMeaning>[CardMeaning(lang: 'vi', content: 'cha')],
      ),
    );
    final childId = await db
        .into(db.deck)
        .insert(
          DeckCompanion.insert(
            pairId: pairId,
            name: 'Child',
            parentDeckId: Value(deckId),
          ),
        );
    await cards.create(
      CardDraft(
        deckId: childId,
        term: 'child',
        meanings: const <CardMeaning>[CardMeaning(lang: 'vi', content: 'con')],
      ),
    );

    final flat = (await useCase.call(deckId: deckId)).valueOrNull!;
    expect(flat, hasLength(2)); // header + parent card only

    final subtree = (await useCase.call(
      deckId: deckId,
      includeSubtree: true,
    )).valueOrNull!;
    final terms = <String>[for (final row in subtree.skip(1)) row[0]];
    expect(terms, containsAll(<String>['parent', 'child']));
  });

  test('D-026: includeSrs adds the box + due_at columns', () async {
    await cards.create(
      CardDraft(
        deckId: deckId,
        term: 'xin',
        meanings: const <CardMeaning>[
          CardMeaning(lang: 'vi', content: 'please'),
        ],
      ),
    );

    final rows = (await useCase.call(
      deckId: deckId,
      includeSrs: true,
    )).valueOrNull!;
    expect(rows.first, <String>['term', 'meaning', 'box', 'due_at']);
    expect(rows[1].length, 4);
  });
}
