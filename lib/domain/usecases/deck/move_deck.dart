import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Moves a deck under a new parent (null = root). The repository rejects a move
/// that would create a cycle (BR-3).
class MoveDeckUseCase {
  const MoveDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<void>> call(int id, {int? newParentId}) =>
      _repository.move(id, newParentId: newParentId);
}
