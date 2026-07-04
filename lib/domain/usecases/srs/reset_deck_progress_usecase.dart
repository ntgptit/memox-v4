import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';

/// Reset **every card in a deck** back to New — box 0, unscheduled — so the whole
/// deck re-enters the Leitner learn flow (deck-management "Reset progress", kit
/// `deck-detail/reset-confirm`).
///
/// Policy: for each of the deck's cards, box → [BoxLevel.newCard], `dueAt` → null,
/// written through the frozen [ReviewRepository.saveSchedule] (the same write a
/// card gets when it first enters the schedule), so no contract change is needed.
/// The first failing write short-circuits and surfaces its [Failure] — a partial
/// reset is reported, never swallowed.
class ResetDeckProgressUseCase {
  const ResetDeckProgressUseCase(this._cards, this._reviews);

  final CardRepository _cards;
  final ReviewRepository _reviews;

  Future<Result<void>> call(DeckId deckId) async {
    final cards = await _cards.watchByDeck(deckId).first;
    for (final card in cards) {
      final result = await _reviews.saveSchedule(
        cardId: card.id,
        box: BoxLevel.newCard,
        dueAt: null,
      );
      if (result case Err()) return result;
    }
    return const Ok<void>(null);
  }
}
