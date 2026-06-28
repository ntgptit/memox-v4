import 'package:memox_v4/core/constants/settings_keys.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/domain/repositories/backup_repository.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';
import 'package:memox_v4/domain/services/cloud_sync_service.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/sync.dart';

/// Syncs the local snapshot with the cloud using **snapshot-level
/// last-writer-wins** (D-027, `docs/business/account-sync/account-sync.md`):
/// if the remote was written after our last sync, pull + restore it; otherwise
/// push the local snapshot. A never-synced device adopts any existing remote.
///
/// v1 limitation (documented): MemoX has no per-record update clock, so the LWW
/// is whole-snapshot, not per-record. Per-record merge + delete tombstones are
/// deferred (account-sync §10).
class SyncNowUseCase {
  const SyncNowUseCase(this._backup, this._cloud, this._settings, this._clock);

  final BackupRepository _backup;
  final CloudSyncService _cloud;
  final SettingsRepository _settings;
  final Clock _clock;

  Future<Result<SyncOutcome>> call() async {
    final signedIn = await _cloud.isSignedIn();
    switch (signedIn) {
      case Err(:final failure):
        return Err<SyncOutcome>(failure);
      case Ok(value: false):
        return const Ok<SyncOutcome>(SyncOutcome.signInRequired);
      case Ok(value: true):
        break;
    }

    final metaResult = await _cloud.remoteMeta();
    if (metaResult case Err(:final failure)) return Err<SyncOutcome>(failure);
    final meta = metaResult.valueOrNull; // null = no remote snapshot yet

    final lastSync =
        (await _settings.readInt(SettingsKeys.cloudLastSyncAt)).valueOrNull ??
        0;

    if (meta != null && meta.modifiedAt.millisecondsSinceEpoch > lastSync) {
      return _pull(meta);
    }
    return _push();
  }

  Future<Result<SyncOutcome>> _push() async {
    final json = await _backup.serialize();
    if (json case Err(:final failure)) return Err<SyncOutcome>(failure);
    final now = _clock.now();
    final uploaded = await _cloud.upload(json.valueOrNull!, now);
    if (uploaded case Err(:final failure)) return Err<SyncOutcome>(failure);
    // Stamp lastSync from the server's post-upload modifiedTime when available,
    // so the next sync compares like-for-like (the device clock may lag the
    // server, which would otherwise make our own upload look "newer" and pull).
    final stamp = (await _cloud.remoteMeta()).valueOrNull?.modifiedAt ?? now;
    await _settings.write(
      SettingsKeys.cloudLastSyncAt,
      '${stamp.millisecondsSinceEpoch}',
    );
    return const Ok<SyncOutcome>(SyncOutcome.pushed);
  }

  Future<Result<SyncOutcome>> _pull(RemoteSnapshotMeta meta) async {
    final downloaded = await _cloud.download();
    if (downloaded case Err(:final failure)) return Err<SyncOutcome>(failure);
    final restored = await _backup.deserialize(downloaded.valueOrNull!);
    if (restored case Err(:final failure)) return Err<SyncOutcome>(failure);
    await _settings.write(
      SettingsKeys.cloudLastSyncAt,
      '${meta.modifiedAt.millisecondsSinceEpoch}',
    );
    return const Ok<SyncOutcome>(SyncOutcome.pulled);
  }
}
