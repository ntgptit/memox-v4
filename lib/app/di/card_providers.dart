import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/card_dao.dart';
import 'package:memox_v4/data/repositories/card_repository_impl.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_providers.g.dart';

/// Composition root for the flashcard slice. Presentation reads the repository
/// provider (a domain type); it never imports `data` directly.
@Riverpod(keepAlive: true)
CardDao cardDao(Ref ref) => CardDao(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
CardRepository cardRepository(Ref ref) =>
    CardRepositoryImpl(ref.watch(cardDaoProvider), ref.watch(clockProvider));
