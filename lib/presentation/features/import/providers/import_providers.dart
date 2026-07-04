import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/import_preview.dart';
import 'package:memox_v4/domain/services/table_codec.dart';
import 'package:memox_v4/domain/usecases/io/import_cards_usecase.dart';
import 'package:memox_v4/domain/usecases/library/card_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'import_providers.g.dart';

/// The steps of the import wizard (kit states).
enum ImportStep { source, mapping, preview, done }

/// Selectable delimiter for the CSV/TSV parse (D-025).
enum ImportSeparator { tab, comma, semicolon }

/// The default language stored on imported meanings (per-pair language selection
/// is deferred — documented gap).
const String _importMeaningLanguage = 'en';

extension on ImportSeparator {
  String get delimiter => switch (this) {
        ImportSeparator.tab => '\t',
        ImportSeparator.comma => ',',
        ImportSeparator.semicolon => ';',
      };
}

/// The import wizard state.
/// The default term / meaning column indices when the picker is untouched
/// (A→term, B→meaning).
const int _defaultTermColumn = 0;
const int _defaultMeaningColumn = 1;

/// How many sample values a mapping row previews for its column.
const int _columnSampleCount = 2;

class ImportState {
  const ImportState({
    required this.step,
    required this.input,
    required this.separator,
    required this.hasHeader,
    required this.termColumn,
    required this.meaningColumn,
    required this.preview,
    required this.duplicateCount,
    required this.importedCount,
  });

  static const ImportState initial = ImportState(
    step: ImportStep.source,
    input: '',
    separator: ImportSeparator.tab,
    hasHeader: false,
    termColumn: _defaultTermColumn,
    meaningColumn: _defaultMeaningColumn,
    preview: null,
    duplicateCount: 0,
    importedCount: 0,
  );

  final ImportStep step;
  final String input;
  final ImportSeparator separator;
  final bool hasHeader;

  /// Which parsed column supplies the card term / meaning (0-based).
  final int termColumn;
  final int meaningColumn;
  final ImportPreview? preview;
  final int duplicateCount;
  final int importedCount;

  ImportState copyWith({
    ImportStep? step,
    String? input,
    ImportSeparator? separator,
    bool? hasHeader,
    int? termColumn,
    int? meaningColumn,
    ImportPreview? preview,
    int? duplicateCount,
    int? importedCount,
  }) {
    return ImportState(
      step: step ?? this.step,
      input: input ?? this.input,
      separator: separator ?? this.separator,
      hasHeader: hasHeader ?? this.hasHeader,
      termColumn: termColumn ?? this.termColumn,
      meaningColumn: meaningColumn ?? this.meaningColumn,
      preview: preview ?? this.preview,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      importedCount: importedCount ?? this.importedCount,
    );
  }
}

/// Drives the import wizard (DM.7 `ParseImportUseCase`, D-025 / D-020; DM.8 file service).
/// Column mapping defaults to A→term, B→meaning but is user-pickable on the
/// mapping step. Cards are written to the first library deck (a deck picker is
/// deferred). No `setState`; failures are logged, not swallowed.
@riverpod
class ImportController extends _$ImportController {
  @override
  ImportState build() => ImportState.initial;

  void setInput(String text) => state = state.copyWith(input: text);

  void setSeparator(ImportSeparator separator) =>
      state = state.copyWith(separator: separator);

  void setHasHeader(bool hasHeader) =>
      state = state.copyWith(hasHeader: hasHeader);

  void setTermColumn(int column) =>
      state = state.copyWith(termColumn: column);

  void setMeaningColumn(int column) =>
      state = state.copyWith(meaningColumn: column);

  /// Number of columns in the current input's first non-empty row (for the
  /// column picker). Zero when there is nothing to parse.
  int columnCount() {
    final delimiter = state.separator.delimiter;
    for (final line in state.input.split('\n')) {
      if (line.trim().isEmpty) continue;
      return line.split(delimiter).length;
    }
    return 0;
  }

  /// A short preview of a column's first data values, for the mapping rows
  /// ("안녕하세요, 감사합니다"). Skips the header row when [ImportState.hasHeader].
  String columnSample(int column) {
    final delimiter = state.separator.delimiter;
    final samples = <String>[];
    var skippedHeader = false;
    for (final line in state.input.split('\n')) {
      if (line.trim().isEmpty) continue;
      if (state.hasHeader && !skippedHeader) {
        skippedHeader = true;
        continue;
      }
      final cells = line.split(delimiter);
      if (column >= 0 && column < cells.length) {
        final value = cells[column].trim();
        if (value.isNotEmpty) samples.add(value);
      }
      if (samples.length >= _columnSampleCount) break;
    }
    return samples.join(', ');
  }

  void goTo(ImportStep step) => state = state.copyWith(step: step);

  /// Advance from the paste step once there is text.
  void continueFromSource() {
    if (state.input.trim().isEmpty) return;
    state = state.copyWith(step: ImportStep.mapping);
  }

  /// Pick a text/CSV file and advance to mapping with its contents.
  Future<void> pickFile() async {
    final result =
        await ref.read(importExportFileServiceProvider).pickTextFile();
    result.fold(
      (content) {
        if (content == null || content.trim().isEmpty) return;
        state = state.copyWith(input: content, step: ImportStep.mapping);
      },
      (failure) =>
          ref.read(loggerProvider).error('import file pick failed', error: failure),
    );
  }

  /// Parse + duplicate-check, then show the preview.
  Future<void> toPreview() async {
    final preview = parseCurrent();
    final duplicates = await _countDuplicates(preview.drafts);
    state = state.copyWith(
      step: ImportStep.preview,
      preview: preview,
      duplicateCount: duplicates,
    );
  }

  /// The live parse of the current input (also used to preview the table on the
  /// mapping step).
  ImportPreview parseCurrent() {
    final codec = CsvCodec(delimiter: state.separator.delimiter);
    final mapping = ColumnMapping(
      termColumn: state.termColumn,
      meaningColumn: state.meaningColumn,
      hasHeader: state.hasHeader,
    );
    return ParseImportUseCase(codec).call(state.input, mapping);
  }

  /// Persist the previewed drafts into the first library deck.
  Future<void> commit() async {
    final preview = state.preview;
    if (preview == null) return;
    final deckId = await _targetDeck();
    if (deckId == null) {
      ref.read(loggerProvider).warn('import has no target deck');
      return;
    }

    final cards = ref.read(cardRepositoryProvider);
    final now = ref.read(clockProvider).now().microsecondsSinceEpoch;
    var imported = 0;
    for (final (index, draft) in preview.drafts.indexed) {
      final card = _draftToCard(draft, deckId, now, index);
      if (card == null) continue;
      final saved = await SaveCardUseCase(cards).call(card);
      if (saved.isOk) imported++;
    }
    state = state.copyWith(step: ImportStep.done, importedCount: imported);
  }

  Card? _draftToCard(CardDraft draft, DeckId deckId, int stamp, int index) {
    final meaning = CardMeaning.create(
      id: CardMeaningId('impm-$stamp-$index'),
      language: _importMeaningLanguage,
      text: draft.meaning,
    );
    if (meaning case Err()) return null;
    final card = Card.create(
      id: CardId('imp-$stamp-$index'),
      deckId: deckId,
      term: draft.term,
      meanings: [(meaning as Ok<CardMeaning>).value],
    );
    return switch (card) {
      Ok<Card>(:final value) => value,
      Err<Card>() => null,
    };
  }

  Future<int> _countDuplicates(List<CardDraft> drafts) async {
    final deckId = await _targetDeck();
    if (deckId == null) return 0;
    final detect = DetectDuplicateTermUseCase(ref.read(cardRepositoryProvider));
    var count = 0;
    for (final draft in drafts) {
      final result = await detect.call(deckId: deckId, term: draft.term);
      if (result case Ok<bool>(:final value) when value) count++;
    }
    return count;
  }

  Future<DeckId?> _targetDeck() async {
    final roots =
        await ref.read(deckRepositoryProvider).watchChildren(null).first;
    return roots.isEmpty ? null : roots.first.id;
  }
}
