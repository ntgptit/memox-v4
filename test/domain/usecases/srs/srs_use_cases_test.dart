import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/srs_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show AppDatabase, CardCompanion, DeckCompanion, LanguagePairCompanion;
import 'package:memox_v4/data/repositories/srs_repository_impl.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/types/box_interval.dart';
import 'package:memox_v4/domain/types/last_result.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/srs/build_due_queue.dart';
import 'package:memox_v4/domain/usecases/srs/build_new_queue.dart';
import 'package:memox_v4/domain/usecases/srs/compute_due_count.dart';
import 'package:memox_v4/domain/usecases/srs/grade_card.dart';
import 'package:memox_v4/domain/usecases/srs/schedule_new_card.dart';

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
  late SrsRepositoryImpl repository;
  late int deckId;
  const clock = _FixedClock(10000);

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    repository = SrsRepositoryImpl(SrsDao(db));
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

  Future<int> card({bool hidden = false}) => db
      .into(db.card)
      .insert(
        CardCompanion.insert(
          deckId: deckId,
          term: 't',
          createdAt: 1,
          hidden: Value(hidden),
        ),
      );

  test('D-002 + D-011: schedule writes box 1 and keeps a single row', () async {
    final c = await card();
    final scheduled = (await ScheduleNewCardUseCase(
      repository,
      clock,
    ).call(c)).valueOrNull!;
    expect(scheduled.box, 1);
    expect(await db.select(db.srsState).get(), hasLength(1));

    // Idempotent: scheduling again leaves the single box-1 row untouched.
    await ScheduleNewCardUseCase(repository, clock).call(c);
    expect(await db.select(db.srsState).get(), hasLength(1));
  });

  test('grade persists the new box and keeps one row (D-011)', () async {
    final c = await card();
    await ScheduleNewCardUseCase(repository, clock).call(c);
    await GradeCardUseCase(repository, clock).call(c, LastResult.correct);
    await GradeCardUseCase(repository, clock).call(c, LastResult.correct);

    expect((await repository.stateFor(c)).valueOrNull!.box, 3);
    expect(await db.select(db.srsState).get(), hasLength(1));
  });

  test('D-006: the due queue excludes hidden and not-yet-due cards', () async {
    final due = await card();
    final notDue = await card();
    final hidden = await card(hidden: true);
    for (final c in <int>[due, notDue, hidden]) {
      await ScheduleNewCardUseCase(repository, clock).call(c);
    }
    // Make `due` and `hidden` actually due (due_at in the past).
    await repository.upsert(SrsState(cardId: due, box: 2, dueAt: 5000));
    await repository.upsert(SrsState(cardId: hidden, box: 2, dueAt: 5000));

    final queue = (await BuildDueQueueUseCase(
      repository,
      clock,
    ).call(<int>[due, notDue, hidden])).valueOrNull!;
    expect(queue, <int>[due]);
  });

  test('D-018: the new queue is capped at the daily limit', () async {
    final cards = <int>[];
    for (var i = 0; i < 25; i++) {
      cards.add(await card());
    }
    final queue = (await BuildNewQueueUseCase(
      repository,
    ).call(cards, limit: kDefaultNewCardsPerDay)).valueOrNull!;
    expect(queue, hasLength(20));
  });

  test('the new queue excludes hidden and already-scheduled cards', () async {
    final fresh = await card();
    final hiddenNew = await card(hidden: true);
    final scheduled = await card();
    await ScheduleNewCardUseCase(repository, clock).call(scheduled);

    final queue = (await BuildNewQueueUseCase(
      repository,
    ).call(<int>[fresh, hiddenNew, scheduled])).valueOrNull!;
    expect(queue, <int>[fresh]);
  });

  test('computeDueCount matches the due queue size', () async {
    final c = await card();
    await repository.upsert(SrsState(cardId: c, box: 2, dueAt: 5000));
    expect(
      (await ComputeDueCountUseCase(
        repository,
        clock,
      ).call(<int>[c])).valueOrNull,
      1,
    );
  });
}
