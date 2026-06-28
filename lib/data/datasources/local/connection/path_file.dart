// Platform-conditional path-based file IO for local backup/restore. Native uses
// dart:io; web stubs throw (no filesystem).
export 'path_file_io.dart' if (dart.library.js_interop) 'path_file_web.dart';
