import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';

import 'generated/schema.dart';

/// The versions this app has ever shipped. A schema bump (DT.2 forward-only)
/// appends the new version here and a matching `drift_schema_vN.json` snapshot.
const List<int> _shippedVersions = [1];

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('the current schema version is the latest shipped', () {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    expect(db.schemaVersion, _shippedVersions.last);
  });

  test('the runtime schema matches its versioned snapshot', () async {
    // Build the DB at each shipped version and confirm the migrated schema
    // exactly matches the checked-in snapshot (no drift between code + schema).
    for (final version in _shippedVersions) {
      final connection = await verifier.startAt(version);
      final db = AppDatabase(connection);
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, version);
    }
  });

  test('data survives a close + reopen round-trip with foreign keys on', () async {
    final dir = Directory.systemTemp.createTempSync('memox_dt2');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/app.sqlite');

    // First open: create the schema and write a row.
    final first = AppDatabase(NativeDatabase(file));
    await first.into(first.languagePairs).insert(
          LanguagePairsCompanion.insert(
            id: 'lp',
            learningLanguage: 'ko',
            nativeLanguage: 'en',
            createdAt: 0,
          ),
        );
    await first.close();

    // Reopen the same file: the row is still there and FKs are re-enabled.
    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    final rows = await second.select(second.languagePairs).get();
    expect(rows.single.learningLanguage, 'ko');
    final fk = await second.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.data.values.first, 1);
    expect(second.schemaVersion, 1);
  });
}
