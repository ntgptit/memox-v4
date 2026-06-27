import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/language_pair_dao.dart';
import 'package:memox_v4/data/repositories/language_pair_repository_impl.dart';
import 'package:memox_v4/domain/repositories/language_pair_repository.dart';

/// Composition root for the language-pair slice. Wires the Drift DAO and the
/// repository implementation behind the domain interface. Presentation reads the
/// repository provider (a domain type) and never imports `data` directly.
final languagePairDaoProvider = Provider<LanguagePairDao>(
  (ref) => LanguagePairDao(ref.watch(databaseProvider)),
);

final languagePairRepositoryProvider = Provider<LanguagePairRepository>(
  (ref) => LanguagePairRepositoryImpl(ref.watch(languagePairDaoProvider)),
);
