import 'package:memox_v4/core/error/result.dart';

/// Persists the learner's recent search queries across app restarts (search
/// screen). A small most-recent-first list; the presentation layer owns the cap +
/// de-duplication, this contract only loads + stores the raw list.
abstract interface class RecentSearchService {
  /// The persisted queries (most-recent first), or empty when none are stored.
  Future<List<String>> load();

  /// Overwrite the stored queries with [queries].
  Future<Result<void>> save(List<String> queries);
}
