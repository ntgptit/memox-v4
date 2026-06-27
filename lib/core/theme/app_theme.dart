import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_elevation.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Material 3 light/dark themes composed from the design tokens.
///
/// The [ColorScheme] is anchored on the brand hue and overridden with the
/// explicit [MxColors] roles; the [TextTheme] is built from [MxTypography]; the
/// semantic tokens Material can't hold (success/warning/info, shadows, surface
/// tiers) ride along in the `MxTheme` extension. Features read color/typography
/// from the theme — no raw values in UI (`docs/ui-ux/ui-ux-contract.md`).
abstract final class AppTheme {
  const AppTheme._();

  /// Light theme.
  static ThemeData light() =>
      _build(Brightness.light, MxColors.light, MxShadows.light);

  /// Dark theme.
  static ThemeData dark() =>
      _build(Brightness.dark, MxColors.dark, MxShadows.dark);

  static ThemeData _build(
    Brightness brightness,
    MxColors c,
    MxShadows shadows,
  ) {
    final scheme = _scheme(brightness, c);
    final text = _textTheme(c.text);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      // Denser, mouse-friendly metrics on desktop/web; touch metrics on mobile.
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      dividerColor: c.divider,
      textTheme: text,
      fontFamily: MxTypography.fontFamily,
      extensions: <ThemeExtension<dynamic>>[
        MxTheme(colors: c, shadows: shadows),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: MxRadius.cardRadius),
      ),
      dividerTheme: DividerThemeData(
        color: c.divider,
        thickness: MxStroke.hairline,
        space: MxSpacing.space4,
      ),
      filledButtonTheme: FilledButtonThemeData(style: _pillButton(text)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _pillButton(
          text,
        ).copyWith(elevation: const WidgetStatePropertyAll<double>(0)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _pillButton(text).copyWith(
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: c.borderStrong),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: text.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: MxRadius.pillRadius,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MxSpacing.space4,
          vertical: MxSpacing.space3,
        ),
        border: OutlineInputBorder(
          borderRadius: MxRadius.fieldRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: MxRadius.fieldRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: MxRadius.fieldRadius,
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceMuted,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: text.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(MxRadius.xl)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MxRadius.xl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(MxRadius.md)),
        ),
      ),
    );
  }

  // ── ColorScheme: seed for full M3 coverage, brand tokens for key roles ──────
  static ColorScheme _scheme(Brightness brightness, MxColors c) {
    return ColorScheme.fromSeed(
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
      tertiary: c.info,
      onTertiary: c.onInfo,
      error: c.error,
      onError: c.onError,
      errorContainer: c.errorSoft,
      onErrorContainer: c.onErrorSoft,
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.textSecondary,
      outline: c.borderStrong,
      outlineVariant: c.border,
      scrim: c.overlay,
      surfaceTint: c.primary,
    );
  }

  // ── TextTheme from the type scale ───────────────────────────────────────────
  static TextTheme _textTheme(Color onSurface) {
    TextStyle s(
      double size,
      FontWeight weight,
      double lineHeight,
      double tracking,
    ) {
      return TextStyle(
        fontFamily: MxTypography.fontFamily,
        fontSize: size,
        fontWeight: weight,
        height: lineHeight,
        letterSpacing: size * tracking,
        color: onSurface,
      );
    }

    return TextTheme(
      displayLarge: s(
        MxTypography.size4xl,
        MxTypography.extrabold,
        MxTypography.lineHeightTight,
        MxTypography.trackingTight,
      ),
      displayMedium: s(
        MxTypography.size3xl,
        MxTypography.extrabold,
        MxTypography.lineHeightTight,
        MxTypography.trackingTight,
      ),
      displaySmall: s(
        MxTypography.size2xl,
        MxTypography.bold,
        MxTypography.lineHeightSnug,
        MxTypography.trackingTight,
      ),
      headlineLarge: s(
        MxTypography.size2xl,
        MxTypography.bold,
        MxTypography.lineHeightSnug,
        MxTypography.trackingTight,
      ),
      headlineMedium: s(
        MxTypography.sizeXl,
        MxTypography.bold,
        MxTypography.lineHeightSnug,
        MxTypography.trackingTight,
      ),
      headlineSmall: s(
        MxTypography.sizeLg,
        MxTypography.semibold,
        MxTypography.lineHeightSnug,
        MxTypography.trackingNormal,
      ),
      titleLarge: s(
        MxTypography.sizeMd,
        MxTypography.semibold,
        MxTypography.lineHeightSnug,
        MxTypography.trackingNormal,
      ),
      titleMedium: s(
        MxTypography.sizeBase,
        MxTypography.semibold,
        MxTypography.lineHeightNormal,
        MxTypography.trackingNormal,
      ),
      titleSmall: s(
        MxTypography.sizeSm,
        MxTypography.semibold,
        MxTypography.lineHeightNormal,
        MxTypography.trackingNormal,
      ),
      bodyLarge: s(
        MxTypography.sizeMd,
        MxTypography.regular,
        MxTypography.lineHeightNormal,
        MxTypography.trackingNormal,
      ),
      bodyMedium: s(
        MxTypography.sizeBase,
        MxTypography.regular,
        MxTypography.lineHeightNormal,
        MxTypography.trackingNormal,
      ),
      bodySmall: s(
        MxTypography.sizeSm,
        MxTypography.regular,
        MxTypography.lineHeightNormal,
        MxTypography.trackingNormal,
      ),
      labelLarge: s(
        MxTypography.sizeBase,
        MxTypography.semibold,
        MxTypography.lineHeightNone,
        MxTypography.trackingNormal,
      ),
      labelMedium: s(
        MxTypography.sizeSm,
        MxTypography.medium,
        MxTypography.lineHeightNone,
        MxTypography.trackingWide,
      ),
      labelSmall: s(
        MxTypography.sizeXs,
        MxTypography.semibold,
        MxTypography.lineHeightNone,
        MxTypography.trackingCaps,
      ),
    );
  }

  // ── shared button shape (pill + token padding + min touch target) ───────────
  static ButtonStyle _pillButton(TextTheme text) {
    return ButtonStyle(
      textStyle: WidgetStatePropertyAll<TextStyle?>(text.labelLarge),
      padding: const WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(
          horizontal: MxSpacing.space6,
          vertical: MxSpacing.space3,
        ),
      ),
      minimumSize: const WidgetStatePropertyAll<Size>(
        Size(0, MxSpacing.minTouchTarget),
      ),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: MxRadius.pillRadius),
      ),
    );
  }
}
