import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/stats_dao.dart';
import 'package:memox_v4/data/repositories/statistics_repository_impl.dart';
import 'package:memox_v4/domain/repositories/statistics_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_providers.g.dart';

/// Composition root for statistics reads (W9).
@Riverpod(keepAlive: true)
StatsDao statsDao(Ref ref) => StatsDao(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
StatisticsRepository statisticsRepository(Ref ref) =>
    StatisticsRepositoryImpl(ref.watch(statsDaoProvider));
