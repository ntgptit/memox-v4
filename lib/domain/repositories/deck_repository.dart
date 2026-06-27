import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Persists the self-nesting deck tree and computes recursive aggregate stats
/// (`docs/contracts/repository-contracts`). Backing table `deck` (self-FK
/// `parent_deck_id`, delete cascades the subtree). Errors map to [Failure] at
/// the boundary; no state lives only in memory.
abstract interface class DeckRepository {
  /// The full library tree for a pair: root nodes with nested children and
  /// recursive stats, ordered by `order_index`.
  Future<Result<List<DeckNode>>> libraryTree(int pairId);

  /// One deck's node (deck + recursive stats + child nodes), or null if absent.
  Future<Result<DeckNode?>> node(int deckId);

  /// All card ids in a deck's subtree (itself + descendants), for recursive
  /// study/games (D-009). Hidden cards excluded unless [includeHidden].
  Future<Result<List<int>>> subtreeCardIds(
    int deckId, {
    bool includeHidden = false,
  });

  /// Creates a deck at root (`parentDeckId` null) or under a parent.
  Future<Result<Deck>> create({
    required int pairId,
    int? parentDeckId,
    required String name,
  });

  /// Renames a deck.
  Future<Result<Deck>> rename(int id, String name);

  /// Moves a deck under a new parent (null = root). Rejects a move that would
  /// create a cycle (into its own subtree) — BR-3.
  Future<Result<void>> move(int id, {int? newParentId});

  /// Deletes a deck; cascade removes the whole subtree (BR-4 / D-024).
  Future<Result<void>> delete(int id);
}
