import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/daily_activity_dao.dart';
import 'package:memox_v4/data/datasources/local/daos/deck_dao.dart';
import 'package:memox_v4/data/datasources/local/daos/srs_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show AppDatabase, CardCompanion, LanguagePairCompanion;
import 'package:memox_v4/data/repositories/daily_activity_repository_impl.dart';
import 'package:memox_v4/data/repositories/deck_repository_impl.dart';
import 'package:memox_v4/data/repositories/srs_repository_impl.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/domain/usecases/study/build_play_menu.dart';
import 'package:memox_v4/domain/usecases/study/finalize_study_session.dart';

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
  late DeckRepositoryImpl deckRepo;
  late SrsRepositoryImpl srsRepo;
  late DailyActivityRepositoryImpl dailyRepo;
  late int pairId;
  late int rootDeck;
  const clock = _FixedClock(10000);

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    deckRepo = DeckRepositoryImpl(DeckDao(db), clock);
    srsRepo = SrsRepositoryImpl(SrsDao(db));
    dailyRepo = DailyActivityRepositoryImpl(DailyActivityDao(db));
    pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    rootDeck = (await deckRepo.create(
      pairId: pairId,
      name: 'Root',
    )).valueOrNull!.id;
  });
  tearDown(() => db.close());

  Future<int> card(int deckId) => db
      .into(db.card)
      .insert(CardCompanion.insert(deckId: deckId, term: 't', createdAt: 1));

  test(
    'D-009: subtreeCardIds gathers cards recursively over the subtree',
    () async {
      final child = (await deckRepo.create(
        pairId: pairId,
        parentDeckId: rootDeck,
        name: 'Child',
      )).valueOrNull!.id;
      final cRoot = await card(rootDeck);
      final cChild = await card(child);

      final ids = (await deckRepo.subtreeCardIds(rootDeck)).valueOrNull!;
      expect(ids.toSet(), <int>{cRoot, cChild});
    },
  );

  test('D-001/D-016: the Play menu gates "Lặp lại" on due > 0', () async {
    final c = await card(rootDeck);

    final menu = BuildPlayMenuUseCase(deckRepo, srsRepo, clock);
    var built = (await menu.call(rootDeck)).valueOrNull!;
    expect(built.entries.contains(StudyEntry.dueReview), isFalse);
    expect(built.entries.contains(StudyEntry.newLearn), isTrue);

    await srsRepo.upsert(SrsState(cardId: c, box: 2, dueAt: 5000));
    built = (await menu.call(rootDeck)).valueOrNull!;
    expect(built.dueCount, 1);
    expect(built.entries.contains(StudyEntry.dueReview), isTrue);
    expect(built.entries.contains(StudyEntry.newLearn), isFalse);
  });

  test('D-010: only DueReview/NewLearn add to daily activity', () async {
    final finalize = FinalizeStudySessionUseCase(dailyRepo, clock);
    await finalize.call(
      pairId: pairId,
      entry: StudyEntry.review,
      seconds: 60,
      words: 5,
    );
    await finalize.call(
      pairId: pairId,
      entry: StudyEntry.game,
      seconds: 60,
      words: 5,
    );
    await finalize.call(
      pairId: pairId,
      entry: StudyEntry.player,
      seconds: 60,
      words: 5,
    );
    expect(await db.select(db.dailyActivity).get(), isEmpty);

    await finalize.call(
      pairId: pairId,
      entry: StudyEntry.dueReview,
      seconds: 30,
      words: 3,
    );
    await finalize.call(
      pairId: pairId,
      entry: StudyEntry.newLearn,
      seconds: 20,
      words: 2,
    );
    final rows = await db.select(db.dailyActivity).get();
    expect(rows, hasLength(1));
    expect(rows.first.seconds, 50);
    expect(rows.first.words, 5);
  });
}
