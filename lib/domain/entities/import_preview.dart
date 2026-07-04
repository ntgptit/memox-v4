import 'package:equatable/equatable.dart';

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
