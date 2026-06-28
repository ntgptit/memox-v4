import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';

part 'app_database.g.dart';

/// The local SQLite database (Drift) — the single owner of persisted entity
/// data per `docs/database/storage-boundaries.md`. Schema and migrations follow
/// `docs/database/{schema,migration}-contract.md`.
///
/// The schema is SQL: defined in `tables.drift` and embedded here via
/// `include`. DAOs and feature queries are added as their own `.drift` files
/// per feature (W2+); this class only wires the schema, version, and the
/// create/upgrade strategy.
@DriftDatabase(include: {'tables.drift'})
class AppDatabase extends _$AppDatabase {
  /// Production database backed by the on-disk file.
  AppDatabase() : super(openLocalDatabase());

  /// Inject a connection (e.g. an in-memory executor for tests).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // 1 → 2: add review_outcome (accuracy stats, W9).
      if (from < 2) {
        await m.createTable(reviewOutcome);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_review_outcome_pair_ts '
          'ON review_outcome (pair_id, ts)',
        );
      }
    },
    beforeOpen: (details) async {
      // Cascade deletes (ownership tree) require FK enforcement, off by default.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
