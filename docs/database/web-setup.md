# Web database setup (Drift on WebAssembly)

> How the local Drift database runs on the **web** target alongside native
> (mobile/desktop). Native uses a file `NativeDatabase`; web uses a
> `WasmDatabase` backed by `sqlite3.wasm` + a drift web worker, with the browser
> picking the best persistent storage (OPFS → IndexedDB).

## How the connection is chosen

`AppDatabase` takes any Drift `QueryExecutor`; the platform-appropriate one is
resolved **at compile time** by a conditional export — no `dart:io`/`dart:ffi`
ever reaches the web build:

| File | Platform | Executor |
| --- | --- | --- |
| `lib/data/datasources/local/connection/open_connection.dart` | — | conditional `export` |
| `…/open_connection_native.dart` | mobile · desktop · **VM (tests)** | `NativeDatabase` on a file in the app-documents dir |
| `…/open_connection_web.dart` | **web** | `WasmDatabase.open(sqlite3Uri: sqlite3.wasm, driftWorkerUri: drift_worker.js)` |
| `…/memory_executor{,_native,_web}.dart` | `AppDatabase.memory()` (tests) | `NativeDatabase.memory()` on VM; throws on web |

`appDatabaseProvider` just calls `openConnection()`; tests override it with
`AppDatabase.memory()`, so neither the plugin nor the wasm path runs under
`flutter test`.

> **Why the split.** `package:drift/native.dart` imports `dart:ffi`, which does
> not exist on web — so importing it (even for the test-only `.memory()` ctor)
> would break `flutter build web`. Both the file executor **and** the in-memory
> executor are therefore behind conditional imports.

## Required web assets

The web target needs two files served from the web root (`web/`), pinned to the
resolved package versions in `pubspec.lock`:

- **`web/sqlite3.wasm`** — the SQLite WebAssembly build (from the `sqlite3`
  package's GitHub release).
- **`web/drift_worker.js`** — drift's web worker (from the `drift` package's
  GitHub release).

Fetch/update them with the pinned-version script:

```bash
node tool/web/fetch_db_assets.mjs
```

Re-run it whenever `drift` or `sqlite3` in `pubspec.lock` changes — a mismatch
between the Dart package and the wasm/worker can fail the web DB at runtime. The
two assets are committed to the repo so `flutter build web` works out of the box.

## Building / running on web

```bash
node tool/web/fetch_db_assets.mjs   # once, or after a drift/sqlite3 bump
flutter run -d chrome               # dev
flutter build web                   # release → build/web/ (assets copied in)
```

Cross-origin isolation note: the fastest storage (OPFS with shared workers) needs
the page served with the `Cross-Origin-Opener-Policy: same-origin` +
`Cross-Origin-Embedder-Policy: require-corp` headers. Without them the web DB
still works — drift transparently falls back to IndexedDB — just a bit slower.

## Not covered here

- **First-run seeding on web.** Like every platform, the app still needs a
  startup hook to open the DB and call `DatabaseSeeder.ensureFirstRun()` before
  the first repository use (the DT.6 bootstrap gap) — otherwise the deck FK has no
  active language pair. That app-integration step is platform-agnostic and tracked
  separately from this DB-connection wiring.
