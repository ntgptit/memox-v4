import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';

/// Row → entity mapping for decks (read side; the domain [Deck] carries no
/// `languagePairId`/`createdAt` — those stay in the store). A stored row is
/// trusted to be valid; an invalid row is a data-integrity error (thrown, caught
/// as a `Failure` by the repository's `guardAsync`).
Deck deckFromRow(DeckRow row) {
  final result = Deck.create(
    id: DeckId(row.id),
    name: row.name,
    parentId: row.parentId == null ? null : DeckId(row.parentId!),
  );
  return switch (result) {
    Ok<Deck>(:final value) => value,
    Err<Deck>(:final failure) =>
      throw StateError('Corrupt deck row ${row.id}: ${failure.message}'),
  };
}
