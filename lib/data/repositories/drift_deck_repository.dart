import 'package:drift/drift.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/datasources/local/dao/deck_dao.dart';
import 'package:memox_v4/data/models/mappers/deck_mapper.dart';
import 'package:memox_v4/data/models/mappers/time_mapper.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';

/// Drift-backed [DeckRepository] (DT.4). Reads go through [DeckDao]; writes fill
/// the store-only columns the domain [Deck] doesn't carry — `createdAt` (from the
/// injected [Clock], preserved on update) and `languagePairId` (the single active
/// pair). Deleting a deck cascades its subtree via the FKs (D-024). Failures are
/// wrapped as [Failure] by `guardAsync`; reads never throw across the boundary.
class DriftDeckRepository implements DeckRepository {
  DriftDeckRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  DeckDao get _dao => _db.deckDao;

  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) =>
      _dao.watchChildren(parentId?.value).map(
            (rows) => [for (final row in rows) deckFromRow(row)],
          );

  @override
  Future<Result<Deck>> getById(DeckId id) => guardAsync(() async {
        final row = await _dao.getById(id.value);
        // ignore: only_throw_errors
        if (row == null) throw NotFoundFailure('No deck ${id.value}');
        return deckFromRow(row);
      });

  @override
  Future<Result<DeckStats>> statsFor(DeckId id) => guardAsync(() async {
        final now = dateTimeToMicros(_clock.now())!;
        final s = await _dao.statsFor(id.value, asOf: now);
        return DeckStats(
          totalCards: s.totalCards,
          hiddenCount: s.hiddenCount,
          dueCount: s.dueCount,
          masteredCount: s.masteredCount,
        );
      });

  @override
  Future<Result<Deck>> save(Deck deck) => guardAsync(() async {
        final existing = await _dao.getById(deck.id.value);
        final createdAt =
            existing?.createdAt ?? dateTimeToMicros(_clock.now())!;
        final pairId = existing?.languagePairId ?? await _activePairId();
        await _db.into(_db.decks).insertOnConflictUpdate(
              DecksCompanion.insert(
                id: deck.id.value,
                name: deck.name,
                languagePairId: pairId,
                createdAt: createdAt,
                parentId: Value(deck.parentId?.value),
                sortIndex: Value(existing?.sortIndex ?? 0),
              ),
            );
        return deck;
      });

  @override
  Future<Result<void>> delete(DeckId id) => guardAsync(() async {
        // FK ON DELETE CASCADE drops the subtree: child decks + cards +
        // meanings + srs + review logs (D-024).
        await (_db.delete(_db.decks)..where((d) => d.id.equals(id.value))).go();
      });

  Future<String> _activePairId() async {
    final pair = await (_db.select(_db.languagePairs)
          ..where((p) => p.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
    if (pair == null) {
      // ignore: only_throw_errors
      throw const PersistenceFailure('No active language pair to own the deck');
    }
    return pair.id;
  }
}
