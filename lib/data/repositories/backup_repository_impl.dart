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

  /// Parent → child order.
  static const List<String> _tables = <String>[
    'language_pair',
    'deck',
    'card',
    'card_meaning',
    'srs_state',
    'daily_activity',
    'settings',
  ];

  @override
  Future<Result<void>> backup(String path) async {
    try {
      final data = <String, List<Map<String, dynamic>>>{};
      for (final table in _tables) {
        final rows = await _db.customSelect('SELECT * FROM $table').get();
        data[table] = <Map<String, dynamic>>[for (final r in rows) r.data];
      }
      await File(path).writeAsString(jsonEncode(data));
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'backup', cause: e));
    }
  }

  @override
  Future<Result<void>> restore(String path) async {
    try {
      final raw =
          jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;
      await _db.transaction(() async {
        for (final table in _tables.reversed) {
          await _db.customStatement('DELETE FROM $table');
        }
        for (final table in _tables) {
          final rows = (raw[table] as List<dynamic>? ?? const <dynamic>[])
              .cast<Map<String, dynamic>>();
          for (final row in rows) {
            final cols = row.keys.toList();
            final placeholders = List<String>.filled(
              cols.length,
              '?',
            ).join(', ');
            await _db.customStatement(
              'INSERT INTO $table (${cols.join(', ')}) VALUES ($placeholders)',
              <Object?>[for (final c in cols) row[c]],
            );
          }
        }
      });
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'restore', cause: e));
    }
  }
}
