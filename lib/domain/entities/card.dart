import 'package:equatable/equatable.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/ids.dart';

/// A study card (`Thẻ học`) — the central unit. A term (the learning-language
/// side) plus one or more meaning blocks, an optional pronunciation audio, an
/// optional grammatical gender, and a hidden flag. Belongs to exactly one deck
/// (BR-1).
class Card extends Equatable {
  Card._({
    required this.id,
    required this.deckId,
    required this.term,
    required List<CardMeaning> meanings,
    required this.hidden,
    this.audioRef,
    this.grammaticalGender,
  }) : meanings = List.unmodifiable(meanings);

  /// Validated construction — a term and at least one meaning are required
  /// (BR-2). Audio generation is deferred, so [audioRef] may be null.
  static Result<Card> create({
    required CardId id,
    required DeckId deckId,
    required String term,
    required List<CardMeaning> meanings,
    bool hidden = false,
    String? audioRef,
    String? grammaticalGender,
  }) {
    if (term.trim().isEmpty) {
      return const Err(ValidationFailure('A card needs a term'));
    }
    if (meanings.isEmpty) {
      return const Err(ValidationFailure('A card needs at least one meaning'));
    }
    return Ok(
      Card._(
        id: id,
        deckId: deckId,
        term: term,
        meanings: meanings,
        hidden: hidden,
        audioRef: audioRef,
        grammaticalGender: grammaticalGender,
      ),
    );
  }

  final CardId id;
  final DeckId deckId;
  final String term;
  final List<CardMeaning> meanings;

  /// Set aside by the learner — excluded from queues and due counts (BR-4).
  final bool hidden;

  /// Pronunciation audio reference; null until audio generation ships.
  final String? audioRef;

  /// Optional grammatical gender note.
  final String? grammaticalGender;

  bool get isHidden => hidden;

  @override
  List<Object?> get props => [
        id.value,
        deckId.value,
        term,
        meanings,
        hidden,
        audioRef,
        grammaticalGender,
      ];
}
