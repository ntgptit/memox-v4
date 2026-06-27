import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/deck_dao.dart';
import 'package:memox_v4/data/repositories/deck_repository_impl.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';

/// Composition root for the deck slice. Presentation reads the repository
/// provider (a domain type); it never imports `data` directly.
final deckDaoProvider = Provider<DeckDao>(
  (ref) => DeckDao(ref.watch(databaseProvider)),
);

final deckRepositoryProvider = Provider<DeckRepository>(
  (ref) =>
      DeckRepositoryImpl(ref.watch(deckDaoProvider), ref.watch(clockProvider)),
);
