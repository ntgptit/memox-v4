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

  @override
  Future<Result<Map<String, String>>> readAll() async {
    try {
      return Ok(await _dao.readAll());
    } catch (e) {
      return Err(PersistenceFailure(message: 'read settings', cause: e));
    }
  }

  @override
  Future<Result<void>> write(String key, String value) async {
    try {
      await _dao.write(key, value);
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'write setting', cause: e));
    }
  }

  @override
  Future<Result<void>> remove(String key) async {
    try {
      await _dao.remove(key);
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'remove setting', cause: e));
    }
  }
}
