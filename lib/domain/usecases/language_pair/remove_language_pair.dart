import 'package:memox_v4/domain/repositories/language_pair_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Removes a language pair and (via cascade) all content that belongs to it.
class RemoveLanguagePairUseCase {
  const RemoveLanguagePairUseCase(this._repository);

  final LanguagePairRepository _repository;

  Future<Result<void>> call(int pairId) => _repository.remove(pairId);
}
