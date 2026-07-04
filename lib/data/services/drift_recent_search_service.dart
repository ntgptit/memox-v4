import 'dart:convert';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/domain/services/recent_search_service.dart';

/// The KV key holding the recent-search list (JSON-encoded `List<String>`).
const String _kRecentSearches = 'search.recents';

/// Drift-backed [RecentSearchService] over the `settings` key–value table (the
/// same store the settings service uses; a distinct key, no overlap). The list is
/// stored as a JSON array of strings.
class DriftRecentSearchService implements RecentSearchService {
  DriftRecentSearchService(this._db);

  final AppDatabase _db;

  @override
  Future<List<String>> load() async {
    final row = await (_db.select(_db.settings)
          ..where((s) => s.key.equals(_kRecentSearches)))
        .getSingleOrNull();
    if (row == null) return const [];
    final decoded = jsonDecode(row.value);
    if (decoded is! List) return const [];
    return decoded.whereType<String>().toList(growable: false);
  }

  @override
  Future<Result<void>> save(List<String> queries) => guardAsync(() async {
        await _db.into(_db.settings).insertOnConflictUpdate(
              SettingsCompanion.insert(
                key: _kRecentSearches,
                value: jsonEncode(queries),
              ),
            );
      });
}
