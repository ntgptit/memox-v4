import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Creates a deck at root or under a parent. The name is required (BR-1).
class CreateDeckUseCase {
  const CreateDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<Deck>> call({
    required int pairId,
    int? parentDeckId,
    required String name,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Future.value(
        const Err(ValidationFailure(message: 'deck name is required')),
      );
    }
    return _repository.create(
      pairId: pairId,
      parentDeckId: parentDeckId,
      name: trimmed,
    );
  }
}
