import 'package:memox_v4/domain/repositories/srs_repository.dart';
import 'package:memox_v4/domain/types/box_interval.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Builds the NewLearn queue from a set of candidate cards: unscheduled cards
/// (no schedule row / box 0), excluding hidden ones, capped at [limit] per day
/// (D-018, default [kDefaultNewCardsPerDay]).
class BuildNewQueueUseCase {
  const BuildNewQueueUseCase(this._repository);

  final SrsRepository _repository;

  Future<Result<List<int>>> call(
    List<int> cardIds, {
    int limit = kDefaultNewCardsPerDay,
  }) async {
    final infoResult = await _repository.scheduleInfo(cardIds);
    return infoResult.map((infos) {
      final newCards = <int>[
        for (final info in infos)
          if (!info.hidden && info.isNew) info.cardId,
      ];
      return newCards.length <= limit ? newCards : newCards.sublist(0, limit);
    });
  }
}
