import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/domain/repositories/srs_repository.dart';
import 'package:memox_v4/domain/types/leitner_box.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Builds the due-review queue from a set of candidate cards (a node's subtree):
/// scheduled cards (box 1..7) whose due date has passed, excluding hidden ones
/// (D-006). Order follows the input.
class BuildDueQueueUseCase {
  const BuildDueQueueUseCase(this._repository, this._clock);

  final SrsRepository _repository;
  final Clock _clock;

  Future<Result<List<int>>> call(List<int> cardIds) async {
    final infoResult = await _repository.scheduleInfo(cardIds);
    final now = _clock.now().millisecondsSinceEpoch;
    return infoResult.map(
      (infos) => <int>[
        for (final info in infos)
          if (!info.hidden &&
              info.box != null &&
              info.box! >= LeitnerBox.scheduledFloor &&
              info.box! < LeitnerBox.masteredBox &&
              info.dueAt != null &&
              info.dueAt! <= now)
            info.cardId,
      ],
    );
  }
}
