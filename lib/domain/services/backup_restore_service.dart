import 'package:memox_v4/core/error/result.dart';

/// Local file backup + restore (settings BR-3). This is a full local snapshot,
/// entirely distinct from account cloud sync (which is deferred in v1, D-027).
/// A contract only — the file/serialization adapter lands in DT.7.
abstract interface class BackupRestoreService {
  /// Write a full local backup; returns a reference to the created file.
  Future<Result<String>> createBackup();

  /// Restore from a backup file previously produced by [createBackup].
  Future<Result<void>> restoreBackup(String source);
}
