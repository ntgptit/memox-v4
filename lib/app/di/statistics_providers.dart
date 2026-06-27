import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/stats_dao.dart';
import 'package:memox_v4/data/repositories/statistics_repository_impl.dart';
import 'package:memox_v4/domain/repositories/statistics_repository.dart';

/// Composition root for statistics reads (W9).
final statsDaoProvider = Provider<StatsDao>(
  (ref) => StatsDao(ref.watch(databaseProvider)),
);

final statisticsRepositoryProvider = Provider<StatisticsRepository>(
  (ref) => StatisticsRepositoryImpl(ref.watch(statsDaoProvider)),
);
