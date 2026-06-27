import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show DeckData;
import 'package:memox_v4/domain/entities/deck.dart';

/// Maps a Drift `deck` row ([DeckData]) to the domain [Deck] entity.
Deck mapDeck(DeckData row) => Deck(
  id: row.id,
  pairId: row.pairId,
  parentDeckId: row.parentDeckId,
  name: row.name,
  orderIndex: row.orderIndex,
);
