import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';
import 'package:memox_v4/domain/usecases/srs/srs_scheduler.dart';

/// Builds the two study queues for a node (a parent node covers its subtree
/// recursively, BR-6 — enforced by the repository query):
/// - [due] — cards due for review at [asOf] (hidden excluded, BR-8);
/// - [newCards] — new cards to introduce, capped at the remaining per-day
///   allowance (D-018) so a session never over-introduces.
class BuildStudyQueue {
  const BuildStudyQueue({
    required ReviewRepository reviews,
    required SrsScheduler scheduler,
  })  : _reviews = reviews,
        _scheduler = scheduler;

  final ReviewRepository _reviews;
  final SrsScheduler _scheduler;

  Future<Result<List<Card>>> due({
    DeckId? within,
    required DateTime asOf,
    int? limit,
  }) {
    return _reviews.dueQueue(within: within, asOf: asOf, limit: limit);
  }

  Future<Result<List<Card>>> newCards({
    DeckId? within,
    required int perDayCap,
    required int introducedToday,
  }) {
    final allowed = _scheduler.remainingNewCardsToday(
      perDayCap: perDayCap,
      introducedToday: introducedToday,
    );
    return _reviews.newQueue(within: within, limit: allowed);
  }
}
