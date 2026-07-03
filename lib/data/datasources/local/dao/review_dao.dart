import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/datasources/local/tables.dart';

part 'review_dao.g.dart';

/// The box value of a brand-new, unscheduled card (kept in sync with
/// `BoxLevel.newCard`).
const int _newBox = 0;

/// SRS scheduling queries (DT.3): the due queue, the new queue, a card's current
/// box, and the live due count. Every read filters hidden cards out (`D-006`),
/// takes an injected `asOf` (no wall clock), and orders deterministically.
@DriftAccessor(tables: [Cards, SrsStates])
class ReviewDao extends DatabaseAccessor<AppDatabase> with _$ReviewDaoMixin {
  ReviewDao(super.db);

  /// Cards due at [asOf] (microseconds) — scheduled (`due_at <= asOf`), not hidden
  /// (`D-006`), optionally scoped to [withinIds]. Ordered by `due_at` then `id`;
  /// [limit] caps the batch.
  Future<List<CardRow>> dueQueue({
    Set<String>? withinIds,
    required int asOf,
    int? limit,
  }) {
    final query = select(cards).join([
      innerJoin(srsStates, srsStates.cardId.equalsExp(cards.id)),
    ])
      ..where(cards.hidden.not() &
          srsStates.dueAt.isNotNull() &
          srsStates.dueAt.isSmallerOrEqualValue(asOf))
      ..orderBy([
        OrderingTerm(expression: srsStates.dueAt),
        OrderingTerm(expression: cards.id),
      ]);
    if (withinIds != null) query.where(cards.deckId.isIn(withinIds));
    if (limit != null) query.limit(limit);
    return query.map((row) => row.readTable(cards)).get();
  }

  /// New (unscheduled) cards — no SRS row or `box = 0` — not hidden, optionally
  /// scoped. Ordered by creation then `id`; [limit] caps the intake (`D-018`).
  Future<List<CardRow>> newQueue({
    Set<String>? withinIds,
    required int limit,
  }) {
    final query = select(cards).join([
      leftOuterJoin(srsStates, srsStates.cardId.equalsExp(cards.id)),
    ])
      ..where(cards.hidden.not() &
          (srsStates.box.isNull() | srsStates.box.equals(_newBox)))
      ..orderBy([
        OrderingTerm(expression: cards.createdAt),
        OrderingTerm(expression: cards.id),
      ])
      ..limit(limit);
    if (withinIds != null) query.where(cards.deckId.isIn(withinIds));
    return query.map((row) => row.readTable(cards)).get();
  }

  /// The card's current Leitner box, or `0` (new) when it was never scheduled.
  Future<int> currentBox(String cardId) async {
    final row = await (select(srsStates)..where((s) => s.cardId.equals(cardId)))
        .getSingleOrNull();
    return row?.box ?? _newBox;
  }

  /// Live count of due, non-hidden cards (the badge source), optionally scoped.
  Stream<int> watchDueCount({Set<String>? withinIds, required int asOf}) {
    final query = select(cards).join([
      innerJoin(srsStates, srsStates.cardId.equalsExp(cards.id)),
    ])..where(cards.hidden.not() &
        srsStates.dueAt.isNotNull() &
        srsStates.dueAt.isSmallerOrEqualValue(asOf));
    if (withinIds != null) query.where(cards.deckId.isIn(withinIds));
    return query.watch().map((rows) => rows.length);
  }
}
