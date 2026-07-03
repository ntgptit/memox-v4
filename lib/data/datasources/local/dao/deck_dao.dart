import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/datasources/local/tables.dart';

part 'deck_dao.g.dart';

/// The Leitner box that marks a card mastered (BR-5) — kept in sync with the
/// domain `BoxLevel.mastered`.
const int _masteredBox = 8;

/// Aggregated per-subtree card counts (raw row data; mapped to `DeckStats` in
/// DT.4). A parent deck covers its whole subtree recursively (D-009 / BR-6).
class DeckStatsRow {
  const DeckStatsRow({
    required this.totalCards,
    required this.hiddenCount,
    required this.dueCount,
    required this.masteredCount,
  });

  final int totalCards;
  final int hiddenCount;
  final int dueCount;
  final int masteredCount;
}

/// Deck-tree queries (DT.3): children listing, subtree resolution, and the
/// per-subtree stats aggregation. All list reads carry an explicit, total
/// `ORDER BY` with an `id` tie-break (deterministic ordering policy); the due
/// filter takes an injected `asOf` — no wall clock.
@DriftAccessor(tables: [Decks, Cards, SrsStates])
class DeckDao extends DatabaseAccessor<AppDatabase> with _$DeckDaoMixin {
  DeckDao(super.db);

  /// Immediate children of [parentId] (roots when null), ordered stably.
  Stream<List<DeckRow>> watchChildren(String? parentId) {
    final query = select(decks)
      ..where((d) =>
          parentId == null ? d.parentId.isNull() : d.parentId.equals(parentId))
      ..orderBy([
        (d) => OrderingTerm(expression: d.sortIndex),
        (d) => OrderingTerm(expression: d.createdAt),
        (d) => OrderingTerm(expression: d.id),
      ]);
    return query.watch();
  }

  Future<DeckRow?> getById(String id) =>
      (select(decks)..where((d) => d.id.equals(id))).getSingleOrNull();

  /// Every deck id in [rootId]'s subtree, root included (D-009). Resolved in Dart
  /// over a single decks scan — deterministic and injection-free; a recursive CTE
  /// is a later optimization.
  Future<Set<String>> subtreeIds(String rootId) async {
    final all = await select(decks).get();
    final childrenByParent = <String, List<String>>{};
    for (final deck in all) {
      (childrenByParent[deck.parentId ?? ''] ??= []).add(deck.id);
    }
    final ids = <String>{};
    final stack = <String>[rootId];
    while (stack.isNotEmpty) {
      final id = stack.removeLast();
      if (!ids.add(id)) continue;
      stack.addAll(childrenByParent[id] ?? const []);
    }
    return ids;
  }

  /// Aggregated card counts over [rootId]'s subtree at [asOf] (microseconds).
  Future<DeckStatsRow> statsFor(String rootId, {required int asOf}) async {
    final ids = await subtreeIds(rootId);
    if (ids.isEmpty) {
      return const DeckStatsRow(
          totalCards: 0, hiddenCount: 0, dueCount: 0, masteredCount: 0);
    }

    final rows = await (select(cards).join([
      leftOuterJoin(srsStates, srsStates.cardId.equalsExp(cards.id)),
    ])..where(cards.deckId.isIn(ids)))
        .get();

    var total = 0;
    var hidden = 0;
    var due = 0;
    var mastered = 0;
    for (final row in rows) {
      final card = row.readTable(cards);
      final srs = row.readTableOrNull(srsStates);
      total++;
      if (card.hidden) {
        hidden++;
        continue; // hidden cards never count toward due/mastered (D-006/BR-8).
      }
      if (srs?.box == _masteredBox) mastered++;
      final dueAt = srs?.dueAt;
      if (dueAt != null && dueAt <= asOf) due++;
    }
    return DeckStatsRow(
      totalCards: total,
      hiddenCount: hidden,
      dueCount: due,
      masteredCount: mastered,
    );
  }
}
