/// Aggregate counts for a deck, computed **recursively** over its subtree
/// (BR-5). `words` excludes hidden cards (BR-6 / D-006); `progress` is the
/// mastered ratio over visible cards.
class DeckStats {
  const DeckStats({
    this.words = 0,
    this.hidden = 0,
    this.due = 0,
    this.mastered = 0,
    this.lastStudiedAt,
  });

  /// Visible (non-hidden) card count over the subtree.
  final int words;

  /// Hidden card count over the subtree (shown separately).
  final int hidden;

  /// Due (scheduled, box 1..7, due_at ≤ now) card count over the subtree.
  final int due;

  /// Mastered (box 8) card count over the subtree.
  final int mastered;

  /// Most recent study instant over the subtree (epoch ms), or null.
  final int? lastStudiedAt;

  /// Mastered ratio over visible cards, 0 when empty.
  double get progress => words == 0 ? 0 : mastered / words;
}
