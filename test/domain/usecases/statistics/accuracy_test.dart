import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/stats_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show
        AppDatabase,
        CardCompanion,
        DeckCompanion,
        LanguagePairCompanion,
        ReviewOutcomeCompanion;
import 'package:memox_v4/data/repositories/statistics_repository_impl.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/statistics/get_statistics.dart';

class _FixedClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 6, 28, 10);
  @override
  DateTime nowUtc() => now().toUtc();
}

void main() {
  late AppDatabase db;
  late GetStatisticsUseCase useCase;
  late int pairId;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    useCase = GetStatisticsUseCase(
      StatisticsRepositoryImpl(StatsDao(db)),
      _FixedClock(),
    );
    pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    final deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    final cardId = await db
        .into(db.card)
        .insert(
          CardCompanion.insert(deckId: deckId, term: 'xin', createdAt: 1),
        );
    Future<void> outcome(bool correct) => db
        .into(db.reviewOutcome)
        .insert(
          ReviewOutcomeCompanion.insert(
            cardId: cardId,
            pairId: pairId,
            ts: 1000,
            correct: correct ? 1 : 0,
            mode: 'dueReview',
          ),
        );
    await outcome(true);
    await outcome(true);
    await outcome(false);
  });
  tearDown(() => db.close());

  test('accuracy = correct / total over review_outcome', () async {
    final summary = (await useCase.call(pairId: pairId)).valueOrNull!;
    expect(summary.accuracyTotal, 3);
    expect(summary.accuracyCorrect, 2);
    expect(summary.accuracy, closeTo(2 / 3, 1e-9));
    expect(summary.hasReviews, isTrue);
  });

  test('no reviews → accuracy 0, hasReviews false', () async {
    final other = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ja', targetLang: 'vi'),
        );
    final summary = (await useCase.call(pairId: other)).valueOrNull!;
    expect(summary.accuracyTotal, 0);
    expect(summary.accuracy, 0);
    expect(summary.hasReviews, isFalse);
  });
}
