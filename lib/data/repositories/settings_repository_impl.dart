import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/data/datasources/local/daos/settings_dao.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Drift-backed [SettingsRepository].
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dao);

  final SettingsDao _dao;

  @override
  Future<Result<int?>> readInt(String key) async {
    try {
      final raw = await _dao.read(key);
      return Ok(raw == null ? null : int.tryParse(raw));
    } catch (e) {
      return Err(PersistenceFailure(message: 'read setting', cause: e));
    }
  }
}
