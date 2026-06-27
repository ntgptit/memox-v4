/// Lifecycle status of a card, **derived** from `srs_state.box` + the `hidden`
/// flag — never stored (`docs/contracts/types-catalog.md`). Box transitions
/// themselves are owned by SRS (W3); this only classifies a current state.
enum CardStatus { newCard, learning, due, mastered, hidden }

/// Classifies a card. `box` is the Leitner box (null/0 = unscheduled new, 8 =
/// mastered); `isDue` is supplied by the caller (it needs the clock, which lives
/// outside this pure function).
CardStatus deriveCardStatus({
  required bool hidden,
  required int? box,
  required bool isDue,
}) {
  if (hidden) return CardStatus.hidden;
  if (box == null || box == 0) return CardStatus.newCard;
  if (box >= 8) return CardStatus.mastered;
  if (isDue) return CardStatus.due;
  return CardStatus.learning;
}
