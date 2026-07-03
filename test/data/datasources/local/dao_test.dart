import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';

/// A due instant to filter against; cards due at `_asOf - 1` are due.
const int _asOf = 1000;

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
    await _seed(db);
  });
  tearDown(() => db.close());

  group('DeckDao', () {
    test('watchChildren lists roots then a parent\'s children', () async {
      final roots = await db.deckDao.watchChildren(null).first;
      expect(roots.map((d) => d.id), ['root']);
      final children = await db.deckDao.watchChildren('root').first;
      expect(children.map((d) => d.id), ['child']);
    });

    test('subtreeIds includes the root and its descendants', () async {
      expect(await db.deckDao.subtreeIds('root'), {'root', 'child'});
    });

    test('statsFor aggregates the subtree (hidden/due/mastered)', () async {
      final stats = await db.deckDao.statsFor('root', asOf: _asOf);
      expect(stats.totalCards, 4);
      expect(stats.hiddenCount, 1); // c4
      expect(stats.dueCount, 1); // c1 only (c4 hidden excluded)
      expect(stats.masteredCount, 1); // c2 box 8
    });
  });

  group('CardDao', () {
    test('watchByDeck returns the deck cards ordered by creation', () async {
      final cards = await db.cardDao.watchByDeck('child').first;
      expect(cards.map((c) => c.id), ['c1', 'c2', 'c3', 'c4']);
    });

    test('meaningsFor returns meanings for the given cards', () async {
      final meanings = await db.cardDao.meaningsFor(['c1', 'c2']);
      expect(meanings.map((m) => m.content), containsAll(['school', 'friend']));
    });

    test('search matches term OR meaning and includes hidden cards (D-019/D-028)',
        () async {
      final hits = await db.cardDao.search(['school']);
      // c1 via meaning "school", c4 (hidden) via term "schoolbag".
      expect(hits.map((c) => c.id), containsAll(['c1', 'c4']));
    });

    test('search ANDs tokens (D-019)', () async {
      expect(await db.cardDao.search(['friend', 'dog']), isEmpty);
      expect((await db.cardDao.search(['개'])).map((c) => c.id), ['c3']);
    });

    test('search scopes to a subtree when given ids', () async {
      final hits = await db.cardDao.search(['school'], withinIds: {'other'});
      expect(hits, isEmpty); // no cards live under "other"
    });
  });

  group('ReviewDao', () {
    test('dueQueue returns due, non-hidden cards ordered by due_at', () async {
      final due = await db.reviewDao.dueQueue(asOf: _asOf);
      expect(due.map((c) => c.id), ['c1']); // c2 not due, c3 new, c4 hidden
    });

    test('newQueue returns unscheduled non-hidden cards', () async {
      final news = await db.reviewDao.newQueue(limit: 10);
      expect(news.map((c) => c.id), ['c3']);
    });

    test('currentBox reads the box or 0 for a new card', () async {
      expect(await db.reviewDao.currentBox('c1'), 1);
      expect(await db.reviewDao.currentBox('c3'), 0);
    });

    test('watchDueCount counts due non-hidden cards', () async {
      expect(await db.reviewDao.watchDueCount(asOf: _asOf).first, 1);
    });
  });
}

Future<void> _seed(AppDatabase db) async {
  await db.into(db.languagePairs).insert(LanguagePairsCompanion.insert(
      id: 'lp', learningLanguage: 'ko', nativeLanguage: 'en', createdAt: 0));
  await db.into(db.decks).insert(DecksCompanion.insert(
      id: 'root', name: 'Root', languagePairId: 'lp', createdAt: 0));
  await db.into(db.decks).insert(DecksCompanion.insert(
      id: 'child',
      name: 'Child',
      languagePairId: 'lp',
      createdAt: 0,
      parentId: const Value('root')));

  Future<void> card(String id, String term, String meaning,
      {int order = 0, bool hidden = false}) async {
    await db.into(db.cards).insert(CardsCompanion.insert(
        id: id,
        deckId: 'child',
        term: term,
        createdAt: order,
        hidden: Value(hidden)));
    await db.into(db.cardMeanings).insert(CardMeaningsCompanion.insert(
        id: 'm-$id', cardId: id, language: 'en', content: meaning));
  }

  await card('c1', '학교', 'school', order: 1);
  await card('c2', '친구', 'friend', order: 2);
  await card('c3', '개', 'dog', order: 3);
  await card('c4', 'schoolbag', 'bag', order: 4, hidden: true);

  await db.into(db.srsStates).insert(
      SrsStatesCompanion.insert(cardId: 'c1', box: 1, dueAt: const Value(500)));
  await db.into(db.srsStates).insert(SrsStatesCompanion.insert(cardId: 'c2', box: 8));
  // c3 has no srs row (new).
  await db.into(db.srsStates).insert(
      SrsStatesCompanion.insert(cardId: 'c4', box: 1, dueAt: const Value(500)));
}
