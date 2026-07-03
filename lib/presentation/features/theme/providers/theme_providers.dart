import 'package:flutter/material.dart' show ThemeMode;
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_providers.g.dart';

/// The learner's appearance preferences (DM.8 `SettingsService`, personalization
/// BR-1..3), read live and saved on change. An async notifier rendered with
/// `AsyncValue.when`. The setting stream does not fail (no `Result`), so there is
/// no read-error state; a failed *save* is logged, not swallowed.
@riverpod
class ThemeController extends _$ThemeController {
  @override
  Future<ThemeSettings> build() =>
      ref.watch(settingsServiceProvider).watchTheme().first;

  Future<void> setMode(ColorMode mode) => _save((s) => s.copyWith(mode: mode));

  Future<void> setAccent(AccentColor accent) =>
      _save((s) => s.copyWith(accent: accent));

  Future<void> setFontScale(FontScale scale) =>
      _save((s) => s.copyWith(fontScale: scale));

  Future<void> _save(ThemeSettings Function(ThemeSettings) update) async {
    final current = state.value ?? const ThemeSettings();
    final result =
        await ref.read(settingsServiceProvider).saveTheme(update(current));
    if (result case Err(:final failure)) {
      ref.read(loggerProvider).error('save theme failed', error: failure);
      return;
    }
    ref.invalidateSelf();
  }
}

/// The app-wide [ThemeMode] derived from the saved colour mode (BR-1/BR-3), so the
/// theme applies live. Accent + font-scale live re-theming is deferred (the token
/// system is single-accent) — those are persisted + previewed on the theme screen.
@riverpod
Stream<ThemeMode> themeMode(Ref ref) =>
    ref.watch(settingsServiceProvider).watchTheme().map(
          (settings) => switch (settings.mode) {
            ColorMode.light => ThemeMode.light,
            ColorMode.dark => ThemeMode.dark,
            ColorMode.system => ThemeMode.system,
          },
        );
