import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/models/card_draft.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/flashcard/check_soft_duplicate.dart';
import 'package:memox_v4/domain/usecases/flashcard/create_card.dart';

/// Outcome of an import run.
class ImportResult {
  const ImportResult({required this.imported, required this.duplicates});

  final int imported;
  final int duplicates;
}

/// Imports parsed table [rows] into a target deck (D-025). Columns are picked by
/// index; the first row is skipped when [hasHeader]. Soft duplicates (D-020) are
/// counted but still imported — the warning never blocks. Parsing CSV/Excel is a
/// data-layer concern (`TableCodec`); this use case is plugin-free + testable.
class ImportCardsUseCase {
  const ImportCardsUseCase(this._create, this._checkDuplicate);

  final CreateCardUseCase _create;
  final CheckSoftDuplicateUseCase _checkDuplicate;

  Future<Result<ImportResult>> call({
    required List<List<String>> rows,
    required int deckId,
    required int termColumn,
    required int meaningColumn,
    required String meaningLang,
    bool hasHeader = true,
  }) async {
    final data = hasHeader && rows.isNotEmpty ? rows.sublist(1) : rows;
    var imported = 0;
    var duplicates = 0;
    for (final row in data) {
      if (termColumn >= row.length) continue;
      final term = row[termColumn].trim();
      if (term.isEmpty) continue;
      final meaning = meaningColumn < row.length
          ? row[meaningColumn].trim()
          : '';
      if (meaning.isEmpty) continue;

      if ((await _checkDuplicate.call(deckId, term)).valueOrNull ?? false) {
        duplicates++;
      }
      final draft = CardDraft(
        deckId: deckId,
        term: term,
        meanings: <CardMeaning>[
          CardMeaning(lang: meaningLang, content: meaning),
        ],
      );
      if (await _create.call(draft) case Ok<dynamic>()) imported++;
    }
    return Ok(ImportResult(imported: imported, duplicates: duplicates));
  }
}
