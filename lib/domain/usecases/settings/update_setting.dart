import 'package:memox_v4/domain/repositories/settings_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Writes a single setting; a null [value] resets it to its default.
class UpdateSettingUseCase {
  const UpdateSettingUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Result<void>> call(String key, String? value) =>
      value == null ? _repository.remove(key) : _repository.write(key, value);
}
