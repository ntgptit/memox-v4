import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/ids.dart';

/// Row → entity mapping for a single meaning block.
CardMeaning meaningFromRow(CardMeaningRow row) {
  final result = CardMeaning.create(
    id: CardMeaningId(row.id),
    language: row.language,
    text: row.content,
  );
  return switch (result) {
    Ok<CardMeaning>(:final value) => value,
    Err<CardMeaning>(:final failure) =>
      throw StateError('Corrupt meaning row ${row.id}: ${failure.message}'),
  };
}

/// Row → entity mapping for a card and its meanings (the meanings arrive already
/// ordered by `sortIndex`). A card always has ≥1 meaning (BR-2).
Card cardFromRows(CardRow row, List<CardMeaningRow> meanings) {
  final result = Card.create(
    id: CardId(row.id),
    deckId: DeckId(row.deckId),
    term: row.term,
    meanings: [for (final m in meanings) meaningFromRow(m)],
    hidden: row.hidden,
    audioRef: row.audioRef,
    grammaticalGender: row.grammaticalGender,
  );
  return switch (result) {
    Ok<Card>(:final value) => value,
    Err<Card>(:final failure) =>
      throw StateError('Corrupt card row ${row.id}: ${failure.message}'),
  };
}
