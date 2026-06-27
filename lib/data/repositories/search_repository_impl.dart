import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/data/datasources/local/daos/search_dao.dart';
import 'package:memox_v4/domain/models/search_result.dart';
import 'package:memox_v4/domain/repositories/search_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Drift-backed [SearchRepository].
class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl(this._dao);

  final SearchDao _dao;

  @override
  Future<Result<List<SearchResult>>> search({
    required int pairId,
    required String query,
    List<int>? scopeCardIds,
  }) async {
    try {
      final rows = await _dao.search(
        pairId: pairId,
        query: query,
        scopeCardIds: scopeCardIds,
      );
      return Ok(
        rows
            .map(
              (r) => SearchResult(
                cardId: r.cardId,
                deckId: r.deckId,
                term: r.term,
                meaning: r.meaning,
                deckName: r.deckName,
                hidden: r.hidden,
                box: r.box,
                dueAt: r.dueAt,
              ),
            )
            .toList(growable: false),
      );
    } catch (e) {
      return Err(PersistenceFailure(message: 'search cards', cause: e));
    }
  }
}
