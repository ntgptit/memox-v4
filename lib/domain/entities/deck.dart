/// A library node that self-nests via [parentDeckId]: a deck holds direct cards
/// AND sub-decks (a mixed node). A root deck has a null parent
/// (`docs/business/deck/deck-management.md`). Aggregate counts live in
/// `DeckStats`, not on the entity.
class Deck {
  const Deck({
    required this.id,
    required this.pairId,
    required this.name,
    required this.orderIndex,
    this.parentDeckId,
  });

  final int id;
  final int pairId;

  /// Parent deck id, or null for a root deck.
  final int? parentDeckId;

  final String name;
  final int orderIndex;
}
