import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Deletes a deck; the repository cascades the whole subtree (D-024).
class DeleteDeckUseCase {
  const DeleteDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<void>> call(int id) => _repository.delete(id);
}
