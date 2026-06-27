import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Deletes a card; cascade removes its meanings and srs state (UC-4).
class DeleteCardUseCase {
  const DeleteCardUseCase(this._repository);

  final CardRepository _repository;

  Future<Result<void>> call(int id) => _repository.delete(id);
}
