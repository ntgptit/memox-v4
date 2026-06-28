import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/language_pair_dao.dart';
import 'package:memox_v4/data/repositories/language_pair_repository_impl.dart';
import 'package:memox_v4/domain/repositories/language_pair_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'language_pair_providers.g.dart';

/// Composition root for the language-pair slice. Wires the Drift DAO and the
/// repository implementation behind the domain interface. Presentation reads the
/// repository provider (a domain type) and never imports `data` directly.
@Riverpod(keepAlive: true)
LanguagePairDao languagePairDao(Ref ref) =>
    LanguagePairDao(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
LanguagePairRepository languagePairRepository(Ref ref) =>
    LanguagePairRepositoryImpl(ref.watch(languagePairDaoProvider));
