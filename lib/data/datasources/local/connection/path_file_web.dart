/// Web has no path-based filesystem; local file backup/restore is unavailable
/// (use cloud sync instead).
Future<void> writePathString(String path, String content) =>
    throw UnsupportedError('Local file backup is not available on web.');

Future<String> readPathString(String path) =>
    throw UnsupportedError('Local file restore is not available on web.');
