import 'package:memox_v4/core/error/result.dart';

/// File + clipboard I/O for import/export (import-export). A contract only — the
/// `file_picker`/clipboard adapter lands in DT.7 — so the import/export use cases
/// stay plugin-free and testable. Text is UTF-8 (BR-4); parsing/encoding is the
/// use cases' job via `TableCodec`, not this service.
abstract interface class ImportExportFileService {
  /// Let the learner pick a text/CSV file; returns its contents, or null if the
  /// picker was cancelled.
  Future<Result<String?>> pickTextFile();

  /// Write [content] to a user-chosen location with a [suggestedName].
  Future<Result<void>> writeTextFile({
    required String suggestedName,
    required String content,
  });

  Future<Result<String>> readClipboard();
  Future<Result<void>> writeClipboard(String text);
}
