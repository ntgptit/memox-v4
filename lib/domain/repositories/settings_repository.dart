import 'package:memox_v4/domain/types/result.dart';

/// Reads and writes the flat `settings` store.
abstract interface class SettingsRepository {
  /// The integer value for [key], or null when unset/non-numeric.
  Future<Result<int?>> readInt(String key);

  /// All persisted settings as raw strings.
  Future<Result<Map<String, String>>> readAll();

  /// Upserts [key] = [value].
  Future<Result<void>> write(String key, String value);

  /// Removes [key] (resets it to its default).
  Future<Result<void>> remove(String key);
}
