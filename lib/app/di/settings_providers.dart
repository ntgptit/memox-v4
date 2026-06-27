import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/settings_dao.dart';
import 'package:memox_v4/data/repositories/settings_repository_impl.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';

/// Composition root for settings reads (W11 daily goal; W12 extends with writes).
final settingsDaoProvider = Provider<SettingsDao>(
  (ref) => SettingsDao(ref.watch(databaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(settingsDaoProvider)),
);
