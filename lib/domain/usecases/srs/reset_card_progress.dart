import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';

/// Reset a card's SRS progress — return it to **New** (box 0, unscheduled) so it
/// re-enters the 5-stage learn from scratch (deck-management "Reset progress").
///
/// Policy: box → [BoxLevel.newCard], `dueAt` → null. Implemented over the frozen
/// [ReviewRepository.saveSchedule] (the same write used when a card first enters
/// the schedule), so no contract change is needed.
class ResetCardProgress {
  const ResetCardProgress(this._reviews);

  final ReviewRepository _reviews;

  Future<Result<void>> call(CardId cardId) => _reviews.saveSchedule(
        cardId: cardId,
        box: BoxLevel.newCard,
        dueAt: null,
      );
}
