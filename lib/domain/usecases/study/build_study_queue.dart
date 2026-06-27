import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/repositories/srs_repository.dart';
import 'package:memox_v4/domain/types/box_interval.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/domain/usecases/srs/build_due_queue.dart';
import 'package:memox_v4/domain/usecases/srs/build_new_queue.dart';

/// Builds the card-id queue for a study entry over the node's subtree (D-009):
/// new cards (capped, D-018) for NewLearn, due cards for DueReview, and every
/// visible card for Review/Game/Player.
class BuildStudyQueueUseCase {
  const BuildStudyQueueUseCase(
    this._deckRepository,
    this._srsRepository,
    this._clock,
  );

  final DeckRepository _deckRepository;
  final SrsRepository _srsRepository;
  final Clock _clock;

  Future<Result<List<int>>> call(
    int nodeId,
    StudyEntry entry, {
    int newLimit = kDefaultNewCardsPerDay,
  }) async {
    final idsResult = await _deckRepository.subtreeCardIds(nodeId);
    final ids = idsResult.valueOrNull ?? const <int>[];
    return switch (entry) {
      StudyEntry.newLearn => BuildNewQueueUseCase(
        _srsRepository,
      ).call(ids, limit: newLimit),
      StudyEntry.dueReview => BuildDueQueueUseCase(
        _srsRepository,
        _clock,
      ).call(ids),
      StudyEntry.review ||
      StudyEntry.game ||
      StudyEntry.player => Future.value(Ok(ids)),
    };
  }
}
