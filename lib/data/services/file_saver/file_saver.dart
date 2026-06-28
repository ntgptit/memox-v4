// Platform-conditional file export. Native writes to the documents dir; web
// has no filesystem (stub throws until a browser-download impl is added).
export 'file_saver_io.dart' if (dart.library.js_interop) 'file_saver_web.dart';
