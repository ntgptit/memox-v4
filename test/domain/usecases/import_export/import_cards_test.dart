import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/card_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/data/repositories/card_repository_impl.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/flashcard/check_soft_duplicate.dart';
import 'package:memox_v4/domain/usecases/flashcard/create_card.dart';
import 'package:memox_v4/domain/usecases/import_export/import_cards.dart';

void main() {
  late AppDatabase db;
  late ImportCardsUseCase useCase;
  late int deckId;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    final repo = CardRepositoryImpl(CardDao(db), const SystemClock());
    useCase = ImportCardsUseCase(
      CreateCardUseCase(repo),
      CheckSoftDuplicateUseCase(repo),
    );
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
  });
  tearDown(() => db.close());

  test(
    'D-025: imports rows, skips header, splits term/meaning columns',
    () async {
      final rows = <List<String>>[
        <String>['term', 'meaning'],
        <String>['xin', 'please'],
        <String>['hello', 'chào'],
      ];
      final result = (await useCase.call(
        rows: rows,
        deckId: deckId,
        termColumn: 0,
        meaningColumn: 1,
        meaningLang: 'vi',
      )).valueOrNull!;

      expect(result.imported, 2);
      expect(result.duplicates, 0);
    },
  );

  test(
    'D-025/D-020: a re-imported term counts as a soft duplicate but imports',
    () async {
      await useCase.call(
        rows: <List<String>>[
          <String>['xin', 'please'],
        ],
        deckId: deckId,
        termColumn: 0,
        meaningColumn: 1,
        meaningLang: 'vi',
        hasHeader: false,
      );

      final again = (await useCase.call(
        rows: <List<String>>[
          <String>['xin', 'again'],
        ],
        deckId: deckId,
        termColumn: 0,
        meaningColumn: 1,
        meaningLang: 'vi',
        hasHeader: false,
      )).valueOrNull!;

      expect(again.imported, 1);
      expect(again.duplicates, 1);
    },
  );

  test('rows missing the term or meaning are skipped', () async {
    final result = (await useCase.call(
      rows: <List<String>>[
        <String>['', 'orphan meaning'],
        <String>['orphan term', ''],
        <String>['ok', 'good'],
      ],
      deckId: deckId,
      termColumn: 0,
      meaningColumn: 1,
      meaningLang: 'vi',
      hasHeader: false,
    )).valueOrNull!;

    expect(result.imported, 1);
  });
}
