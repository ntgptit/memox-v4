import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';

/// Stores the learner's language pairs and which one is active (glossary). Every
/// piece of content belongs to a pair, and most screens scope to the selected
/// one. Validation of a new pair (D-030) is enforced by [LanguagePair.create]
/// before [add] — the store persists an already-valid pair.
abstract interface class LanguagePairService {
  Stream<List<LanguagePair>> watchAll();

  /// The currently selected pair id, or null before the learner has picked one.
  Stream<LanguagePairId?> watchSelected();

  Future<Result<void>> select(LanguagePairId id);
  Future<Result<LanguagePair>> add(LanguagePair pair);
  Future<Result<void>> remove(LanguagePairId id);
}
