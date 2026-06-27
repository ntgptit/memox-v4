import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/search_dao.dart';
import 'package:memox_v4/data/repositories/search_repository_impl.dart';
import 'package:memox_v4/domain/repositories/search_repository.dart';

/// Composition root for the search slice.
final searchDaoProvider = Provider<SearchDao>(
  (ref) => SearchDao(ref.watch(databaseProvider)),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepositoryImpl(ref.watch(searchDaoProvider)),
);
