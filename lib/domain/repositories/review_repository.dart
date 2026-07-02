import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_log.dart';

/// The SRS scheduling + review-history contract. **Frozen** once screens code
/// against it (R4).
///
/// Read/write policy: queue reads are one-shot snapshots taken `asOf` a given
/// time (the caller supplies "now" via the domain [Clock] for determinism);
/// [watchDueCount] is the live badge source. The box math itself lives in the SRS
/// scheduler (DM.4) — this contract only reads the current box and persists the
/// scheduler's result, so it stays free of scheduling policy.
abstract interface class ReviewRepository {
  /// Live count of due, non-hidden cards for a node's subtree (badge). Hidden
  /// cards never count (BR-8).
  Stream<int> watchDueCount({DeckId? within});

  /// Cards due for review at [asOf], excluding hidden cards (BR-8), optionally
  /// capped by [limit]. Scoped to a subtree when [within] is set.
  Future<Result<List<Card>>> dueQueue({
    DeckId? within,
    required DateTime asOf,
    int? limit,
  });

  /// New (unscheduled) cards to introduce, capped by [limit] — the caller passes
  /// the per-day cap (default 20, D-018).
  Future<Result<List<Card>>> newQueue({DeckId? within, required int limit});

  /// The card's current Leitner box (new/box 0 when never scheduled).
  Future<Result<BoxLevel>> currentBox(CardId cardId);

  /// Persist a card's SRS position — used both when a new card enters box 1
  /// (D-002) and after a review moves it. [dueAt] is null for a mastered card
  /// (box 8) that leaves the schedule (BR-5).
  Future<Result<void>> saveSchedule({
    required CardId cardId,
    required BoxLevel box,
    DateTime? dueAt,
  });

  /// Record a graded review outcome for history/accuracy stats.
  Future<Result<void>> logReview(ReviewLog log);
}
