import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';

/// Upsert a card — create or edit. The [Card] is already validated by
/// [Card.create] (term + ≥1 meaning, BR-2). Duplicate terms are allowed; the
/// warning is surfaced separately by [DetectDuplicateTermUseCase] (BR-5 / D-020).
class SaveCardUseCase {
  const SaveCardUseCase(this._cards);

  final CardRepository _cards;

  Future<Result<Card>> call(Card card) => _cards.save(card);
}

/// Delete a card and its meanings + SRS state.
class DeleteCardUseCase {
  const DeleteCardUseCase(this._cards);

  final CardRepository _cards;

  Future<Result<void>> call(CardId cardId) => _cards.delete(cardId);
}

/// Toggle a card's hidden flag — a hidden card leaves the review queue + due
/// count but is kept (flashcard UC-3 / D-006).
class SetCardHiddenUseCase {
  const SetCardHiddenUseCase(this._cards);

  final CardRepository _cards;

  Future<Result<void>> call(CardId cardId, {required bool hidden}) =>
      _cards.setHidden(cardId, hidden: hidden);
}

/// Search cards by term + meaning, globally or within a node's subtree
/// (global-search). An empty query yields no results. Matching semantics are
/// D-019 (see `CardSearchUseCase`); the repository applies them in the store.
class SearchCardsUseCase {
  const SearchCardsUseCase(this._cards);

  final CardRepository _cards;

  Future<Result<List<Card>>> call(String query, {DeckId? within}) {
    if (query.trim().isEmpty) return Future.value(const Ok([]));
    return _cards.search(query, within: within);
  }
}

/// Soft-duplicate detection: reports whether the deck already holds a card with
/// the same term (case-insensitive). A duplicate is only a warning — the caller
/// still allows the save (BR-5 / D-020). When editing, [excluding] skips the card
/// being edited so it never flags itself.
class DetectDuplicateTermUseCase {
  const DetectDuplicateTermUseCase(this._cards);

  final CardRepository _cards;

  Future<Result<bool>> call({
    required DeckId deckId,
    required String term,
    CardId? excluding,
  }) {
    final needle = term.trim().toLowerCase();
    return guardAsync(() async {
      final existing = await _cards.watchByDeck(deckId).first;
      return existing.any(
        (card) =>
            card.id != excluding && card.term.trim().toLowerCase() == needle,
      );
    });
  }
}
