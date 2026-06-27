import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/domain/models/card_draft.dart';

/// Validates a card draft (BR-2): a non-empty term and at least one meaning whose
/// content is non-empty. Returns a [ValidationFailure] describing the first
/// problem, or null when the draft is valid.
Failure? validateCardDraft(CardDraft draft) {
  if (draft.term.trim().isEmpty) {
    return const ValidationFailure(message: 'term is required');
  }
  if (draft.meanings.isEmpty) {
    return const ValidationFailure(message: 'at least one meaning is required');
  }
  for (final meaning in draft.meanings) {
    if (meaning.content.trim().isEmpty) {
      return const ValidationFailure(message: 'meaning content is required');
    }
  }
  return null;
}

/// Trims the term, meaning contents, and gender (empty gender → null) so storage
/// never holds surrounding whitespace.
CardDraft normalizeCardDraft(CardDraft draft) {
  final gender = draft.gender?.trim();
  return CardDraft(
    deckId: draft.deckId,
    term: draft.term.trim(),
    gender: (gender == null || gender.isEmpty) ? null : gender,
    audioRef: draft.audioRef,
    hidden: draft.hidden,
    meanings: draft.meanings
        .map((m) => m.copyWith(content: m.content.trim()))
        .toList(growable: false),
  );
}
