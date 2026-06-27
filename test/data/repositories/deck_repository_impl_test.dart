import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/deck_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show
        AppDatabase,
        CardCompanion,
        CardMeaningCompanion,
        LanguagePairCompanion,
        SrsStateCompanion;
import 'package:memox_v4/data/repositories/deck_repository_impl.dart';
import 'package:memox_v4/domain/types/result.dart';

class _FixedClock implements Clock {
  const _FixedClock(this._ms);
  final int _ms;
  @override
  DateTime now() => DateTime.fromMillisecondsSinceEpoch(_ms);
  @override
  DateTime nowUtc() => now().toUtc();
}

void main() {
  late AppDatabase db;
  late DeckRepositoryImpl repository;
  late int pairId;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    repository = DeckRepositoryImpl(DeckDao(db), const _FixedClock(1000));
    pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
  });
  tearDown(() => db.close());

  Future<int> deck(String name, {int? parent}) async {
    final result = await repository.create(
      pairId: pairId,
      parentDeckId: parent,
      name: name,
    );
    return result.valueOrNull!.id;
  }

  Future<int> card(int deckId, {bool hidden = false}) => db
      .into(db.card)
      .insert(
        CardCompanion.insert(
          deckId: deckId,
          term: 't',
          createdAt: 1,
          hidden: Value(hidden),
        ),
      );

  test('libraryTree nests children under their roots', () async {
    final root = await deck('Root');
    await deck('Child', parent: root);

    final roots = (await repository.libraryTree(pairId)).valueOrNull!;
    expect(roots, hasLength(1));
    expect(roots.first.deck.name, 'Root');
    expect(roots.first.children, hasLength(1));
    expect(roots.first.children.first.deck.name, 'Child');
  });

  test('BR-5: words/hidden aggregate recursively over the subtree', () async {
    final root = await deck('Root');
    final child = await deck('Child', parent: root);
    await card(root);
    await card(child);
    await card(child);
    await card(child, hidden: true);

    final rootNode = (await repository.libraryTree(pairId)).valueOrNull!.first;
    expect(rootNode.stats.words, 3);
    expect(rootNode.stats.hidden, 1);
    expect(rootNode.children.first.stats.words, 2);
  });

  test('recursive: due aggregates from srs_state vs the clock', () async {
    final root = await deck('Root');
    final c = await card(root);
    await db
        .into(db.srsState)
        .insert(
          SrsStateCompanion.insert(
            cardId: Value(c),
            box: const Value(2),
            dueAt: const Value(500),
          ),
        );

    final rootNode = (await repository.libraryTree(pairId)).valueOrNull!.first;
    expect(rootNode.stats.due, 1);
  });

  test('D-024: delete cascades the whole subtree', () async {
    final root = await deck('Root');
    final child = await deck('Child', parent: root);
    final grand = await deck('Grand', parent: child);
    final c = await card(grand);
    await db
        .into(db.cardMeaning)
        .insert(
          CardMeaningCompanion.insert(cardId: c, lang: 'vi', content: 'm'),
        );
    await db
        .into(db.srsState)
        .insert(SrsStateCompanion.insert(cardId: Value(c)));

    await repository.delete(root);

    expect((await repository.libraryTree(pairId)).valueOrNull, isEmpty);
    expect(await db.select(db.deck).get(), isEmpty);
    expect(await db.select(db.card).get(), isEmpty);
    expect(await db.select(db.cardMeaning).get(), isEmpty);
    expect(await db.select(db.srsState).get(), isEmpty);
  });

  test(
    'BR-3: moving a deck into its own subtree (or itself) is rejected',
    () async {
      final root = await deck('Root');
      final child = await deck('Child', parent: root);

      final intoChild = await repository.move(root, newParentId: child);
      expect((intoChild as Err).failure, isA<ValidationFailure>());

      final intoSelf = await repository.move(root, newParentId: root);
      expect((intoSelf as Err).failure, isA<ValidationFailure>());
    },
  );

  test('move to an unrelated parent succeeds', () async {
    final a = await deck('A');
    final b = await deck('B');

    expect((await repository.move(a, newParentId: b)).isOk, isTrue);
    final node = (await repository.node(a)).valueOrNull!;
    expect(node.deck.parentDeckId, b);
  });
}
