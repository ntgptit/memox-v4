import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

/// Typed access to the `deck` table plus the read queries the recursive stats
/// need from `card`/`srs_state`. Returns Drift rows; mapping + aggregation is the
/// repository's job (`docs/database/schema-contract.md`).
class DeckDao {
  const DeckDao(this._db);

  final AppDatabase _db;

  Future<List<DeckData>> decksForPair(int pairId) =>
      (_db.select(_db.deck)
            ..where((t) => t.pairId.equals(pairId))
            ..orderBy(<OrderClauseGenerator<Deck>>[
              (t) => OrderingTerm(expression: t.orderIndex),
            ]))
          .get();

  Future<DeckData?> deckById(int id) =>
      (_db.select(_db.deck)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<CardData>> cardsIn(List<int> deckIds) {
    if (deckIds.isEmpty) return Future.value(const <CardData>[]);
    return (_db.select(_db.card)..where((t) => t.deckId.isIn(deckIds))).get();
  }

  Future<List<SrsStateData>> srsFor(List<int> cardIds) {
    if (cardIds.isEmpty) return Future.value(const <SrsStateData>[]);
    return (_db.select(
      _db.srsState,
    )..where((t) => t.cardId.isIn(cardIds))).get();
  }

  /// Number of sibling decks (same pair + same parent) — the next `order_index`.
  Future<int> siblingCount(int pairId, int? parentDeckId) async {
    final count = _db.deck.id.count();
    final query = _db.selectOnly(_db.deck)
      ..addColumns(<Expression<Object>>[count])
      ..where(
        _db.deck.pairId.equals(pairId) &
            (parentDeckId == null
                ? _db.deck.parentDeckId.isNull()
                : _db.deck.parentDeckId.equals(parentDeckId)),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> insertDeck({
    required int pairId,
    int? parentDeckId,
    required String name,
    required int orderIndex,
  }) => _db
      .into(_db.deck)
      .insert(
        DeckCompanion.insert(
          pairId: pairId,
          name: name,
          parentDeckId: Value(parentDeckId),
          orderIndex: Value(orderIndex),
        ),
      );

  Future<void> renameDeck(int id, String name) => (_db.update(
    _db.deck,
  )..where((t) => t.id.equals(id))).write(DeckCompanion(name: Value(name)));

  Future<void> updateParent(int id, int? newParentId) =>
      (_db.update(_db.deck)..where((t) => t.id.equals(id))).write(
        DeckCompanion(parentDeckId: Value(newParentId)),
      );

  Future<void> deleteDeck(int id) =>
      (_db.delete(_db.deck)..where((t) => t.id.equals(id))).go();
}
