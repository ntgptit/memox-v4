import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// The IndexedDB/OPFS database name (web).
const String _dbName = 'memox';

/// Web: a `WasmDatabase` backed by `sqlite3.wasm` + `drift_worker.js` served from
/// the web root (fetch them into `web/`, see `docs/database/web-setup.md`). Drift
/// probes the browser and picks the best storage (OPFS → IndexedDB). Returned via
/// `DatabaseConnection.delayed` so the executor is available synchronously while
/// the wasm module loads.
QueryExecutor openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: _dbName,
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  }));
}
