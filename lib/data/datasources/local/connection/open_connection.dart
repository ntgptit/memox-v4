/// Opens the platform-appropriate Drift `QueryExecutor` for the app database.
///
/// The implementation is chosen at compile time via conditional export:
/// **native** (mobile / desktop / the test VM) uses `NativeDatabase` over a file
/// in the app-documents dir; **web** uses `WasmDatabase` over `sqlite3.wasm` +
/// `drift_worker.js` (see `docs/database/web-setup.md`). Tests never call this —
/// they use `AppDatabase.memory()` — so the plugin/wasm path stays out of
/// `flutter test`.
library;

export 'open_connection_native.dart'
    if (dart.library.js_interop) 'open_connection_web.dart';
