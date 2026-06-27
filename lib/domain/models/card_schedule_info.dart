/// A card joined with its (optional) schedule, used to build study queues:
/// the card's hidden flag plus its box/due (null box = no `srs_state` row).
class CardScheduleInfo {
  const CardScheduleInfo({
    required this.cardId,
    required this.hidden,
    this.box,
    this.dueAt,
  });

  final int cardId;
  final bool hidden;
  final int? box;
  final int? dueAt;

  /// New = unscheduled: no schedule row, or box 0.
  bool get isNew => box == null || box == 0;
}
