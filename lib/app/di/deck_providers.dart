import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/deck_dao.dart';
import 'package:memox_v4/data/repositories/deck_repository_impl.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deck_providers.g.dart';

/// Composition root for the deck slice. Presentation reads the repository
/// provider (a domain type); it never imports `data` directly.
@Riverpod(keepAlive: true)
DeckDao deckDao(Ref ref) => DeckDao(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
DeckRepository deckRepository(Ref ref) =>
    DeckRepositoryImpl(ref.watch(deckDaoProvider), ref.watch(clockProvider));
