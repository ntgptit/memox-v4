import 'package:memox_v4/domain/entities/card_meaning.dart';

/// A flashcard: a `term` (the language-being-studied side) plus one or more
/// meaning blocks, optional grammatical gender and audio, and a `hidden` flag
/// (`docs/business/flashcard/flashcard-management.md`). A card belongs to exactly
/// one deck (BR-1). The review schedule lives in `srs_state`, not here.
class Card {
  const Card({
    required this.id,
    required this.deckId,
    required this.term,
    required this.hidden,
    required this.orderIndex,
    required this.createdAt,
    required this.meanings,
    this.gender,
    this.audioRef,
    this.lastStudiedAt,
  });

  final int id;
  final int deckId;

  /// The question side — the word in the language being studied.
  final String term;

  /// Grammatical gender for languages that mark it; null otherwise.
  final String? gender;

  /// Pointer to generated/attached audio (TTS); null until generated.
  final String? audioRef;

  /// Hidden cards are kept but excluded from study queues and due counts (D-006).
  final bool hidden;

  final int orderIndex;

  /// Creation instant, epoch milliseconds.
  final int createdAt;

  /// Last study instant, epoch milliseconds; null if never studied.
  final int? lastStudiedAt;

  /// Meaning blocks (≥1; the first is the native-language meaning, BR-2).
  final List<CardMeaning> meanings;
}
