import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Hides or unhides a card (UC-3). Hidden cards stay stored but drop out of study
/// queues and due counts (D-006).
class ToggleCardHiddenUseCase {
  const ToggleCardHiddenUseCase(this._repository);

  final CardRepository _repository;

  Future<Result<void>> call(int id, {required bool hidden}) =>
      _repository.setHidden(id, hidden: hidden);
}
