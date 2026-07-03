import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/data/providers/database_provider.dart';
import 'package:memox_v4/data/seed/database_seeder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'seed_providers.g.dart';

/// The database seeder (DT.6) over the app database + clock. App startup calls
/// [DatabaseSeeder.ensureFirstRun] before the first repository use so the deck FK
/// always has its active language pair; a dev build may also call
/// [DatabaseSeeder.seedSampleData]. Tests construct the seeder directly.
@riverpod
DatabaseSeeder databaseSeeder(Ref ref) => DatabaseSeeder(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    );
