import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/search_dao.dart';
import 'package:memox_v4/data/repositories/search_repository_impl.dart';
import 'package:memox_v4/domain/repositories/search_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_providers.g.dart';

/// Composition root for the search slice.
@Riverpod(keepAlive: true)
SearchDao searchDao(Ref ref) => SearchDao(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) =>
    SearchRepositoryImpl(ref.watch(searchDaoProvider));
