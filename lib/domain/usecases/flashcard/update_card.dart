import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/models/card_draft.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/flashcard/card_validation.dart';

/// Edits a card's content (term, meanings, gender, hidden). The review schedule
/// is untouched (UC-2 postcondition).
class UpdateCardUseCase {
  const UpdateCardUseCase(this._repository);

  final CardRepository _repository;

  Future<Result<Card>> call(int id, CardDraft draft) {
    final failure = validateCardDraft(draft);
    if (failure != null) return Future.value(Err(failure));
    return _repository.update(id, normalizeCardDraft(draft));
  }
}
