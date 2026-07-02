import 'package:equatable/equatable.dart';
import 'package:memox_v4/domain/usecases/io/table_codec.dart';

/// Which columns of the imported table hold the term and the meaning, and whether
/// the first row is a header to skip (D-025).
class ColumnMapping extends Equatable {
  const ColumnMapping({
    required this.termColumn,
    required this.meaningColumn,
    this.hasHeader = false,
  });

  final int termColumn;
  final int meaningColumn;
  final bool hasHeader;

  @override
  List<Object> get props => [termColumn, meaningColumn, hasHeader];
}

/// A parsed, not-yet-persisted card from an import row — just the two required
/// fields. It becomes a real card (with ids + deck) at write time.
class CardDraft extends Equatable {
  const CardDraft({required this.term, required this.meaning});

  final String term;
  final String meaning;

  @override
  List<Object> get props => [term, meaning];
}

/// The preview shown before writing (import-export BR-2): the drafts that parsed
/// cleanly plus how many rows were skipped (too short / missing a field).
class ImportPreview extends Equatable {
  const ImportPreview({required this.drafts, required this.skipped});

  final List<CardDraft> drafts;
  final int skipped;

  @override
  List<Object> get props => [drafts, skipped];
}

/// Decodes import text with the chosen [TableCodec] (delimiter/format) and maps
/// the selected columns into card drafts for the preview step (D-025). Rows too
/// short for the mapping, or missing a term/meaning, are skipped and counted —
/// never silently dropped. Soft-duplicate warning against the deck happens at
/// write time via `DetectDuplicateTerm` (D-020).
class ParseImport {
  const ParseImport(this._codec);

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
