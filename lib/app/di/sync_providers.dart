import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/settings_providers.dart';
import 'package:memox_v4/data/config/cloud_sync_config.dart';
import 'package:memox_v4/data/services/google_drive_sync_service.dart';
import 'package:memox_v4/domain/services/cloud_sync_service.dart';
import 'package:memox_v4/domain/usecases/sync/sync_now.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_providers.g.dart';

/// Composition root for Google Drive sync (W10).
///
/// [cloudSyncConfig] carries the OAuth client id; it ships empty (the HUMAN GAP)
/// so the service stays inert until configured — override this provider (e.g.
/// from `--dart-define`) to enable real sync.
@Riverpod(keepAlive: true)
CloudSyncConfig cloudSyncConfig(Ref ref) => const CloudSyncConfig();

@Riverpod(keepAlive: true)
CloudSyncService cloudSyncService(Ref ref) =>
    GoogleDriveSyncService(config: ref.watch(cloudSyncConfigProvider));

@Riverpod(keepAlive: true)
SyncNowUseCase syncNow(Ref ref) => SyncNowUseCase(
  ref.watch(backupRepositoryProvider),
  ref.watch(cloudSyncServiceProvider),
  ref.watch(settingsRepositoryProvider),
  ref.watch(clockProvider),
);
