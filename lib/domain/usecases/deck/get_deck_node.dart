import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Loads one deck's node (deck + recursive stats + child nodes) for deck detail.
class GetDeckNodeUseCase {
  const GetDeckNodeUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<DeckNode?>> call(int deckId) => _repository.node(deckId);
}
