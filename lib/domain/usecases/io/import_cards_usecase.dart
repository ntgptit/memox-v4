import 'package:memox_v4/domain/entities/import_preview.dart';
import 'package:memox_v4/domain/services/table_codec.dart';

/// Decodes import text with the chosen [TableCodec] (delimiter/format) and maps
/// the selected columns into card drafts for the preview step (D-025). Rows too
/// short for the mapping, or missing a term/meaning, are skipped and counted —
/// never silently dropped. Soft-duplicate warning against the deck happens at
/// write time via `DetectDuplicateTermUseCase` (D-020).
class ParseImportUseCase {
  const ParseImportUseCase(this._codec);

  final TableCodec _codec;

  ImportPreview call(String input, ColumnMapping mapping) {
    final table = _codec.decode(input);
    final rows =
        mapping.hasHeader && table.isNotEmpty ? table.skip(1) : table;
    final widthNeeded =
        (mapping.termColumn > mapping.meaningColumn
            ? mapping.termColumn
            : mapping.meaningColumn) +
        1;

    final drafts = <CardDraft>[];
    var skipped = 0;
    for (final row in rows) {
      if (row.length < widthNeeded) {
        skipped++;
        continue;
      }
      final term = row[mapping.termColumn].trim();
      final meaning = row[mapping.meaningColumn].trim();
      if (term.isEmpty || meaning.isEmpty) {
        skipped++;
        continue;
      }
      drafts.add(CardDraft(term: term, meaning: meaning));
    }
    return ImportPreview(drafts: drafts, skipped: skipped);
  }
}
