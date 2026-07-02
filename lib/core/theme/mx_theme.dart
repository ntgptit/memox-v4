import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_elevation.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';

/// The design roles Material's [ColorScheme] cannot express — surface tiers, the
/// semantic *soft* pairs, text tiers, borders, interaction-state overlays, the
/// focus ring, and the elevation ([MxShadows]) set — carried on [ThemeData] as a
/// [ThemeExtension] so widgets read them with `MxTheme.of(context)` and they lerp
/// on a theme switch.
///
/// Colors come straight from the generated [MxColors] token mirror; the radii are
/// theme-invariant so they are exposed as getters delegating to [MxRadius] rather
/// than lerped fields.
@immutable
class MxTheme extends ThemeExtension<MxTheme> {
  const MxTheme({
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.primarySoft,
    required this.onPrimarySoft,
    required this.accentSoft,
    required this.info,
    required this.onInfo,
    required this.infoSoft,
    required this.onInfoSoft,
    required this.successSoft,
    required this.onSuccessSoft,
    required this.warningSoft,
    required this.onWarningSoft,
    required this.errorSoft,
    required this.onErrorSoft,
    required this.stateHover,
    required this.statePressed,
    required this.stateSelected,
    required this.focusRing,
    required this.overlay,
    required this.shadows,
  });

  /// Builds the extension from a [MxColors] palette + its matching [MxShadows].
  factory MxTheme.fromTokens(MxColors c, MxShadows shadows) => MxTheme(
        surface: c.surface,
        surfaceMuted: c.surfaceMuted,
        surfaceRaised: c.surfaceRaised,
        surfaceSunken: c.surfaceSunken,
        text: c.text,
        textSecondary: c.textSecondary,
        textTertiary: c.textTertiary,
        border: c.border,
        borderStrong: c.borderStrong,
        divider: c.divider,
        primarySoft: c.primarySoft,
        onPrimarySoft: c.onPrimarySoft,
        accentSoft: c.accentSoft,
        info: c.info,
        onInfo: c.onInfo,
        infoSoft: c.infoSoft,
        onInfoSoft: c.onInfoSoft,
        successSoft: c.successSoft,
        onSuccessSoft: c.onSuccessSoft,
        warningSoft: c.warningSoft,
        onWarningSoft: c.onWarningSoft,
        errorSoft: c.errorSoft,
        onErrorSoft: c.onErrorSoft,
        stateHover: c.stateHover,
        statePressed: c.statePressed,
        stateSelected: c.stateSelected,
        focusRing: c.focusRing,
        overlay: c.overlay,
        shadows: shadows,
      );

  // Surface tiers.
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceRaised;
  final Color surfaceSunken;

  // Text tiers.
  final Color text;
  final Color textSecondary;
  final Color textTertiary;

  // Lines.
  final Color border;
  final Color borderStrong;
  final Color divider;

  // Semantic soft pairs (Material only carries the strong roles).
  final Color primarySoft;
  final Color onPrimarySoft;
  final Color accentSoft;
  final Color info;
  final Color onInfo;
  final Color infoSoft;
  final Color onInfoSoft;
  final Color successSoft;
  final Color onSuccessSoft;
  final Color warningSoft;
  final Color onWarningSoft;
  final Color errorSoft;
  final Color onErrorSoft;

  // Interaction-state overlays + focus.
  final Color stateHover;
  final Color statePressed;
  final Color stateSelected;
  final Color focusRing;
  final Color overlay;

  // Elevation set for this brightness.
  final MxShadows shadows;

  // Theme-invariant corner radii (delegated to the token mirror).
  BorderRadius get cardRadius => MxRadius.cardRadius;
  BorderRadius get tileRadius => MxRadius.tileRadius;
  BorderRadius get controlRadius => MxRadius.controlRadius;
  BorderRadius get pillRadius => MxRadius.pillRadius;

  /// The extension off the ambient theme. Present whenever [ThemeData] was built
  /// by `AppTheme`, so the `!` is the intended contract (a missing extension is a
  /// wiring bug that should fail loudly).
  static MxTheme of(BuildContext context) =>
      Theme.of(context).extension<MxTheme>()!;

  @override
  MxTheme copyWith({
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? text,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? borderStrong,
    Color? divider,
    Color? primarySoft,
    Color? onPrimarySoft,
    Color? accentSoft,
    Color? info,
    Color? onInfo,
    Color? infoSoft,
    Color? onInfoSoft,
    Color? successSoft,
    Color? onSuccessSoft,
    Color? warningSoft,
    Color? onWarningSoft,
    Color? errorSoft,
    Color? onErrorSoft,
    Color? stateHover,
    Color? statePressed,
    Color? stateSelected,
    Color? focusRing,
    Color? overlay,
    MxShadows? shadows,
  }) {
    return MxTheme(
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimarySoft: onPrimarySoft ?? this.onPrimarySoft,
      accentSoft: accentSoft ?? this.accentSoft,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoSoft: infoSoft ?? this.infoSoft,
      onInfoSoft: onInfoSoft ?? this.onInfoSoft,
      successSoft: successSoft ?? this.successSoft,
      onSuccessSoft: onSuccessSoft ?? this.onSuccessSoft,
      warningSoft: warningSoft ?? this.warningSoft,
      onWarningSoft: onWarningSoft ?? this.onWarningSoft,
      errorSoft: errorSoft ?? this.errorSoft,
      onErrorSoft: onErrorSoft ?? this.onErrorSoft,
      stateHover: stateHover ?? this.stateHover,
      statePressed: statePressed ?? this.statePressed,
      stateSelected: stateSelected ?? this.stateSelected,
      focusRing: focusRing ?? this.focusRing,
      overlay: overlay ?? this.overlay,
      shadows: shadows ?? this.shadows,
    );
  }

  @override
  MxTheme lerp(covariant MxTheme? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return MxTheme(
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      surfaceSunken: mix(surfaceSunken, other.surfaceSunken),
      text: mix(text, other.text),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      border: mix(border, other.border),
      borderStrong: mix(borderStrong, other.borderStrong),
      divider: mix(divider, other.divider),
      primarySoft: mix(primarySoft, other.primarySoft),
      onPrimarySoft: mix(onPrimarySoft, other.onPrimarySoft),
      accentSoft: mix(accentSoft, other.accentSoft),
      info: mix(info, other.info),
      onInfo: mix(onInfo, other.onInfo),
      infoSoft: mix(infoSoft, other.infoSoft),
      onInfoSoft: mix(onInfoSoft, other.onInfoSoft),
      successSoft: mix(successSoft, other.successSoft),
      onSuccessSoft: mix(onSuccessSoft, other.onSuccessSoft),
      warningSoft: mix(warningSoft, other.warningSoft),
      onWarningSoft: mix(onWarningSoft, other.onWarningSoft),
      errorSoft: mix(errorSoft, other.errorSoft),
      onErrorSoft: mix(onErrorSoft, other.onErrorSoft),
      stateHover: mix(stateHover, other.stateHover),
      statePressed: mix(statePressed, other.statePressed),
      stateSelected: mix(stateSelected, other.stateSelected),
      focusRing: mix(focusRing, other.focusRing),
      overlay: mix(overlay, other.overlay),
      // MxShadows is a discrete set — snap at the midpoint rather than blend.
      shadows: t < 0.5 ? shadows : other.shadows,
    );
  }
}
