import 'package:equatable/equatable.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/ids.dart';

/// A single meaning block of a card (`Nghĩa`) — free text in one language (BR-3).
/// A card may hold several, one per language.
class CardMeaning extends Equatable {
  const CardMeaning._({
    required this.id,
    required this.language,
    required this.text,
  });

  /// Validated construction — language and text must be non-empty.
  static Result<CardMeaning> create({
    required CardMeaningId id,
    required String language,
    required String text,
  }) {
    if (language.trim().isEmpty || text.trim().isEmpty) {
      return const Err(
        ValidationFailure('A meaning needs a language and non-empty text'),
      );
    }
    return Ok(CardMeaning._(id: id, language: language, text: text));
  }

  final CardMeaningId id;
  final String language;
  final String text;

  @override
  List<Object> get props => [id.value, language, text];
}
