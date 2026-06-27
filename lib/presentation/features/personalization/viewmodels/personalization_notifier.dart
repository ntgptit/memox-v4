import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/settings_providers.dart';
import 'package:memox_v4/core/constants/settings_keys.dart';
import 'package:memox_v4/core/theme/theme_prefs.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/settings/update_setting.dart';

/// Theme personalization (kept alive): mode + accent + font scale, persisted via
/// the W12 settings store and applied live by `MemoXApp`.
final personalizationNotifierProvider =
    AsyncNotifierProvider<PersonalizationNotifier, ThemePrefs>(
      PersonalizationNotifier.new,
    );

class PersonalizationNotifier extends AsyncNotifier<ThemePrefs> {
  UpdateSettingUseCase get _update =>
      UpdateSettingUseCase(ref.read(settingsRepositoryProvider));

  @override
  Future<ThemePrefs> build() => _load();

  Future<ThemePrefs> _load() async {
    final raw =
        (await ref.read(settingsRepositoryProvider).readAll()).valueOrNull ??
        const <String, String>{};
    return ThemePrefs(
      mode: ThemePrefs.parseMode(raw[SettingsKeys.themeMode]),
      accent: ThemePrefs.parseAccent(raw[SettingsKeys.accentColor]),
      fontScale: ThemePrefs.parseFontScale(raw[SettingsKeys.fontScale]),
    );
  }

  Future<void> setMode(ThemeMode mode) =>
      _set(SettingsKeys.themeMode, mode.name);

  Future<void> setAccent(AccentChoice accent) =>
      _set(SettingsKeys.accentColor, accent.name);

  Future<void> setFontScale(FontScale scale) =>
      _set(SettingsKeys.fontScale, scale.name);

  Future<void> _set(String key, String value) async {
    await _update.call(key, value);
    state = await AsyncValue.guard(_load);
  }
}
