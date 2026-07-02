import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';

/// Appearance + preference settings (personalization + settings). A contract only
/// — the key-value store adapter lands in DT.7. `watch*` streams drive live
/// application (theme changes apply without restart, BR-3).
abstract interface class SettingsService {
  Stream<ThemeSettings> watchTheme();
  Future<Result<void>> saveTheme(ThemeSettings settings);

  /// Words per game round (settings BR-2 / D-008, default 5).
  Stream<int> watchGameWordsPerRound();
  Future<Result<void>> saveGameWordsPerRound(int count);
}
