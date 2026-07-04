import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/services/table_codec.dart';
import 'package:memox_v4/domain/usecases/io/export_cards_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_providers.g.dart';

/// The steps of the export flow (kit states).
enum ExportStep { config, exporting, done }

/// Export scope — the current deck only, or its whole subtree.
enum ExportScope { deck, subtree }

/// Output format. Excel reuses the CSV encoder (binary `.xlsx` is deferred — the
/// pure `CsvCodec` produces text; documented gap).
enum ExportFormat { csv, excel, copy }

/// Delimiter for the CSV/TSV encode (D-025).
enum ExportSeparator { tab, comma, semicolon }

/// The suggested filename for a written export.
const String _exportFileName = 'memox-export.csv';

extension on ExportSeparator {
  String get delimiter => switch (this) {
        ExportSeparator.tab => '\t',
        ExportSeparator.comma => ',',
        ExportSeparator.semicolon => ';',
      };
}

/// The export wizard state.
class ExportState {
  const ExportState({
    required this.step,
    required this.scope,
    required this.format,
    required this.separator,
    required this.includeSrs,
    required this.exportedCount,
    required this.content,
  });

  static const ExportState initial = ExportState(
    step: ExportStep.config,
    scope: ExportScope.deck,
    format: ExportFormat.csv,
    separator: ExportSeparator.tab,
    includeSrs: true,
    exportedCount: 0,
    content: '',
  );

  final ExportStep step;
  final ExportScope scope;
  final ExportFormat format;
  final ExportSeparator separator;
  final bool includeSrs;
  final int exportedCount;
  final String content;

  ExportState copyWith({
    ExportStep? step,
    ExportScope? scope,
    ExportFormat? format,
    ExportSeparator? separator,
    bool? includeSrs,
    int? exportedCount,
    String? content,
  }) {
    return ExportState(
      step: step ?? this.step,
      scope: scope ?? this.scope,
      format: format ?? this.format,
      separator: separator ?? this.separator,
      includeSrs: includeSrs ?? this.includeSrs,
      exportedCount: exportedCount ?? this.exportedCount,
      content: content ?? this.content,
    );
  }
}

/// Drives the export flow (DM.7 `BuildExportUseCase`, D-026; DM.8 file service). Gathers
/// the first library deck's cards (a deck picker is deferred), encodes them, and
/// writes/copies based on the chosen format. No `setState`; failures are logged.
@riverpod
class ExportController extends _$ExportController {
  @override
  ExportState build() => ExportState.initial;

  void setScope(ExportScope scope) => state = state.copyWith(scope: scope);
  void setFormat(ExportFormat format) => state = state.copyWith(format: format);
  void setSeparator(ExportSeparator separator) =>
      state = state.copyWith(separator: separator);
  void setIncludeSrs(bool value) => state = state.copyWith(includeSrs: value);

  /// Encode the deck's cards and perform the primary output for the chosen format.
  Future<void> run() async {
    state = state.copyWith(step: ExportStep.exporting);
    final items = await _gatherItems();
    final codec = CsvCodec(delimiter: state.separator.delimiter);
    final content = BuildExportUseCase(codec).call(items, includeSrs: state.includeSrs);

    final files = ref.read(importExportFileServiceProvider);
    final Result<void> output = switch (state.format) {
      ExportFormat.copy => await files.writeClipboard(content),
      ExportFormat.csv || ExportFormat.excel => await files.writeTextFile(
          suggestedName: _exportFileName,
          content: content,
        ),
    };

    if (output case Err(:final failure)) {
      ref.read(loggerProvider).error('export output failed', error: failure);
      state = state.copyWith(step: ExportStep.config);
      return;
    }
    state = state.copyWith(
      step: ExportStep.done,
      exportedCount: items.length,
      content: content,
    );
  }

  /// Re-share the encoded content as text.
  Future<void> share() async {
    final result =
        await ref.read(importExportFileServiceProvider).writeClipboard(state.content);
    if (result case Err(:final failure)) {
      ref.read(loggerProvider).error('export share failed', error: failure);
    }
  }

  /// Re-save the encoded content to a file.
  Future<void> save() async {
    final result = await ref.read(importExportFileServiceProvider).writeTextFile(
          suggestedName: _exportFileName,
          content: state.content,
        );
    if (result case Err(:final failure)) {
      ref.read(loggerProvider).error('export save failed', error: failure);
    }
  }

  Future<List<ExportItem>> _gatherItems() async {
    final decks = ref.read(deckRepositoryProvider);
    final cardsRepo = ref.read(cardRepositoryProvider);
    final reviews = ref.read(reviewRepositoryProvider);

    final roots = await decks.watchChildren(null).first;
    if (roots.isEmpty) return const [];
    final rootId = roots.first.id;

    final deckIds = state.scope == ExportScope.subtree
        ? await _subtree(rootId, decks)
        : <DeckId>[rootId];

    final items = <ExportItem>[];
    for (final deckId in deckIds) {
      final cards = await cardsRepo.watchByDeck(deckId).first;
      for (final card in cards) {
        // The frozen contract exposes the box but no dueAt read, so the due date
        // is blank in the export (documented gap).
        final box = await reviews.currentBox(card.id);
        final srs = switch (box) {
          Ok(:final value) => SrsState(box: value),
          Err() => null,
        };
        items.add((card: card, srs: srs));
      }
    }
    return items;
  }

  Future<List<DeckId>> _subtree(DeckId root, DeckRepository decks) async {
    final ids = <DeckId>[root];
    final queue = <DeckId>[root];
    while (queue.isNotEmpty) {
      final id = queue.removeLast();
      final children = await decks.watchChildren(id).first;
      for (final child in children) {
        ids.add(child.id);
        queue.add(child.id);
      }
    }
    return ids;
  }
}
