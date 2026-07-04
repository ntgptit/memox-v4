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
/// theme applies live. **Accent** live re-theming is still deferred — the token
/// system is single-accent (no `warm`/`cool` accent tokens; that needs a
/// design-system change), so accent is persisted + previewed only. **Font scale**
/// is now applied live app-wide via [textScaleFactor].
@riverpod
Stream<ThemeMode> themeMode(Ref ref) =>
    ref.watch(settingsServiceProvider).watchTheme().map(
          (settings) => switch (settings.mode) {
            ColorMode.light => ThemeMode.light,
            ColorMode.dark => ThemeMode.dark,
            ColorMode.system => ThemeMode.system,
          },
        );

/// Text-scale factors for each [FontScale] step (applied app-wide via a
/// MediaQuery `TextScaler` — see `MemoxApp`).
const double fontScaleSmallFactor = 0.9;
const double fontScaleMediumFactor = 1.0;
const double fontScaleLargeFactor = 1.15;

/// The relative text scale for a [FontScale] setting.
extension FontScaleFactor on FontScale {
  double get factor => switch (this) {
        FontScale.small => fontScaleSmallFactor,
        FontScale.medium => fontScaleMediumFactor,
        FontScale.large => fontScaleLargeFactor,
      };
}

/// The app-wide text scale derived from the saved font-scale setting, so the
/// choice on the theme screen applies live everywhere (personalization BR-2/BR-3).
@riverpod
Stream<double> textScaleFactor(Ref ref) =>
    ref.watch(settingsServiceProvider).watchTheme().map(
          (settings) => settings.fontScale.factor,
        );
