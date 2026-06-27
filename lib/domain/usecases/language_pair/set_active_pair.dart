import 'package:memox_v4/domain/repositories/language_pair_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Persists which pair is the active learning context.
class SetActivePairUseCase {
  const SetActivePairUseCase(this._repository);

  final LanguagePairRepository _repository;

  Future<Result<void>> call(int pairId) => _repository.setActivePairId(pairId);
}
