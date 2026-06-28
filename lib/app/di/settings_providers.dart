import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/settings_dao.dart';
import 'package:memox_v4/data/repositories/backup_repository_impl.dart';
import 'package:memox_v4/data/repositories/settings_repository_impl.dart';
import 'package:memox_v4/domain/repositories/backup_repository.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// Composition root for settings + local backup (W11 reads, W12 writes).
@Riverpod(keepAlive: true)
SettingsDao settingsDao(Ref ref) => SettingsDao(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepositoryImpl(ref.watch(settingsDaoProvider));

@Riverpod(keepAlive: true)
BackupRepository backupRepository(Ref ref) =>
    BackupRepositoryImpl(ref.watch(databaseProvider));
