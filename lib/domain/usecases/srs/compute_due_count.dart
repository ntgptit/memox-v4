import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/domain/repositories/srs_repository.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/srs/build_due_queue.dart';

/// The number of due cards among a candidate set (the red badge count). Shares
/// the due rule with [BuildDueQueueUseCase] so they never diverge.
class ComputeDueCountUseCase {
  const ComputeDueCountUseCase(this._repository, this._clock);

  final SrsRepository _repository;
  final Clock _clock;

  Future<Result<int>> call(List<int> cardIds) async {
    final due = await BuildDueQueueUseCase(_repository, _clock).call(cardIds);
    return due.map((ids) => ids.length);
  }
}
