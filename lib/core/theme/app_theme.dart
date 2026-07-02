import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_elevation.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Assembles the app's [ThemeData] for each brightness from the generated design
/// tokens: a seeded Material [ColorScheme] overridden with the exact token colors,
/// the per-component themes (T.3) so stock widgets inherit the kit look, plus the
/// [MxTheme] extension for the roles Material can't express. The single seam where
/// tokens become the running theme — no widget hardcodes a color.
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
      filledButtonTheme: FilledButtonThemeData(style: _buttonStyle(c.primary, c.onPrimary, c)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _buttonStyle(c.surfaceRaised, c.text, c)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(Colors.transparent, c.primary, c).copyWith(
          side: WidgetStatePropertyAll(BorderSide(color: c.border, width: MxStroke.hairline)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: _buttonStyle(Colors.transparent, c.primary, c)),
      cardTheme: CardThemeData(
        color: c.surfaceRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: MxRadius.cardRadius),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: c.text,
          fontFamily: MxTypography.fontFamily,
          fontSize: MxTypography.sizeLg,
          fontWeight: MxTypography.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primarySoft,
        height: MxSpacing.bottomNavHeight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: MxIconSize.md,
            color: states.contains(WidgetState.selected) ? c.primary : c.textTertiary,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceMuted,
        side: BorderSide(color: c.border, width: MxStroke.hairline),
        shape: const RoundedRectangleBorder(borderRadius: MxRadius.pillRadius),
        labelStyle: TextStyle(color: c.text, fontSize: MxTypography.sizeSm),
        padding: const EdgeInsets.symmetric(
          horizontal: MxSpacing.space3,
          vertical: MxSpacing.space1,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.onPrimary : c.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.primary : c.surfaceSunken,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? Colors.transparent : c.border,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(MxRadius.xl)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceMuted,
        hintStyle: TextStyle(color: c.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MxSpacing.space4,
          vertical: MxSpacing.space3,
        ),
        border: _inputBorder(c.border, MxStroke.hairline),
        enabledBorder: _inputBorder(c.border, MxStroke.hairline),
        focusedBorder: _inputBorder(c.focusRing, MxStroke.emphasis),
        errorBorder: _inputBorder(c.error, MxStroke.hairline),
        focusedErrorBorder: _inputBorder(c.error, MxStroke.emphasis),
      ),
      extensions: [MxTheme.fromTokens(c, shadows)],
    );
  }

  /// Shared button shape/size/padding with a token-driven fill + label color.
  static ButtonStyle _buttonStyle(Color background, Color foreground, MxColors c) {
    return FilledButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: c.surfaceSunken,
      disabledForegroundColor: c.textTertiary,
      elevation: 0,
      minimumSize: const Size(MxSpacing.minTouchTarget, MxSpacing.minTouchTarget),
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.space5,
        vertical: MxSpacing.space3,
      ),
      shape: const RoundedRectangleBorder(borderRadius: MxRadius.controlRadius),
      textStyle: const TextStyle(
        fontFamily: MxTypography.fontFamily,
        fontSize: MxTypography.sizeBase,
        fontWeight: MxTypography.semibold,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: MxRadius.controlRadius,
        borderSide: BorderSide(color: color, width: width),
      );
}
