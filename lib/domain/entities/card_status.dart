/// A card's lifecycle state (`CardStatus` in the glossary):
/// mới → đang học → đến hạn → đã thuộc, plus the orthogonal "ẩn" (hidden) state.
///
/// This is the derived, user-facing status; the underlying scheduling position is
/// the card's [BoxLevel]. Hidden cards never enter the review queue nor count
/// toward due totals (BR-8).
enum CardStatus {
  /// Mới — created but not yet scheduled (box 0).
  newCard,

  /// Đang học — currently going through the 5-stage "Học" flow.
  learning,

  /// Đến hạn — scheduled and due for review now.
  due,

  /// Đã thuộc — reached the top box (mastered); scheduling stops.
  mastered,

  /// Ẩn — set aside by the learner; excluded from queues and due counts.
  hidden;

  bool get isHidden => this == CardStatus.hidden;
}
