import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/datasources/local/tables.dart';

part 'card_dao.g.dart';

/// Card + meaning queries (DT.3): per-deck listing, lookups, and global search.
/// List reads carry an explicit, total `ORDER BY` with an `id` tie-break.
@DriftAccessor(tables: [Cards, CardMeanings])
class CardDao extends DatabaseAccessor<AppDatabase> with _$CardDaoMixin {
  CardDao(super.db);

  /// Cards in a single deck (not the subtree — the caller scopes), ordered stably
  /// by creation. Includes hidden cards; the caller filters per its rule.
  Stream<List<CardRow>> watchByDeck(String deckId) {
    final query = select(cards)
      ..where((c) => c.deckId.equals(deckId))
      ..orderBy([
        (c) => OrderingTerm(expression: c.createdAt),
        (c) => OrderingTerm(expression: c.id),
      ]);
    return query.watch();
  }

  Future<CardRow?> getById(String id) =>
      (select(cards)..where((c) => c.id.equals(id))).getSingleOrNull();

  /// Meanings for the given card ids, ordered by card then `sortIndex` (the first
  /// is the primary meaning), with an `id` tie-break.
  Future<List<CardMeaningRow>> meaningsFor(List<String> cardIds) {
    if (cardIds.isEmpty) return Future.value(const []);
    final query = select(cardMeanings)
      ..where((m) => m.cardId.isIn(cardIds))
      ..orderBy([
        (m) => OrderingTerm(expression: m.cardId),
        (m) => OrderingTerm(expression: m.sortIndex),
        (m) => OrderingTerm(expression: m.id),
      ]);
    return query.get();
  }

  /// Cards matching **every** [tokens] token on the term or any meaning content
  /// (AND across tokens, `D-019`), **including hidden cards** (`D-028`), optionally
  /// scoped to [withinIds] (a resolved subtree). Ordered stably by term then id.
  Future<List<CardRow>> search(
    List<String> tokens, {
    Set<String>? withinIds,
  }) {
    if (tokens.isEmpty) return Future.value(const []);

    final query = select(cards);
    for (final token in tokens) {
      final pattern = '%$token%';
      // The token hits the term, or a meaning of this card whose content matches.
      final meaningMatch = existsQuery(
        select(cardMeanings)
          ..where((m) =>
              m.cardId.equalsExp(cards.id) & m.content.like(pattern)),
      );
      query.where((c) => c.term.like(pattern) | meaningMatch);
    }
    if (withinIds != null) {
      query.where((c) => c.deckId.isIn(withinIds));
    }
    query.orderBy([
      (c) => OrderingTerm(expression: c.term),
      (c) => OrderingTerm(expression: c.id),
    ]);
    return query.get();
  }
}
