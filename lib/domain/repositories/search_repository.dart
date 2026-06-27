import 'package:memox_v4/domain/models/search_result.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Searches cards by term + meaning within a pair (`docs/business/search`).
/// Results include hidden cards (D-028); the status filter is applied above this
/// layer. v1 uses a case-insensitive LIKE over `card`/`card_meaning` — an
/// FTS/index is deferred until the performance contract requires it.
abstract interface class SearchRepository {
  /// Cards in [pairId] whose term OR any meaning matches [query] (D-019).
  /// [scopeCardIds] narrows the search to a node's subtree when provided.
  Future<Result<List<SearchResult>>> search({
    required int pairId,
    required String query,
    List<int>? scopeCardIds,
  });
}
