import 'package:memox_v4/domain/repositories/language_pair_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Toggles the active pair's display direction and returns the new value.
///
/// Direction is a display concern only — it never forks the schedule, which
/// stays single-direction per card (D-011).
class SwapDisplayDirectionUseCase {
  const SwapDisplayDirectionUseCase(this._repository);

  final LanguagePairRepository _repository;

  Future<Result<bool>> call() async {
    final current = await _repository.displaySwapped();
    return switch (current) {
      Err(:final failure) => Err(failure),
      Ok(:final value) => _set(!value),
    };
  }

  Future<Result<bool>> _set(bool next) async {
    final result = await _repository.setDisplaySwapped(next);
    return switch (result) {
      Err(:final failure) => Err(failure),
      Ok() => Ok(next),
    };
  }
}
