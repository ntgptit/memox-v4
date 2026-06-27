import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';

/// Material 3 light/dark themes derived from a single brand [MxColors.seed].
///
/// Features must read color/typography from the theme — no raw values in UI
/// (`docs/ui-ux/ui-ux-contract.md`).
abstract final class AppTheme {
  const AppTheme._();

  /// Light theme.
  static ThemeData light() => _themeFor(Brightness.light);

  /// Dark theme.
  static ThemeData dark() => _themeFor(Brightness.dark);

  static ThemeData _themeFor(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MxColors.seed,
        brightness: brightness,
      ),
    );
  }
}
