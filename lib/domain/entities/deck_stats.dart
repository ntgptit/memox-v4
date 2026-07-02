import 'package:equatable/equatable.dart';

/// Aggregated counts for a deck node (`số thẻ, tiến độ, số đến hạn, số ẩn`),
/// summed recursively over the subtree (deck-management BR-5). Hidden cards are
/// counted separately and excluded from the visible/word count (BR-6) and due
/// count (BR-8).
class DeckStats extends Equatable {
  const DeckStats({
    required this.totalCards,
    required this.hiddenCount,
    required this.dueCount,
    required this.masteredCount,
  })  : assert(totalCards >= 0, 'totalCards must be >= 0'),
        assert(hiddenCount >= 0 && hiddenCount <= totalCards,
            'hiddenCount must be within 0..totalCards');

  static const DeckStats empty =
      DeckStats(totalCards: 0, hiddenCount: 0, dueCount: 0, masteredCount: 0);

  final int totalCards;
  final int hiddenCount;
  final int dueCount;
  final int masteredCount;

  /// Cards shown to the learner — total minus hidden (the "X từ" count, BR-6).
  int get visibleCount => totalCards - hiddenCount;

  /// Mastered over visible cards (`Progress`). Zero when there is nothing visible.
  double get progress =>
      visibleCount == 0 ? 0 : masteredCount / visibleCount;

  /// Subtree aggregation — a node's stats are its own plus each child's (BR-5).
  DeckStats operator +(DeckStats other) => DeckStats(
        totalCards: totalCards + other.totalCards,
        hiddenCount: hiddenCount + other.hiddenCount,
        dueCount: dueCount + other.dueCount,
        masteredCount: masteredCount + other.masteredCount,
      );

  @override
  List<Object> get props => [totalCards, hiddenCount, dueCount, masteredCount];
}
