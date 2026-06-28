// Drift web worker entrypoint. Compiled to `web/drift_worker.dart.js` (committed)
// via: dart compile js -O4 web/drift_worker.dart -o web/drift_worker.dart.js
// Must be recompiled when the `drift` version changes. See web/README-drift.md.
import 'package:drift/wasm.dart';

void main() => WasmDatabase.workerMainForOpen();
