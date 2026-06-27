/// A card reduced to what the games need: its id, term, and native meaning.
class GameCard {
  const GameCard({
    required this.cardId,
    required this.term,
    required this.meaning,
  });

  final int cardId;
  final String term;
  final String meaning;
}
