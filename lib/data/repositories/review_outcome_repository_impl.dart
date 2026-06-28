import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/data/datasources/local/daos/review_outcome_dao.dart';
import 'package:memox_v4/domain/repositories/review_outcome_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Drift-backed [ReviewOutcomeRepository].
class ReviewOutcomeRepositoryImpl implements ReviewOutcomeRepository {
  const ReviewOutcomeRepositoryImpl(this._dao);

  final ReviewOutcomeDao _dao;

  @override
  Future<Result<void>> record({
    required int cardId,
    required int pairId,
    required int ts,
    required bool correct,
    required String mode,
  }) async {
    try {
      await _dao.record(
        cardId: cardId,
        pairId: pairId,
        ts: ts,
        correct: correct,
        mode: mode,
      );
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'record outcome', cause: e));
    }
  }
}
