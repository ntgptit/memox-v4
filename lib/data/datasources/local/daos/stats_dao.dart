import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/domain/models/statistics_summary.dart';

/// Read-only aggregate queries over `card`/`srs_state`/`daily_activity`. All
/// counts exclude hidden cards (consistent with deck stats / D-006).
class StatsDao {
  const StatsDao(this._db);

  final AppDatabase _db;

  Future<StatsRaw> read(int? pairId) async {
    final accuracy = await _accuracy(pairId);
    return (
      pairs: await _pairs(pairId),
      decks: await _decks(pairId),
      boxes: await _boxes(pairId),
      dueAts: await _dueAts(pairId),
      activity: await _activity(pairId),
      accuracyCorrect: accuracy.correct,
      accuracyTotal: accuracy.total,
    );
  }

  Future<({int correct, int total})> _accuracy(int? pairId) async {
    final where = pairId == null ? '' : ' WHERE pair_id = ?';
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS total, COALESCE(SUM(correct), 0) AS correct '
          'FROM review_outcome$where',
          variables: _scopeVar(pairId),
          readsFrom: <ResultSetImplementation<Object, Object>>{
            _db.reviewOutcome,
          },
        )
        .getSingle();
    return (correct: row.read<int>('correct'), total: row.read<int>('total'));
  }

  List<Variable<Object>> _scopeVar(int? pairId) => pairId == null
      ? const <Variable<Object>>[]
      : <Variable<Object>>[Variable<int>(pairId)];

  Future<int> _pairs(int? pairId) async {
    if (pairId != null) return 1;
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS n FROM language_pair',
          readsFrom: <ResultSetImplementation<Object, Object>>{
            _db.languagePair,
          },
        )
        .getSingle();
    return row.read<int>('n');
  }

  Future<int> _decks(int? pairId) async {
    final where = pairId == null ? '' : ' WHERE pair_id = ?';
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS n FROM deck$where',
          variables: _scopeVar(pairId),
          readsFrom: <ResultSetImplementation<Object, Object>>{_db.deck},
        )
        .getSingle();
    return row.read<int>('n');
  }

  Future<List<BoxCount>> _boxes(int? pairId) async {
    final scope = pairId == null ? '' : ' AND d.pair_id = ?';
    final rows = await _db
        .customSelect(
          'SELECT COALESCE(s.box, 0) AS box, COUNT(*) AS n '
          'FROM card c JOIN deck d ON c.deck_id = d.id '
          'LEFT JOIN srs_state s ON s.card_id = c.id '
          'WHERE c.hidden = 0$scope '
          'GROUP BY COALESCE(s.box, 0)',
          variables: _scopeVar(pairId),
          readsFrom: <ResultSetImplementation<Object, Object>>{
            _db.card,
            _db.deck,
            _db.srsState,
          },
        )
        .get();
    return <BoxCount>[
      for (final r in rows) (box: r.read<int>('box'), count: r.read<int>('n')),
    ];
  }

  Future<List<int>> _dueAts(int? pairId) async {
    final scope = pairId == null ? '' : ' AND d.pair_id = ?';
    final rows = await _db
        .customSelect(
          'SELECT s.due_at AS due_at FROM srs_state s '
          'JOIN card c ON s.card_id = c.id JOIN deck d ON c.deck_id = d.id '
          'WHERE c.hidden = 0 AND s.box >= 1 AND s.box < 8 '
          'AND s.due_at IS NOT NULL$scope',
          variables: _scopeVar(pairId),
          readsFrom: <ResultSetImplementation<Object, Object>>{
            _db.card,
            _db.deck,
            _db.srsState,
          },
        )
        .get();
    return <int>[for (final r in rows) r.read<int>('due_at')];
  }

  Future<List<ActivityPoint>> _activity(int? pairId) async {
    final where = pairId == null ? '' : ' WHERE pair_id = ?';
    final rows = await _db
        .customSelect(
          'SELECT day AS day, seconds AS seconds, words AS words '
          'FROM daily_activity$where',
          variables: _scopeVar(pairId),
          readsFrom: <ResultSetImplementation<Object, Object>>{
            _db.dailyActivity,
          },
        )
        .get();
    return <ActivityPoint>[
      for (final r in rows)
        (
          day: r.read<String>('day'),
          seconds: r.read<int>('seconds'),
          words: r.read<int>('words'),
        ),
    ];
  }
}
