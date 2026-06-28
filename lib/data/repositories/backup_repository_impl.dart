import 'dart:convert';

import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/data/datasources/local/connection/path_file.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/domain/repositories/backup_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// JSON snapshot of every table, written via raw SQL so it stays decoupled from
/// the typed companions. Restore replaces all rows in a single transaction
/// (parents first to satisfy foreign keys).
class BackupRepositoryImpl implements BackupRepository {
  const BackupRepositoryImpl(this._db);

  final AppDatabase _db;

  /// Parent → child order. `review_outcome` references card + language_pair, so
  /// it sits after both (insert) and is cleared first (delete, reversed).
  static const List<String> _tables = <String>[
    'language_pair',
    'deck',
    'card',
    'card_meaning',
    'srs_state',
    'daily_activity',
    'settings',
    'review_outcome',
  ];

  @override
  Future<Result<void>> backup(String path) async {
    final json = await serialize();
    switch (json) {
      case Ok(value: final content):
        return _guard('backup', () => writePathString(path, content));
      case Err(:final failure):
        return Err<void>(failure);
    }
  }

  @override
  Future<Result<void>> restore(String path) async {
    try {
      return await deserialize(await readPathString(path));
    } catch (e) {
      return Err(PersistenceFailure(message: 'restore', cause: e));
    }
  }

  @override
  Future<Result<String>> serialize() async {
    try {
      final data = <String, List<Map<String, dynamic>>>{};
      for (final table in _tables) {
        final rows = await _db.customSelect('SELECT * FROM $table').get();
        data[table] = <Map<String, dynamic>>[for (final r in rows) r.data];
      }
      return Ok<String>(jsonEncode(data));
    } catch (e) {
      return Err(PersistenceFailure(message: 'serialize', cause: e));
    }
  }

  @override
  Future<Result<void>> deserialize(String json) => _guard('restore', () async {
    // Guard against wiping the DB from an empty/corrupt snapshot: the payload
    // must be a JSON object carrying the root table, even when it has no rows.
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic> ||
        !decoded.containsKey('language_pair')) {
      throw const FormatException('not a valid MemoX backup snapshot');
    }
    final raw = decoded;
    await _db.transaction(() async {
      for (final table in _tables.reversed) {
        await _db.customStatement('DELETE FROM $table');
      }
      for (final table in _tables) {
        final rows = (raw[table] as List<dynamic>? ?? const <dynamic>[])
            .cast<Map<String, dynamic>>();
        if (rows.isEmpty) continue;
        final cols = rows.first.keys.toList();
        // Column names are interpolated into SQL, so reject anything that isn't a
        // plain identifier (defends the restore/sync path against a crafted key).
        if (!cols.every(_isIdentifier)) {
          throw const FormatException('snapshot has an invalid column name');
        }
        final colSql = cols.join(', ');
        final rowPlaceholder =
            '(${List<String>.filled(cols.length, '?').join(', ')})';
        // Batch into multi-row INSERTs so a large restore isn't O(rows) round-trips.
        for (var i = 0; i < rows.length; i += _restoreChunk) {
          final chunk = rows.sublist(
            i,
            i + _restoreChunk < rows.length ? i + _restoreChunk : rows.length,
          );
          final values = List<String>.filled(
            chunk.length,
            rowPlaceholder,
          ).join(', ');
          await _db.customStatement(
            'INSERT INTO $table ($colSql) VALUES $values',
            <Object?>[
              for (final row in chunk)
                for (final c in cols) row[c],
            ],
          );
        }
      }
    });
  });

  static const int _restoreChunk = 200;

  static bool _isIdentifier(String name) =>
      RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(name);

  Future<Result<void>> _guard(String op, Future<void> Function() body) async {
    try {
      await body();
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: op, cause: e));
    }
  }
}
