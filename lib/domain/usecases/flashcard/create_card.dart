import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/models/card_draft.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/flashcard/card_validation.dart';

/// Creates a card after validating it (BR-2). Duplicate terms are allowed — the
/// soft-duplicate check (D-020) is a separate, non-blocking step.
class CreateCardUseCase {
  const CreateCardUseCase(this._repository);

  final CardRepository _repository;

  Future<Result<Card>> call(CardDraft draft) {
    final failure = validateCardDraft(draft);
    if (failure != null) return Future.value(Err(failure));
    return _repository.create(normalizeCardDraft(draft));
  }
}
