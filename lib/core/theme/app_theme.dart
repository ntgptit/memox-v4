import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_elevation.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Assembles the app's [ThemeData] for each brightness from the generated design
/// tokens: a seeded Material [ColorScheme] overridden with the exact token colors,
/// plus the [MxTheme] extension for the roles Material can't express. This is the
/// single seam where tokens become the running theme — no widget hardcodes a color.
abstract final class AppTheme {
  static ThemeData get light =>
      _build(MxColors.light, MxShadows.light, Brightness.light);

  static ThemeData get dark =>
      _build(MxColors.dark, MxShadows.dark, Brightness.dark);

  static ThemeData _build(MxColors c, MxShadows shadows, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: MxColors.seed,
      brightness: brightness,
    ).copyWith(
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primarySoft,
      onPrimaryContainer: c.onPrimarySoft,
      secondary: c.accent,
      onSecondary: c.onAccent,
      secondaryContainer: c.accentSoft,
      error: c.error,
      onError: c.onError,
      errorContainer: c.errorSoft,
      onErrorContainer: c.onErrorSoft,
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      outlineVariant: c.divider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      fontFamily: MxTypography.fontFamily,
      textTheme: const TextTheme().apply(
        bodyColor: c.text,
        displayColor: c.text,
      ),
      extensions: [MxTheme.fromTokens(c, shadows)],
    );
  }
}
