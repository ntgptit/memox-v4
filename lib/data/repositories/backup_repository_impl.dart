import 'dart:convert';
import 'dart:io';

import 'package:memox_v4/core/error/failure.dart';
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
        return _guard('backup', () => File(path).writeAsString(content));
      case Err(:final failure):
        return Err<void>(failure);
    }
  }

  @override
  Future<Result<void>> restore(String path) async {
    try {
      return await deserialize(await File(path).readAsString());
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
    final raw = jsonDecode(json) as Map<String, dynamic>;
    await _db.transaction(() async {
      for (final table in _tables.reversed) {
        await _db.customStatement('DELETE FROM $table');
      }
      for (final table in _tables) {
        final rows = (raw[table] as List<dynamic>? ?? const <dynamic>[])
            .cast<Map<String, dynamic>>();
        for (final row in rows) {
          final cols = row.keys.toList();
          final placeholders = List<String>.filled(cols.length, '?').join(', ');
          await _db.customStatement(
            'INSERT INTO $table (${cols.join(', ')}) VALUES ($placeholders)',
            <Object?>[for (final c in cols) row[c]],
          );
        }
      }
    });
  });

  Future<Result<void>> _guard(String op, Future<void> Function() body) async {
    try {
      await body();
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: op, cause: e));
    }
  }
}
