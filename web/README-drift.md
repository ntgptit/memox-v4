# Drift web assets

The web build runs SQLite as WebAssembly (the native `dart:ffi` backend can't
run in a browser). Two assets must be present in `web/` and are committed:

- `sqlite3.wasm` — the SQLite WASM build, matching the `sqlite3` package version
  (currently 2.9.4). Source:
  `https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-<ver>/sqlite3.wasm`
- `drift_worker.dart.js` — the Drift web worker, compiled from `drift_worker.dart`
  and matching the `drift` package version (currently 2.31.0).

## Regenerating after a dependency bump

When `drift` or `sqlite3` changes in `pubspec.lock`:

```bash
# 1. recompile the worker (must match the installed drift)
dart compile js -O4 web/drift_worker.dart -o web/drift_worker.dart.js

# 2. re-download sqlite3.wasm for the new sqlite3 version
curl -L -o web/sqlite3.wasm \
  https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-<new-ver>/sqlite3.wasm
```

The `.js.deps` / `.js.map` produced by the compile are gitignored.

## Platform wiring

`lib/data/datasources/local/connection/database_connection.dart` conditionally
exports the native (`dart:ffi`) or web (`WasmDatabase`) backend. Local file
backup/restore and file export fall back to "unsupported" stubs on web (no
filesystem) — use cloud sync there. Notifications/TTS depend on browser support.
