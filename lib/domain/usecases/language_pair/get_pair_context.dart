import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/models/language_pair_context.dart';
import 'package:memox_v4/domain/repositories/language_pair_repository.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/language_pair/list_language_pairs.dart';

/// Reads the full pair context: the pair list plus the resolved active pair and
/// display direction. When no pair is explicitly active, the first pair is used.
class GetPairContextUseCase {
  const GetPairContextUseCase(this._repository);

  final LanguagePairRepository _repository;

  Future<Result<LanguagePairContext>> call() async {
    final pairsResult = await ListLanguagePairsUseCase(_repository).call();
    return switch (pairsResult) {
      Err(:final failure) => Err(failure),
      Ok(:final value) => _resolve(value),
    };
  }

  Future<Result<LanguagePairContext>> _resolve(List<LanguagePair> pairs) async {
    final activeId = (await _repository.activePairId()).valueOrNull;
    final swapped = (await _repository.displaySwapped()).getOrElse(
      (_) => false,
    );
    return Ok(
      LanguagePairContext(
        pairs: pairs,
        active: _activeOf(pairs, activeId),
        displaySwapped: swapped,
      ),
    );
  }

  LanguagePair? _activeOf(List<LanguagePair> pairs, int? activeId) {
    if (pairs.isEmpty) return null;
    for (final pair in pairs) {
      if (pair.id == activeId) return pair;
    }
    return pairs.first;
  }
}
