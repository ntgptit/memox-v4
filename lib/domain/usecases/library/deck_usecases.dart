import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';

/// Upsert a deck — create or rename. The [Deck] is already validated by
/// [Deck.create] (name required, BR-1), so this only persists it.
class SaveDeckUseCase {
  const SaveDeckUseCase(this._decks);

  final DeckRepository _decks;

  Future<Result<Deck>> call(Deck deck) => _decks.save(deck);
}

/// Move a deck under a new parent (or to the root when [newParentId] is null),
/// rejecting any move that would create a cycle — a deck cannot become its own
/// parent nor move into its own subtree (deck-management BR-3 / AC-3).
class MoveDeckUseCase {
  const MoveDeckUseCase(this._decks);

  final DeckRepository _decks;

  Future<Result<Deck>> call({
    required DeckId deckId,
    required DeckId? newParentId,
  }) async {
    if (newParentId == deckId) {
      return const Err(ValidationFailure('A deck cannot be its own parent'));
    }

    // Walk up from the target parent; reaching [deckId] means the target is
    // inside the moving deck's own subtree — a cycle.
    var cursor = newParentId;
    while (cursor != null) {
      final ancestor = await _decks.getById(cursor);
      if (ancestor case Err(:final failure)) return Err(failure);
      final node = (ancestor as Ok<Deck>).value;
      if (node.id == deckId) {
        return const Err(
          ValidationFailure('Cannot move a deck into its own subtree'),
        );
      }
      cursor = node.parentId;
    }

    final current = await _decks.getById(deckId);
    if (current case Err(:final failure)) return Err(failure);
    final deck = (current as Ok<Deck>).value;

    final moved = Deck.create(
      id: deck.id,
      name: deck.name,
      parentId: newParentId,
    );
    if (moved case Err(:final failure)) return Err(failure);
    return _decks.save((moved as Ok<Deck>).value);
  }
}

/// Delete a deck; the repository cascades the whole subtree — child decks, cards,
/// meanings, SRS state (deck-management BR-4 / D-024).
class DeleteDeckUseCase {
  const DeleteDeckUseCase(this._decks);

  final DeckRepository _decks;

  Future<Result<void>> call(DeckId deckId) => _decks.delete(deckId);
}
