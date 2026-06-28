import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/srs_dao.dart';
import 'package:memox_v4/data/repositories/srs_repository_impl.dart';
import 'package:memox_v4/domain/repositories/srs_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'srs_providers.g.dart';

/// Composition root for the SRS slice (the W4 study flow consumes these). The
/// study use cases are constructed by their callers with the repository + clock.
@Riverpod(keepAlive: true)
SrsDao srsDao(Ref ref) => SrsDao(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
SrsRepository srsRepository(Ref ref) =>
    SrsRepositoryImpl(ref.watch(srsDaoProvider));
