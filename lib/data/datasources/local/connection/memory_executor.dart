/// The in-memory Drift executor for `AppDatabase.memory()` (data-layer tests).
///
/// Behind a conditional export so the production `app_database.dart` never imports
/// `package:drift/native.dart` (which pulls `dart:ffi`, unavailable on web). On
/// native/VM it is a real `NativeDatabase.memory()`; on web it throws — the web
/// app never uses an in-memory DB, and tests always run on the VM.
library;

export 'memory_executor_native.dart'
    if (dart.library.js_interop) 'memory_executor_web.dart';
