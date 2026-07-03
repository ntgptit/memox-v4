import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/repositories/drift_card_repository.dart';
import 'package:memox_v4/data/repositories/drift_deck_repository.dart';
import 'package:memox_v4/data/repositories/drift_review_repository.dart';
import 'package:memox_v4/data/seed/database_seeder.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/usecases/srs/srs_scheduler.dart';
import 'package:memox_v4/domain/usecases/study/grade_card.dart';

/// V.3 — cross-layer data integration: seed → DAO queries → repositories → the
/// study use cases, all against one in-memory (or file) Drift DB. Where the DT
/// unit tests probe a single query, these walk realistic multi-layer flows
/// (D-006 hidden, D-009 subtree, D-024 cascade, D-003 grade, D-010/D-002).
class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

const _rootId = DeckId('seed-korean-basics');
const _card1 = CardId('seed-card-1');

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);
  final clock = _FixedClock(now);

  late AppDatabase db;
  late DriftDeckRepository decks;
  late DriftCardRepository cards;
  late DriftReviewRepository reviews;

  Future<void> wire(AppDatabase database) async {
    db = database;
    decks = DriftDeckRepository(db, clock);
    cards = DriftCardRepository(db, clock);
    reviews = DriftReviewRepository(db, clock);
    await DatabaseSeeder(db, clock).seedSampleData();
  }

  setUp(() => wire(AppDatabase.memory()));
  tearDown(() => db.close());

  T ok<T>(Result<T> r) => (r as Ok<T>).value;

  group('seed → query correctness', () {
    test('the seeded queues + search + stats line up across layers', () async {
      final due = ok(await reviews.dueQueue(asOf: now));
      expect(due.map((c) => c.id.value), ['seed-card-1']); // card-1 due an hour ago

      final news = ok(await reviews.newQueue(limit: 10));
      expect(news.map((c) => c.id.value), ['seed-card-3']); // card-3 is new

      final hits = ok(await cards.search('con')); // "con mèo" / "con chó"
      expect(hits.map((c) => c.id.value), containsAll(['seed-card-2', 'seed-card-3']));

      final stats = ok(await decks.statsFor(_rootId));
      expect(stats.totalCards, 3);
      expect(stats.dueCount, 1);
      expect(stats.hiddenCount, 0);
    });
  });

  group('grade a due card (D-003) propagates across the stack', () {
    test('a pass reschedules it, empties the due queue, drops the badge', () async {
      final grade = GradeCard(
        reviews: reviews,
        scheduler: SrsScheduler(clock),
      );

      expect(await reviews.watchDueCount().first, 1);
      final result = ok(await grade.call(cardId: _card1, grade: ReviewGrade.pass));
      expect(result.box.value, 2); // box 1 → 2

      // No longer due at `now`; the badge reflects it; the log was written.
      expect(ok(await reviews.dueQueue(asOf: now)), isEmpty);
      expect(await reviews.watchDueCount().first, 0);
      expect((await db.select(db.reviewLogs).get()).single.grade, 'pass');
    });
  });

  group('hiding a card (D-006) removes it from queues + counts', () {
    test('a hidden due card leaves the due queue and stats due/hidden shift',
        () async {
      ok(await cards.setHidden(_card1, hidden: true));
      expect(ok(await reviews.dueQueue(asOf: now)), isEmpty);
      final stats = ok(await decks.statsFor(_rootId));
      expect(stats.dueCount, 0);
      expect(stats.hiddenCount, 1);
    });
  });

  group('deleting a deck (D-024) cascades through every read path', () {
    test('the subtree, its cards, queues, search and stats all clear', () async {
      ok(await decks.delete(_rootId));

      expect(await decks.watchChildren(null).first, isEmpty);
      expect(await cards.getById(_card1) is Err, isTrue);
      expect(ok(await reviews.dueQueue(asOf: now)), isEmpty);
      expect(ok(await cards.search('con')), isEmpty);
      expect(ok(await decks.statsFor(_rootId)).totalCards, 0);
    });
  });

  group('populated migration round-trip (file-backed)', () {
    test('seeded data survives a close + reopen with queries intact', () async {
      final dir = Directory.systemTemp.createTempSync('memox_v3');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/app.sqlite');

      await db.close(); // drop the in-memory DB from setUp
      await wire(AppDatabase(NativeDatabase(file))); // seed into the file

      await db.close();
      final reopened = AppDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      final reReviews = DriftReviewRepository(reopened, clock);

      final due = ok(await reReviews.dueQueue(asOf: now));
      expect(due.map((c) => c.id.value), ['seed-card-1']); // data survived
      // FK cascade still enforced after reopen (D-024).
      final fk =
          await reopened.customSelect('PRAGMA foreign_keys').getSingle();
      expect(fk.data.values.first, 1);
    });
  });
}
