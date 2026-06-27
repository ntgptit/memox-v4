import 'package:memox_v4/domain/types/card_status.dart';

/// A search hit: the card's term + a meaning snippet, its containing deck name,
/// the hidden flag, and the raw schedule (box/due) so the status can be derived
/// against a clock (`docs/business/search/global-search.md`).
class SearchResult {
  const SearchResult({
    required this.cardId,
    required this.deckId,
    required this.term,
    required this.meaning,
    required this.deckName,
    required this.hidden,
    this.box,
    this.dueAt,
  });

  final int cardId;
  final int deckId;
  final String term;
  final String meaning;
  final String deckName;
  final bool hidden;
  final int? box;
  final int? dueAt;

  /// The lifecycle status at [nowMs] (D-028 status filter / badge).
  CardStatus status(int nowMs) => deriveCardStatus(
    hidden: hidden,
    box: box,
    isDue:
        box != null &&
        box! >= 1 &&
        box! < 8 &&
        dueAt != null &&
        dueAt! <= nowMs,
  );
}
