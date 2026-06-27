import 'package:memox_v4/domain/types/result.dart';

/// Reads typed values from the flat `settings` store. W12 extends this with
/// writes; W11 only reads the daily-goal keys.
abstract interface class SettingsRepository {
  /// The integer value for [key], or null when unset/non-numeric.
  Future<Result<int?>> readInt(String key);
}
