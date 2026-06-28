import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/daily_activity_dao.dart';
import 'package:memox_v4/data/repositories/daily_activity_repository_impl.dart';
import 'package:memox_v4/domain/repositories/daily_activity_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_activity_providers.g.dart';

/// Composition root for the daily-activity slice (used by study finalize, W4;
/// the Today dashboard reads it in W11).
@Riverpod(keepAlive: true)
DailyActivityDao dailyActivityDao(Ref ref) =>
    DailyActivityDao(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
DailyActivityRepository dailyActivityRepository(Ref ref) =>
    DailyActivityRepositoryImpl(ref.watch(dailyActivityDaoProvider));
