// Platform-conditional database backend. Mobile/desktop use `NativeDatabase`
// (dart:ffi); web uses `WasmDatabase` (sqlite3.wasm). This file itself imports
// no platform library so it compiles everywhere; the conditional export wires
// `openLocalDatabase()` / `openInMemoryDatabase()` to the right implementation.
export 'connection_unsupported.dart'
    if (dart.library.io) 'connection_native.dart'
    if (dart.library.js_interop) 'connection_web.dart';
