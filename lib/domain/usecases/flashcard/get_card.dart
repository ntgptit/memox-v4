import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Loads a single card with its meanings (for the editor in edit mode).
class GetCardUseCase {
  const GetCardUseCase(this._repository);

  final CardRepository _repository;

  Future<Result<Card?>> call(int id) => _repository.getById(id);
}
