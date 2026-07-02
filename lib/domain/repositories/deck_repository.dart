import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';

/// The deck-tree contract (`Bộ thẻ`). **Frozen** once screens code against it (R4).
///
/// Read/write policy:
/// - `watch*` methods are the live read source — a stream backed by the local
///   store that re-emits on every change; the UI binds to these.
/// - `Future<Result<…>>` reads are one-shot lookups; writes return the persisted
///   entity (or void) or a [Failure]. Nothing throws across this boundary.
abstract interface class DeckRepository {
  /// Live children of [parentId] (root decks when null), for the library tree.
  Stream<List<Deck>> watchChildren(DeckId? parentId);

  /// One-shot fetch of a single deck.
  Future<Result<Deck>> getById(DeckId id);

  /// Recursively aggregated counts for a deck's subtree (deck-management BR-5).
  Future<Result<DeckStats>> statsFor(DeckId id);

  /// Upsert — create, rename, or move (persisting the new [Deck.parentId]).
  /// Cycle-free move (BR-3) is enforced by the caller/use case, not here.
  Future<Result<Deck>> save(Deck deck);

  /// Delete a deck and cascade the whole subtree — child decks, cards, meanings,
  /// SRS state (deck-management BR-4 / D-024).
  Future<Result<void>> delete(DeckId id);
}
