/// Review interval (days) for each Leitner box: 1·3·7·14·30·60·120. Boxes 0
/// (new) and 8 (mastered) are unscheduled (`docs/contracts/types-catalog.md`,
/// `docs/business/srs/srs-review.md` BR-5).
abstract final class BoxInterval {
  const BoxInterval._();

  static const Map<int, int> _daysByBox = <int, int>{
    1: 1,
    2: 3,
    3: 7,
    4: 14,
    5: 30,
    6: 60,
    7: 120,
  };

  /// Days until the next review for [box], or null when the box isn't scheduled.
  static int? daysForBox(int box) => _daysByBox[box];
}

/// Default NewLearn daily cap (`settings.new_cards_per_day`, D-018).
const int kDefaultNewCardsPerDay = 20;
