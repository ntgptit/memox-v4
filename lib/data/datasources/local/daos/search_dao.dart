import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

/// One search hit row from the card⨝deck⨝srs query.
typedef SearchRow = ({
  int cardId,
  int deckId,
  String term,
  String meaning,
  String deckName,
  bool hidden,
  int? box,
  int? dueAt,
});

/// Searches `card` + `card_meaning` within a pair. The term is matched directly;
/// meanings via `EXISTS` so a multi-meaning card yields one row. Includes hidden
/// cards (D-028); the displayed meaning is the card's first.
class SearchDao {
  const SearchDao(this._db);

  final AppDatabase _db;

  Future<List<SearchRow>> search({
    required int pairId,
    required String query,
    List<int>? scopeCardIds,
  }) async {
    final like = '%${query.toLowerCase()}%';
    final sql = StringBuffer(
      'SELECT c.id AS card_id, c.deck_id AS deck_id, c.term AS term, '
      'c.hidden AS hidden, d.name AS deck_name, s.box AS box, s.due_at AS due_at, '
      '(SELECT cm.content FROM card_meaning cm WHERE cm.card_id = c.id LIMIT 1) '
      'AS meaning '
      'FROM card c JOIN deck d ON c.deck_id = d.id '
      'LEFT JOIN srs_state s ON s.card_id = c.id '
      'WHERE d.pair_id = ? AND (LOWER(c.term) LIKE ? OR EXISTS '
      '(SELECT 1 FROM card_meaning cm WHERE cm.card_id = c.id '
      'AND LOWER(cm.content) LIKE ?))',
    );
    final variables = <Variable<Object>>[
      Variable<int>(pairId),
      Variable<String>(like),
      Variable<String>(like),
    ];
    if (scopeCardIds != null && scopeCardIds.isNotEmpty) {
      final placeholders = List<String>.filled(
        scopeCardIds.length,
        '?',
      ).join(', ');
      sql.write(' AND c.id IN ($placeholders)');
      variables.addAll(scopeCardIds.map(Variable<int>.new));
    }
    sql.write(' ORDER BY c.order_index');

    final rows = await _db
        .customSelect(
          sql.toString(),
          variables: variables,
          readsFrom: <ResultSetImplementation<Object, Object>>{
            _db.card,
            _db.cardMeaning,
            _db.deck,
            _db.srsState,
          },
        )
        .get();
    return rows
        .map(
          (r) => (
            cardId: r.read<int>('card_id'),
            deckId: r.read<int>('deck_id'),
            term: r.read<String>('term'),
            meaning: r.readNullable<String>('meaning') ?? '',
            deckName: r.read<String>('deck_name'),
            hidden: r.read<int>('hidden') != 0,
            box: r.readNullable<int>('box'),
            dueAt: r.readNullable<int>('due_at'),
          ),
        )
        .toList(growable: false);
  }
}
