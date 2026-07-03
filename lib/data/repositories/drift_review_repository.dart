import 'package:drift/drift.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/datasources/local/dao/review_dao.dart';
import 'package:memox_v4/data/models/mappers/card_mapper.dart';
import 'package:memox_v4/data/models/mappers/srs_mapper.dart';
import 'package:memox_v4/data/models/mappers/time_mapper.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_log.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';

/// Drift-backed [ReviewRepository] (DT.4). Queue reads take an injected `asOf`
/// (no wall clock) and exclude hidden cards (D-006); `saveSchedule` upserts the
/// SRS position (preserving `last_reviewed_at`); `logReview` appends history.
/// `within` scopes to a deck's subtree (D-009). Failures wrap as [Failure].
class DriftReviewRepository implements ReviewRepository {
  DriftReviewRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  ReviewDao get _dao => _db.reviewDao;

  @override
  Stream<int> watchDueCount({DeckId? within}) {
    // The badge is "now"-relative; the live stream re-reads on each write, so a
    // freshly-due card appears without a query-embedded wall clock.
    return Stream.fromFuture(_scope(within)).asyncExpand(
      (ids) => _dao.watchDueCount(withinIds: ids, asOf: _nowMicros()),
    );
  }

  @override
  Future<Result<List<Card>>> dueQueue({
    DeckId? within,
    required DateTime asOf,
    int? limit,
  }) =>
      guardAsync(() async {
        final rows = await _dao.dueQueue(
          withinIds: await _scope(within),
          asOf: dateTimeToMicros(asOf)!,
          limit: limit,
        );
        return _assemble(rows);
      });

  @override
  Future<Result<List<Card>>> newQueue({DeckId? within, required int limit}) =>
      guardAsync(() async {
        final rows = await _dao.newQueue(
          withinIds: await _scope(within),
          limit: limit,
        );
        return _assemble(rows);
      });

  @override
  Future<Result<BoxLevel>> currentBox(CardId cardId) =>
      guardAsync(() async => boxFromInt(await _dao.currentBox(cardId.value)));

  @override
  Future<Result<void>> saveSchedule({
    required CardId cardId,
    required BoxLevel box,
    DateTime? dueAt,
  }) =>
      guardAsync(() async {
        // `last_reviewed_at` is left absent so an update never clobbers it.
        await _db.into(_db.srsStates).insertOnConflictUpdate(
              SrsStatesCompanion(
                cardId: Value(cardId.value),
                box: Value(box.value),
                dueAt: Value(dateTimeToMicros(dueAt)),
              ),
            );
      });

  @override
  Future<Result<void>> logReview(ReviewLog log) => guardAsync(() async {
        final at = dateTimeToMicros(log.reviewedAt)!;
        await _db.into(_db.reviewLogs).insert(
              ReviewLogsCompanion.insert(
                id: 'rl-${log.cardId.value}-$at',
                cardId: log.cardId.value,
                grade: log.grade.name,
                reviewedAt: at,
              ),
              mode: InsertMode.insertOrReplace,
            );
      });

  Future<Set<String>?> _scope(DeckId? within) async =>
      within == null ? null : _db.deckDao.subtreeIds(within.value);

  int _nowMicros() => dateTimeToMicros(_clock.now())!;

  Future<List<Card>> _assemble(List<CardRow> rows) async {
    if (rows.isEmpty) return const [];
    final meanings = await _db.cardDao.meaningsFor([for (final r in rows) r.id]);
    final byCard = <String, List<CardMeaningRow>>{};
    for (final m in meanings) {
      (byCard[m.cardId] ??= []).add(m);
    }
    return [for (final row in rows) cardFromRows(row, byCard[row.id] ?? const [])];
  }
}
