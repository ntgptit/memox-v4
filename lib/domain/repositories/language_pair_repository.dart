import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Persists language pairs and the app-wide pair context (active pair + display
/// direction). The interface lives in domain; the Drift-backed implementation
/// lives in data. Use cases depend only on this interface
/// (`docs/contracts/repository-contracts/_template.md`).
///
/// Backing storage: `language_pair` table plus two `settings` keys
/// (`active_pair_id`, `display_swapped`) — see
/// `docs/database/schema-contract.md`. No state is held only in memory.
abstract interface class LanguagePairRepository {
  /// All pairs ordered by `order_index`.
  Future<Result<List<LanguagePair>>> list();

  /// Creates a pair (appended after the current last). Returns the stored row.
  Future<Result<LanguagePair>> create({
    required String sourceLang,
    required String targetLang,
  });

  /// Deletes a pair and (via FK cascade) all of its content.
  Future<Result<void>> remove(int id);

  /// The persisted active pair id, or null when none has been chosen.
  Future<Result<int?>> activePairId();

  /// Persists the chosen active pair id.
  Future<Result<void>> setActivePairId(int id);

  /// Whether the active pair shows the target language as the question side.
  Future<Result<bool>> displaySwapped();

  /// Persists the display direction flag.
  Future<Result<void>> setDisplaySwapped(bool swapped);
}
