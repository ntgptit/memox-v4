import 'package:memox_v4/domain/entities/card_meaning.dart';

/// The editable content of a card, used by create/update. Identity (`id`,
/// `orderIndex`, `createdAt`) is owned by the repository, not the draft.
class CardDraft {
  const CardDraft({
    required this.deckId,
    required this.term,
    required this.meanings,
    this.gender,
    this.audioRef,
    this.hidden = false,
  });

  final int deckId;
  final String term;
  final String? gender;
  final String? audioRef;
  final bool hidden;
  final List<CardMeaning> meanings;
}
