import 'package:memox_v4/domain/models/search_result.dart';
import 'package:memox_v4/domain/repositories/search_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Searches cards by term + meaning (D-019), optionally scoped to a node. An
/// empty query returns no results.
class SearchCardsUseCase {
  const SearchCardsUseCase(this._repository);

  final SearchRepository _repository;

  Future<Result<List<SearchResult>>> call({
    required int pairId,
    required String query,
    List<int>? scopeCardIds,
  }) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return Future.value(const Ok(<SearchResult>[]));
    }
    return _repository.search(
      pairId: pairId,
      query: trimmed,
      scopeCardIds: scopeCardIds,
    );
  }
}
