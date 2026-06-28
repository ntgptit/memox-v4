/// Web has no app filesystem; file export needs a browser download (follow-up).
Future<String> saveExportBytes(String fileName, List<int> bytes) =>
    throw UnsupportedError('Saving files is not available on web yet.');
