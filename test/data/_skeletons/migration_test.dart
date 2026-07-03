// Persistence-safety skeleton (DT.0.1 · Policy 5 — migration safety).
//
// Locks the contract DT.2 (migrations & versioning) must satisfy: a schema bump
// preserves existing data and re-enables foreign keys; an incompatible backup
// restore is rejected, not applied blindly. Skipped until migrations exist; see
// docs/database/persistence-safety.md.
@Skip('DT.2 fills this in once schema versioning + migrations exist.')
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('migration safety (Policy 5)', () {
    test('migrating a populated vN db to the current version keeps every row', () {
      // GIVEN a vN database with rows, WHEN opened at the current schemaVersion,
      // THEN all rows survive (no silent data loss).
    });

    test('foreign keys are re-enabled after migration', () {
      // GIVEN a post-migration connection, THEN PRAGMA foreign_keys reads 1.
    });

    test('a restore across an incompatible schema_version is rejected', () {
      // GIVEN a backup whose backup_metadata.schema_version is incompatible,
      // THEN restore returns a Failure rather than corrupting the DB. D-027.
    });
  });
}
