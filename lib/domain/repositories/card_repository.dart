import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/models/card_draft.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Persists cards and their meanings (`docs/contracts/repository-contracts`).
/// Backing tables: `card`, `card_meaning` (delete cascades to `card_meaning` and
/// `srs_state`) — see `docs/database/schema-contract.md`. Errors map to
/// [Failure] at the implementation boundary; no state lives only in memory.
abstract interface class CardRepository {
  /// Cards of a deck ordered by `order_index`; hidden ones included unless
  /// [includeHidden] is false.
  Future<Result<List<Card>>> listByDeck(
    int deckId, {
    bool includeHidden = true,
  });

  /// One card with its meanings, or null when absent.
  Future<Result<Card?>> getById(int id);

  /// Creates a card (appended after the deck's current last) with its meanings.
  Future<Result<Card>> create(CardDraft draft);

  /// Replaces a card's fields and meaning set.
  Future<Result<Card>> update(int id, CardDraft draft);

  /// Deletes a card; cascade removes its meanings and srs state (D-024 family).
  Future<Result<void>> delete(int id);

  /// Toggles the hidden flag (D-006).
  Future<Result<void>> setHidden(int id, {required bool hidden});

  /// Whether [term] already exists in [deckId] (case-insensitive) — the soft
  /// duplicate check (D-020); never blocks, only informs.
  Future<Result<bool>> termExists(
    int deckId,
    String term, {
    int? excludingCardId,
  });

  /// Count of non-hidden cards in a deck — the "X words" shown on a node (BR-6,
  /// D-006 excludes hidden).
  Future<Result<int>> visibleCount(int deckId);
}
