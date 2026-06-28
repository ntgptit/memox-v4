import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web: sqlite3 compiled to WebAssembly, persisted via OPFS/IndexedDB. Requires
/// `web/sqlite3.wasm` + `web/drift_worker.dart.js` (see `web/README-drift.md`).
QueryExecutor openLocalDatabase() => LazyDatabase(() async {
  final result = await WasmDatabase.open(
    databaseName: 'memox',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  return result.resolvedExecutor;
});

QueryExecutor openInMemoryDatabase() =>
    throw UnsupportedError('In-memory database is not used on web.');
