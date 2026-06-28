import 'package:memox_v4/domain/types/result.dart';

/// Local backup: a restorable file snapshot of all data, distinct from cloud
/// sync (BR-3, `docs/database/storage-boundaries.md`).
abstract interface class BackupRepository {
  /// Writes a snapshot of every table to [path].
  Future<Result<void>> backup(String path);

  /// Replaces all data with the snapshot at [path].
  Future<Result<void>> restore(String path);

  /// The same snapshot as [backup], as a JSON string (for cloud sync upload).
  Future<Result<String>> serialize();

  /// Replaces all data with the snapshot held in [json] (cloud sync download).
  Future<Result<void>> deserialize(String json);
}
