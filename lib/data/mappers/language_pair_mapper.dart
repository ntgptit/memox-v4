import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show LanguagePairData;
import 'package:memox_v4/domain/entities/language_pair.dart';

/// Maps a Drift `language_pair` row ([LanguagePairData]) to the domain
/// [LanguagePair] entity.
LanguagePair mapLanguagePairRow(LanguagePairData row) => LanguagePair(
  id: row.id,
  sourceLang: row.sourceLang,
  targetLang: row.targetLang,
  orderIndex: row.orderIndex,
);
