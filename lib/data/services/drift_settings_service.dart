import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';
import 'package:memox_v4/domain/services/settings_service.dart';

/// Settings keys (schema contract §settings) owned by this service. The daily-goal
/// and new-per-day keys are owned by `DriftSettingsRepository` (no overlap).
const String _kThemeMode = 'theme.mode';
const String _kThemeAccent = 'theme.accent';
const String _kThemeFontScale = 'theme.font_scale';
const String _kGameWordsPerRound = 'game.words_per_round';
const String _kSrsDueNotifications = 'srs.due_notifications';

/// The default game round size when unset (D-008).
const int _defaultGameWords = 5;

/// Due-notifications default when unset — opt-in, so off.
const bool _defaultSrsDueNotifications = false;

/// Drift-backed [SettingsService] (DT.7) over the `settings` key–value table.
/// `watch*` streams re-emit on any settings write; enums serialize by name.
class DriftSettingsService implements SettingsService {
  DriftSettingsService(this._db);

  final AppDatabase _db;

  @override
  Stream<ThemeSettings> watchTheme() =>
      _watchKeys([_kThemeMode, _kThemeAccent, _kThemeFontScale]).map(
        (values) => ThemeSettings(
          mode: _enumByName(ColorMode.values, values[_kThemeMode]) ??
              ColorMode.system,
          accent: _enumByName(AccentColor.values, values[_kThemeAccent]) ??
              AccentColor.brand,
          fontScale: _enumByName(FontScale.values, values[_kThemeFontScale]) ??
              FontScale.medium,
        ),
      );

  @override
  Future<Result<void>> saveTheme(ThemeSettings settings) => guardAsync(() async {
        await _db.transaction(() async {
          await _put(_kThemeMode, settings.mode.name);
          await _put(_kThemeAccent, settings.accent.name);
          await _put(_kThemeFontScale, settings.fontScale.name);
        });
      });

  @override
  Stream<int> watchGameWordsPerRound() =>
      _watchKeys([_kGameWordsPerRound]).map((values) =>
          int.tryParse(values[_kGameWordsPerRound] ?? '') ?? _defaultGameWords);

  @override
  Future<Result<void>> saveGameWordsPerRound(int count) =>
      guardAsync(() async => _put(_kGameWordsPerRound, count.toString()));

  @override
  Stream<bool> watchSrsDueNotifications() =>
      _watchKeys([_kSrsDueNotifications]).map((values) =>
          values[_kSrsDueNotifications] == null
              ? _defaultSrsDueNotifications
              : values[_kSrsDueNotifications] == 'true');

  @override
  Future<Result<void>> saveSrsDueNotifications(bool enabled) =>
      guardAsync(() async => _put(_kSrsDueNotifications, enabled.toString()));

  Stream<Map<String, String>> _watchKeys(List<String> keys) {
    final query = _db.select(_db.settings)..where((s) => s.key.isIn(keys));
    return query
        .watch()
        .map((rows) => {for (final row in rows) row.key: row.value});
  }

  Future<void> _put(String key, String value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  T? _enumByName<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
