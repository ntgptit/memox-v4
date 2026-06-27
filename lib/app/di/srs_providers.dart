import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/srs_dao.dart';
import 'package:memox_v4/data/repositories/srs_repository_impl.dart';
import 'package:memox_v4/domain/repositories/srs_repository.dart';

/// Composition root for the SRS slice (the W4 study flow consumes these). The
/// study use cases are constructed by their callers with the repository + clock.
final srsDaoProvider = Provider<SrsDao>(
  (ref) => SrsDao(ref.watch(databaseProvider)),
);

final srsRepositoryProvider = Provider<SrsRepository>(
  (ref) => SrsRepositoryImpl(ref.watch(srsDaoProvider)),
);
