import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/daily_activity_dao.dart';
import 'package:memox_v4/data/repositories/daily_activity_repository_impl.dart';
import 'package:memox_v4/domain/repositories/daily_activity_repository.dart';

/// Composition root for the daily-activity slice (used by study finalize, W4;
/// the Today dashboard reads it in W11).
final dailyActivityDaoProvider = Provider<DailyActivityDao>(
  (ref) => DailyActivityDao(ref.watch(databaseProvider)),
);

final dailyActivityRepositoryProvider = Provider<DailyActivityRepository>(
  (ref) => DailyActivityRepositoryImpl(ref.watch(dailyActivityDaoProvider)),
);
