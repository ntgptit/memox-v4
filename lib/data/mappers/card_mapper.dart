import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show CardData, CardMeaningData;
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';

/// Maps a Drift card row + its meaning rows to the domain [Card] aggregate.
Card mapCard(CardData row, List<CardMeaningData> meanings) => Card(
  id: row.id,
  deckId: row.deckId,
  term: row.term,
  gender: row.gender,
  audioRef: row.audioRef,
  hidden: row.hidden,
  orderIndex: row.orderIndex,
  createdAt: row.createdAt,
  lastStudiedAt: row.lastStudiedAt,
  meanings: meanings.map(mapCardMeaning).toList(growable: false),
);

CardMeaning mapCardMeaning(CardMeaningData row) =>
    CardMeaning(id: row.id, lang: row.lang, content: row.content);
