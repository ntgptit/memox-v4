import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';

/// Row → entity mapping for a language pair; an invalid stored row is corruption.
LanguagePair languagePairFromRow(LanguagePairRow row) {
  final result = LanguagePair.create(
    id: LanguagePairId(row.id),
    learningLanguage: row.learningLanguage,
    nativeLanguage: row.nativeLanguage,
  );
  return switch (result) {
    Ok<LanguagePair>(:final value) => value,
    Err<LanguagePair>(:final failure) =>
      throw StateError('Corrupt language-pair row ${row.id}: ${failure.message}'),
  };
}
