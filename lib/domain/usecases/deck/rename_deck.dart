import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Renames a deck. The new name is required (BR-1).
class RenameDeckUseCase {
  const RenameDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<Deck>> call(int id, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Future.value(
        const Err(ValidationFailure(message: 'deck name is required')),
      );
    }
    return _repository.rename(id, trimmed);
  }
}
