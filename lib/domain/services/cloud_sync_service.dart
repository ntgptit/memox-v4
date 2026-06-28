import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/sync.dart';

/// Cloud backend for multi-device sync (Google Drive appDataFolder in v1).
/// Distinct from local file backup (`BackupRepository`). The snapshot payload is
/// the same JSON the backup layer serializes.
abstract interface class CloudSyncService {
  Future<Result<bool>> isSignedIn();

  Future<Result<void>> signIn();

  Future<Result<void>> signOut();

  /// Metadata of the remote snapshot, or `Ok(null)` when none exists yet.
  Future<Result<RemoteSnapshotMeta?>> remoteMeta();

  /// Uploads [snapshotJson], stamping it with [modifiedAt].
  Future<Result<void>> upload(String snapshotJson, DateTime modifiedAt);

  /// Downloads the remote snapshot JSON.
  Future<Result<String>> download();
}
