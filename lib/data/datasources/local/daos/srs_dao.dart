import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

/// A card joined with its (optional) schedule row.
typedef CardScheduleRow = ({int cardId, bool hidden, int? box, int? dueAt});

/// Typed access to `srs_state` plus the card⨝srs join the queue builders need.
class SrsDao {
  const SrsDao(this._db);

  final AppDatabase _db;

  Future<SrsStateData?> stateFor(int cardId) => (_db.select(
    _db.srsState,
  )..where((t) => t.cardId.equals(cardId))).getSingleOrNull();

  Future<void> upsert({
    required int cardId,
    required int box,
    int? dueAt,
    String? lastResult,
    int? reviewedAt,
  }) => _db
      .into(_db.srsState)
      .insertOnConflictUpdate(
        SrsStateCompanion.insert(
          cardId: Value(cardId),
          box: Value(box),
          dueAt: Value(dueAt),
          lastResult: Value(lastResult),
          reviewedAt: Value(reviewedAt),
        ),
      );

  /// For each of [cardIds], the card's hidden flag and box/due (null box when no
  /// schedule row exists). A single LEFT JOIN so callers filter in Dart.
  Future<List<CardScheduleRow>> scheduleRows(List<int> cardIds) async {
    if (cardIds.isEmpty) return const <CardScheduleRow>[];
    final placeholders = List<String>.filled(cardIds.length, '?').join(', ');
    final rows = await _db
        .customSelect(
          'SELECT c.id AS card_id, c.hidden AS hidden, s.box AS box, '
          's.due_at AS due_at '
          'FROM card c LEFT JOIN srs_state s ON s.card_id = c.id '
          'WHERE c.id IN ($placeholders)',
          variables: cardIds.map(Variable<int>.new).toList(growable: false),
          readsFrom: <ResultSetImplementation<Object, Object>>{
            _db.card,
            _db.srsState,
          },
        )
        .get();
    return rows
        .map(
          (r) => (
            cardId: r.read<int>('card_id'),
            hidden: r.read<int>('hidden') != 0,
            box: r.readNullable<int>('box'),
            dueAt: r.readNullable<int>('due_at'),
          ),
        )
        .toList(growable: false);
  }
}
