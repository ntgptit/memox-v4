import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/repositories/drift_card_repository.dart';
import 'package:memox_v4/data/repositories/drift_deck_repository.dart';
import 'package:memox_v4/data/repositories/drift_review_repository.dart';
import 'package:memox_v4/data/repositories/drift_settings_repository.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/review_log.dart';

class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

Deck _deck(String id, String name, {String? parent}) => (Deck.create(
      id: DeckId(id),
      name: name,
      parentId: parent == null ? null : DeckId(parent),
    ) as Ok<Deck>)
    .value;

Card _card(String id, String deckId, String term, List<String> meanings,
        {bool hidden = false}) =>
    (Card.create(
      id: CardId(id),
      deckId: DeckId(deckId),
      term: term,
      hidden: hidden,
      meanings: [
        for (final (i, m) in meanings.indexed)
          (CardMeaning.create(id: CardMeaningId('m-$id-$i'), language: 'en', text: m)
                  as Ok<CardMeaning>)
              .value,
      ],
    ) as Ok<Card>)
        .value;

void main() {
  late AppDatabase db;
  late DriftDeckRepository decks;
  late DriftCardRepository cards;
  late DriftReviewRepository reviews;
  late DriftSettingsRepository settings;
  final clock = _FixedClock(DateTime.utc(2026, 7, 3, 9));

  setUp(() async {
    db = AppDatabase.memory();
    // A deck needs an active language pair to own it.
    await db.into(db.languagePairs).insert(LanguagePairsCompanion.insert(
        id: 'lp',
        learningLanguage: 'ko',
        nativeLanguage: 'en',
        createdAt: 0,
        isActive: const Value(true)));
    decks = DriftDeckRepository(db, clock);
    cards = DriftCardRepository(db, clock);
    reviews = DriftReviewRepository(db, clock);
    settings = DriftSettingsRepository(db);
  });
  tearDown(() => db.close());

  T ok<T>(Result<T> r) => (r as Ok<T>).value;

  group('DeckRepository', () {
    test('save + watchChildren + getById', () async {
      ok(await decks.save(_deck('root', 'Root')));
      ok(await decks.save(_deck('child', 'Child', parent: 'root')));

      final roots = await decks.watchChildren(null).first;
      expect(roots.map((d) => d.id.value), ['root']);
      final children = await decks.watchChildren(const DeckId('root')).first;
      expect(children.single.name, 'Child');
      expect(ok(await decks.getById(const DeckId('child'))).parentId?.value, 'root');
    });

    test('delete cascades the subtree (D-024)', () async {
      ok(await decks.save(_deck('root', 'Root')));
      ok(await decks.save(_deck('child', 'Child', parent: 'root')));
      ok(await cards.save(_card('c1', 'child', '학교', ['school'])));

      ok(await decks.delete(const DeckId('root')));

      expect(await decks.watchChildren(null).first, isEmpty);
      expect((await cards.getById(const CardId('c1'))) is Err, isTrue);
    });

    test('statsFor aggregates the subtree', () async {
      ok(await decks.save(_deck('root', 'Root')));
      ok(await cards.save(_card('c1', 'root', 'a', ['x'])));
      ok(await cards.save(_card('c2', 'root', 'b', ['y'], hidden: true)));
      ok(await reviews.saveSchedule(
          cardId: const CardId('c1'), box: BoxLevel.mastered));

      final stats = ok(await decks.statsFor(const DeckId('root')));
      expect(stats.totalCards, 2);
      expect(stats.hiddenCount, 1);
      expect(stats.masteredCount, 1);
    });
  });

  group('CardRepository', () {
    setUp(() async => ok(await decks.save(_deck('d', 'Deck'))));

    test('save persists a card with its meanings (one transaction)', () async {
      ok(await cards.save(_card('c1', 'd', '사과', ['apple', 'the fruit'])));
      final list = await cards.watchByDeck(const DeckId('d')).first;
      expect(list.single.term, '사과');
      expect(list.single.meanings.map((m) => m.text), ['apple', 'the fruit']);
    });

    test('save replaces meanings on edit', () async {
      ok(await cards.save(_card('c1', 'd', '사과', ['apple', 'extra'])));
      ok(await cards.save(_card('c1', 'd', '사과', ['apple'])));
      final list = await cards.watchByDeck(const DeckId('d')).first;
      expect(list.single.meanings.map((m) => m.text), ['apple']);
    });

    test('setHidden toggles the flag; unknown card fails', () async {
      ok(await cards.save(_card('c1', 'd', 'a', ['x'])));
      ok(await cards.setHidden(const CardId('c1'), hidden: true));
      expect(ok(await cards.getById(const CardId('c1'))).hidden, isTrue);
      expect(await cards.setHidden(const CardId('nope'), hidden: true) is Err,
          isTrue);
    });

    test('search matches term or meaning, including hidden (D-019/D-028)', () async {
      ok(await cards.save(_card('c1', 'd', '학교', ['school'])));
      ok(await cards.save(_card('c2', 'd', 'schoolbag', ['bag'], hidden: true)));
      final hits = ok(await cards.search('school'));
      expect(hits.map((c) => c.id.value), containsAll(['c1', 'c2']));
    });
  });

  group('ReviewRepository', () {
    setUp(() async {
      ok(await decks.save(_deck('d', 'Deck')));
      ok(await cards.save(_card('c1', 'd', 'due', ['x'])));
      ok(await cards.save(_card('c2', 'd', 'new', ['y'])));
    });

    test('saveSchedule + currentBox + dueQueue honour the schedule', () async {
      final due = DateTime.utc(2026, 7, 3, 8); // an hour before "now"
      ok(await reviews.saveSchedule(
          cardId: const CardId('c1'), box: BoxLevel.firstBox, dueAt: due));

      expect(ok(await reviews.currentBox(const CardId('c1'))).value, 1);
      expect(ok(await reviews.currentBox(const CardId('c2'))).value, 0); // new

      final queue = ok(await reviews.dueQueue(asOf: clock.now()));
      expect(queue.map((c) => c.id.value), ['c1']);
    });

    test('newQueue returns unscheduled cards', () async {
      ok(await reviews.saveSchedule(
          cardId: const CardId('c1'), box: BoxLevel.firstBox, dueAt: clock.now()));
      final news = ok(await reviews.newQueue(limit: 10));
      expect(news.map((c) => c.id.value), ['c2']);
    });

    test('logReview appends and watchDueCount counts due cards', () async {
      ok(await reviews.saveSchedule(
          cardId: const CardId('c1'),
          box: BoxLevel.firstBox,
          dueAt: DateTime.utc(2026, 7, 3, 8)));
      ok(await reviews.logReview(ReviewLog(
          cardId: const CardId('c1'),
          grade: ReviewGrade.pass,
          reviewedAt: clock.now())));

      expect(await reviews.watchDueCount().first, 1);
      expect((await db.select(db.reviewLogs).get()).single.grade, 'pass');
    });
  });

  group('SettingsRepository', () {
    test('daily goal round-trips through the k/v store', () async {
      ok(await settings.saveDailyGoal(const DailyGoal(minutesTarget: 15)));
      final goal = await settings.watchDailyGoal().first;
      expect(goal.minutesTarget, 15);
      expect(goal.wordsTarget, isNull);
    });

    test('new-cards-per-day defaults to 20 then persists', () async {
      expect(await settings.watchNewCardsPerDay().first, 20);
      ok(await settings.saveNewCardsPerDay(30));
      expect(await settings.watchNewCardsPerDay().first, 30);
    });
  });
}
