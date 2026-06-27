import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Soft-duplicate check (D-020 / BR-5): reports whether a term already exists in
/// the deck so the editor can warn — it never blocks the save.
class CheckSoftDuplicateUseCase {
  const CheckSoftDuplicateUseCase(this._repository);

  final CardRepository _repository;

  Future<Result<bool>> call(int deckId, String term, {int? excludingCardId}) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return Future.value(const Ok(false));
    return _repository.termExists(
      deckId,
      trimmed,
      excludingCardId: excludingCardId,
    );
  }
}
