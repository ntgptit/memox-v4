import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/srs_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show AppDatabase, CardCompanion, DeckCompanion, LanguagePairCompanion;
import 'package:memox_v4/data/repositories/srs_repository_impl.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';
import 'package:memox_v4/presentation/features/study/viewmodels/study_session_notifier.dart';

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
  late SrsRepositoryImpl srsRepo;
  late ProviderContainer container;
  late int deckId;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    srsRepo = SrsRepositoryImpl(SrsDao(db));
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(const _FixedClock(10000)),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<int> card() => db
      .into(db.card)
      .insert(CardCompanion.insert(deckId: deckId, term: 't', createdAt: 1));

  Future<StudySessionState> open(StudyRequest request) async {
    await container.read(languagePairProvider.future);
    container.listen(studySessionProvider(request), (_, _) {});
    return container.read(studySessionProvider(request).future);
  }

  StudySessionNotifier notifier(StudyRequest request) =>
      container.read(studySessionProvider(request).notifier);

  test(
    'D-002/D-017: NewLearn schedules into box 1 only after all 5 stages',
    () async {
      final c = await card();
      final request = StudyRequest(nodeId: deckId, entry: StudyEntry.newLearn);
      await open(request);
      final note = notifier(request);

      // D-017: quitting after 3 of 5 stages → still new (no srs row).
      await note.grade(true);
      await note.grade(true);
      await note.grade(true);
      expect((await srsRepo.stateFor(c)).valueOrNull, isNull);

      // Complete the remaining stages → box 1 (D-002).
      await note.grade(true);
      await note.grade(true);
      expect((await srsRepo.stateFor(c)).valueOrNull?.box, 1);
    },
  );

  test('D-015: a wrong answer re-queues the card within the stage', () async {
    await card();
    await card();
    final request = StudyRequest(nodeId: deckId, entry: StudyEntry.newLearn);
    final initial = await open(request);
    expect(initial.cards, hasLength(2));

    await notifier(request).grade(false);
    final state = container.read(studySessionProvider(request)).value!;
    expect(state.pending, hasLength(2));
    expect(state.stageIndex, 0);
  });

  test('D-007: DueReview grades the card into SRS', () async {
    final c = await card();
    await srsRepo.upsert(SrsState(cardId: c, box: 2, dueAt: 5000));
    final request = StudyRequest(nodeId: deckId, entry: StudyEntry.dueReview);
    await open(request);

    await notifier(request).grade(true);
    expect((await srsRepo.stateFor(c)).valueOrNull?.box, 3);
  });
}
