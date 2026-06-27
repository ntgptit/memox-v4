import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/settings_dao.dart';
import 'package:memox_v4/data/repositories/backup_repository_impl.dart';
import 'package:memox_v4/data/repositories/settings_repository_impl.dart';
import 'package:memox_v4/domain/repositories/backup_repository.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';

/// Composition root for settings + local backup (W11 reads, W12 writes).
final settingsDaoProvider = Provider<SettingsDao>(
  (ref) => SettingsDao(ref.watch(databaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(settingsDaoProvider)),
);

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepositoryImpl(ref.watch(databaseProvider)),
);
