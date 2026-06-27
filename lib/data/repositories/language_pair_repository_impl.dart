import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/data/datasources/local/daos/language_pair_dao.dart';
import 'package:memox_v4/data/mappers/language_pair_mapper.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/repositories/language_pair_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Drift-backed [LanguagePairRepository]. Maps low-level storage errors to
/// [PersistenceFailure] at this boundary; raw exceptions never reach presentation
/// (`docs/contracts/error-contract.md`).
class LanguagePairRepositoryImpl implements LanguagePairRepository {
  const LanguagePairRepositoryImpl(this._dao);

  final LanguagePairDao _dao;

  /// `settings` keys owning the app-wide pair context
  /// (`docs/database/schema-contract.md`).
  static const String _activePairIdKey = 'active_pair_id';
  static const String _displaySwappedKey = 'display_swapped';

  @override
  Future<Result<List<LanguagePair>>> list() async {
    try {
      final rows = await _dao.allPairs();
      return Ok(rows.map(mapLanguagePairRow).toList(growable: false));
    } catch (e) {
      return Err(PersistenceFailure(message: 'list language pairs', cause: e));
    }
  }

  @override
  Future<Result<LanguagePair>> create({
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      final orderIndex = await _dao.countPairs();
      final row = await _dao.insertPair(
        sourceLang: sourceLang,
        targetLang: targetLang,
        orderIndex: orderIndex,
      );
      return Ok(mapLanguagePairRow(row));
    } catch (e) {
      return Err(PersistenceFailure(message: 'create language pair', cause: e));
    }
  }

  @override
  Future<Result<void>> remove(int id) async {
    try {
      await _dao.deletePair(id);
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'remove language pair', cause: e));
    }
  }

  @override
  Future<Result<int?>> activePairId() async {
    try {
      final raw = await _dao.readSetting(_activePairIdKey);
      return Ok(raw == null ? null : int.tryParse(raw));
    } catch (e) {
      return Err(PersistenceFailure(message: 'read active pair', cause: e));
    }
  }

  @override
  Future<Result<void>> setActivePairId(int id) async {
    try {
      await _dao.writeSetting(_activePairIdKey, id.toString());
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'set active pair', cause: e));
    }
  }

  @override
  Future<Result<bool>> displaySwapped() async {
    try {
      final raw = await _dao.readSetting(_displaySwappedKey);
      return Ok(raw == 'true');
    } catch (e) {
      return Err(
        PersistenceFailure(message: 'read display direction', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> setDisplaySwapped(bool swapped) async {
    try {
      await _dao.writeSetting(_displaySwappedKey, swapped.toString());
      return const Ok<void>(null);
    } catch (e) {
      return Err(
        PersistenceFailure(message: 'set display direction', cause: e),
      );
    }
  }
}
