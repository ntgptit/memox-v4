import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/usecases/io/import_cards.dart';
import 'package:memox_v4/domain/usecases/io/table_codec.dart';
import 'package:memox_v4/domain/usecases/library/card_use_cases.dart';
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
class ImportState {
  const ImportState({
    required this.step,
    required this.input,
    required this.separator,
    required this.hasHeader,
    required this.preview,
    required this.duplicateCount,
    required this.importedCount,
  });

  static const ImportState initial = ImportState(
    step: ImportStep.source,
    input: '',
    separator: ImportSeparator.tab,
    hasHeader: false,
    preview: null,
    duplicateCount: 0,
    importedCount: 0,
  );

  final ImportStep step;
  final String input;
  final ImportSeparator separator;
  final bool hasHeader;
  final ImportPreview? preview;
  final int duplicateCount;
  final int importedCount;

  ImportState copyWith({
    ImportStep? step,
    String? input,
    ImportSeparator? separator,
    bool? hasHeader,
    ImportPreview? preview,
    int? duplicateCount,
    int? importedCount,
  }) {
    return ImportState(
      step: step ?? this.step,
      input: input ?? this.input,
      separator: separator ?? this.separator,
      hasHeader: hasHeader ?? this.hasHeader,
      preview: preview ?? this.preview,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      importedCount: importedCount ?? this.importedCount,
    );
  }
}

/// Drives the import wizard (DM.7 `ParseImport`, D-025 / D-020; DM.8 file service).
/// Column mapping is fixed to A→term, B→meaning (a column picker is deferred).
/// Cards are written to the first library deck (a deck picker is deferred). No
/// `setState`; failures are logged, not swallowed.
@riverpod
class ImportController extends _$ImportController {
  @override
  ImportState build() => ImportState.initial;

  void setInput(String text) => state = state.copyWith(input: text);

  void setSeparator(ImportSeparator separator) =>
      state = state.copyWith(separator: separator);

  void setHasHeader(bool hasHeader) =>
      state = state.copyWith(hasHeader: hasHeader);

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
      termColumn: 0,
      meaningColumn: 1,
      hasHeader: state.hasHeader,
    );
    return ParseImport(codec).call(state.input, mapping);
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
      final saved = await SaveCard(cards).call(card);
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
    final detect = DetectDuplicateTerm(ref.read(cardRepositoryProvider));
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
