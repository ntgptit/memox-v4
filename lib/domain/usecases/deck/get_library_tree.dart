import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Loads the library tree (root nodes with recursive stats) for a pair.
class GetLibraryTreeUseCase {
  const GetLibraryTreeUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<List<DeckNode>>> call(int pairId) =>
      _repository.libraryTree(pairId);
}
