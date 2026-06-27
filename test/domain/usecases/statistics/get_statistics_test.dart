import 'package:drift/drift.dart' show Value;
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
        SrsStateCompanion;
import 'package:memox_v4/data/repositories/statistics_repository_impl.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/statistics/get_statistics.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
  @override
  DateTime nowUtc() => _now.toUtc();
}

void main() {
  late AppDatabase db;
  late GetStatisticsUseCase useCase;
  late int pairA;
  late int pairB;
  late int deckA;
  late int deckB;
  final today = DateTime(2026, 6, 28, 10);

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    useCase = GetStatisticsUseCase(
      StatisticsRepositoryImpl(StatsDao(db)),
      _FixedClock(today),
    );
    pairA = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    pairB = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ja', targetLang: 'vi'),
        );
    deckA = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairA, name: 'A'));
    deckB = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairB, name: 'B'));
  });
  tearDown(() => db.close());

  Future<int> card(int deckId, String term, {bool hidden = false}) => db
      .into(db.card)
      .insert(
        CardCompanion.insert(
          deckId: deckId,
          term: term,
          createdAt: 1,
          hidden: Value(hidden),
        ),
      );

  Future<void> srs(int cardId, int box, {int? dueAt}) => db
      .into(db.srsState)
      .insert(
        SrsStateCompanion.insert(
          cardId: Value(cardId),
          box: Value(box),
          dueAt: Value(dueAt),
        ),
      );

  test('current-pair scope counts only that pair, excludes hidden', () async {
    final mastered = await card(deckA, 'a');
    final due = await card(deckA, 'b');
    await card(deckA, 'c'); // new (no srs)
    await card(deckA, 'h', hidden: true); // excluded
    await srs(mastered, 8);
    await srs(
      due,
      2,
      dueAt: today.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
    );
    await card(deckB, 'z'); // other pair → excluded from current-pair scope

    final summary = (await useCase.call(pairId: pairA)).valueOrNull!;
    expect(summary.pairs, 1);
    expect(summary.decks, 1);
    expect(summary.words, 3); // hidden excluded
    expect(summary.mastered, 1);
    expect(summary.boxCounts[0], 1); // new
    expect(summary.boxCounts[2], 1); // due card in box 2
    expect(summary.boxCounts[8], 1); // mastered
    expect(summary.masteredProgress, closeTo(1 / 3, 1e-9));
    expect(summary.dueForecast[0], 1); // overdue counts as today
  });

  test('all-app scope spans both pairs', () async {
    final m = await card(deckA, 'a');
    await srs(m, 8);
    final b5 = await card(deckB, 'b');
    await srs(b5, 5);

    final summary = (await useCase.call(pairId: null)).valueOrNull!;
    expect(summary.pairs, 2);
    expect(summary.decks, 2);
    expect(summary.words, 2);
    expect(summary.mastered, 1);
    expect(summary.boxCounts[5], 1);
    expect(summary.boxCounts[8], 1);
  });

  test('empty scope has no data', () async {
    final summary = (await useCase.call(pairId: pairA)).valueOrNull!;
    expect(summary.hasEnoughData, isFalse);
    expect(summary.words, 0);
  });
}
