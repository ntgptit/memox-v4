import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/repositories/language_pair_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Lists every language pair, ordered for display.
class ListLanguagePairsUseCase {
  const ListLanguagePairsUseCase(this._repository);

  final LanguagePairRepository _repository;

  Future<Result<List<LanguagePair>>> call() => _repository.list();
}
