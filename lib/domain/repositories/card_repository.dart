import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';

/// The card contract (`Thẻ học`). **Frozen** once screens code against it (R4).
///
/// Read/write policy: `watch*`/`search` are the live/one-shot read source; writes
/// return the persisted entity (or void) or a [Failure]. Hidden cards are still
/// returned by [watchByDeck] (the deck-detail screen shows them, dimmed); it is
/// the review queues (ReviewRepository) that exclude them (BR-4).
abstract interface class CardRepository {
  /// Live cards in a deck (both visible and hidden), for the deck-detail list.
  Stream<List<Card>> watchByDeck(DeckId deckId);

  /// One-shot fetch of a single card.
  Future<Result<Card>> getById(CardId id);

  /// Upsert — create or edit. Soft-duplicate terms are allowed (BR-5 / D-020);
  /// any duplicate warning is a UI concern, not a persistence error.
  Future<Result<Card>> save(Card card);

  /// Delete a card and its meanings + SRS state.
  Future<Result<void>> delete(CardId id);

  /// Toggle the hidden flag (UC-3 / D-006) without rewriting the whole card.
  Future<Result<void>> setHidden(CardId id, {required bool hidden});

  /// Search cards by term and meaning — globally, or within a deck subtree
  /// (global-search). Returns matches ordered by the implementation's relevance.
  Future<Result<List<Card>>> search(String query, {DeckId? within});
}
