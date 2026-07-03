import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:memox_v4/data/datasources/local/tables.dart';

part 'app_database.g.dart';

/// The current on-disk schema version. Bumped by DT.2 alongside a migration.
const int _schemaVersion = 1;

/// The local Drift database (DT.1) — the single on-device source of truth. Holds
/// every table in `docs/database/schema-contract.md`; DAOs (DT.3) and repository
/// impls (DT.4) build on it. Foreign keys are enabled at every open so the
/// `onDelete: cascade` relations actually fire (D-024) — SQLite defaults them off.
///
/// Persistence-safety policy (`docs/database/persistence-safety.md`): multi-table
/// writes run in a `transaction`; queries take an injected "now" (no wall clock);
/// list reads carry an explicit `ORDER BY` — enforced by the DAOs (DT.3).
@DriftDatabase(
  tables: [
    LanguagePairs,
    Decks,
    Cards,
    CardMeanings,
    SrsStates,
    ReviewLogs,
    StudySessions,
    DailyActivity,
    Settings,
    BackupMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// An in-memory database — used by data-layer integration tests (DT.1+).
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => _schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // Forward-only (R3): never edit a shipped schema in place. Each version
        // bump adds a `if (from < N) { … }` block here and a new
        // `drift_schemas/drift_schema_vN.json` snapshot (regenerate the migration
        // test helper). v1 is the base — there are no upgrade steps yet.
        onUpgrade: (m, from, to) async {},
        beforeOpen: (details) async {
          // Cascades (D-024) only fire when foreign keys are enforced; SQLite
          // leaves them off by default, so enable them on every connection.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
