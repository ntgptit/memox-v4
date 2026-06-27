import 'package:flutter/widgets.dart';

/// Semantic color palette for one brightness, mirroring the frozen design
/// tokens in `docs/design/MemoX Design System/tokens/colors.css`
/// (`--memox-<role>`). One [MxColors] instance per theme: [light] and [dark].
///
/// Features must read colors from the theme — never raw `Color(0x...)` values
/// (`docs/ui-ux/ui-ux-contract.md`). The roles Material's [ColorScheme] cannot
/// express (semantic success/warning/info, soft containers, surface tiers,
/// interaction overlays) are surfaced via the `MxTheme` extension; the rest
/// seed the [ColorScheme] in `app_theme.dart`.
///
/// Token VALUES are the design kit's contract. This file is the downstream
/// Flutter consumer of that CSS; keep the two in sync when a token changes.
@immutable
class MxColors {
  const MxColors({
    required this.bg,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.primary,
    required this.primaryStrong,
    required this.onPrimary,
    required this.primarySoft,
    required this.onPrimarySoft,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.success,
    required this.onSuccess,
    required this.successSoft,
    required this.onSuccessSoft,
    required this.warning,
    required this.onWarning,
    required this.warningSoft,
    required this.onWarningSoft,
    required this.error,
    required this.onError,
    required this.errorSoft,
    required this.onErrorSoft,
    required this.info,
    required this.onInfo,
    required this.infoSoft,
    required this.onInfoSoft,
    required this.stateHover,
    required this.statePressed,
    required this.stateSelected,
    required this.stateDisabled,
    required this.focusRing,
    required this.overlay,
    required this.scrim,
  });

  // canvas & surfaces
  final Color bg;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceRaised;
  final Color surfaceSunken;

  // text
  final Color text;
  final Color textSecondary;
  final Color textTertiary;

  // primary (brand)
  final Color primary;
  final Color primaryStrong;
  final Color onPrimary;
  final Color primarySoft;
  final Color onPrimarySoft;

  // accent
  final Color accent;
  final Color onAccent;
  final Color accentSoft;

  // structural
  final Color border;
  final Color borderStrong;
  final Color divider;

  // semantic: success
  final Color success;
  final Color onSuccess;
  final Color successSoft;
  final Color onSuccessSoft;

  // semantic: warning
  final Color warning;
  final Color onWarning;
  final Color warningSoft;
  final Color onWarningSoft;

  // semantic: error
  final Color error;
  final Color onError;
  final Color errorSoft;
  final Color onErrorSoft;

  // semantic: info
  final Color info;
  final Color onInfo;
  final Color infoSoft;
  final Color onInfoSoft;

  // interaction states
  final Color stateHover;
  final Color statePressed;
  final Color stateSelected;
  final Color stateDisabled;
  final Color focusRing;
  final Color overlay;
  final Color scrim;

  /// Brand primary seed (`--memox-primary`, light). The Material scheme is
  /// anchored on this hue; also the default personalization accent (W13).
  static const Color seed = Color(0xFF4F46E5);

  /// Selectable accent hues offered by the Theme picker (W13). Theme-
  /// independent absolute values (`--memox-palette-*`).
  static const Color paletteIndigo = Color(0xFF5569FF);
  static const Color paletteViolet = Color(0xFF7C5CFF);
  static const Color paletteGreen = Color(0xFF2BB673);
  static const Color paletteCoral = Color(0xFFFF6B6B);
  static const Color paletteAmber = Color(0xFFFF9F43);
  static const Color paletteCyan = Color(0xFF22A3C3);

  /// Light palette — `tokens/colors.css` `:root` / `[data-theme='light']`.
  static const MxColors light = MxColors(
    bg: Color(0xFFF3F4FB),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFECEDF8),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFE3E5F4),
    text: Color(0xFF1D2240),
    textSecondary: Color(0x9E1D2240),
    textTertiary: Color(0x661D2240),
    primary: Color(0xFF4F46E5),
    primaryStrong: Color(0xFF3F37C4),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE6E6FB),
    onPrimarySoft: Color(0xFF382FB4),
    accent: Color(0xFF1FA9D6),
    onAccent: Color(0xFF04303F),
    accentSoft: Color(0xFFDDF2FA),
    border: Color(0xFFE4E4F2),
    borderStrong: Color(0xFFCCCCE8),
    divider: Color(0x141D2240),
    success: Color(0xFF2FAA46),
    onSuccess: Color(0xFFFFFFFF),
    successSoft: Color(0xFFE0F4E2),
    onSuccessSoft: Color(0xFF1F7A33),
    warning: Color(0xFFF5920B),
    onWarning: Color(0xFF3A2200),
    warningSoft: Color(0xFFFDECCA),
    onWarningSoft: Color(0xFF93570A),
    error: Color(0xFFEF2950),
    onError: Color(0xFFFFFFFF),
    errorSoft: Color(0xFFFCE0E5),
    onErrorSoft: Color(0xFFC20F32),
    info: Color(0xFF1FA9D6),
    onInfo: Color(0xFFFFFFFF),
    infoSoft: Color(0xFFDDF2FA),
    onInfoSoft: Color(0xFF0A6F93),
    stateHover: Color(0x0B1D2240),
    statePressed: Color(0x171D2240),
    stateSelected: Color(0x1A4F46E5),
    stateDisabled: Color(0x421D2240),
    focusRing: Color(0x6B4F46E5),
    overlay: Color(0x7312142D),
    scrim: Color(0x0A1D2240),
  );

  /// Dark palette — `tokens/colors.css` `[data-theme='dark']`.
  static const MxColors dark = MxColors(
    bg: Color(0xFF0A0C1E),
    surface: Color(0xFF181C34),
    surfaceMuted: Color(0xFF14182F),
    surfaceRaised: Color(0xFF242A47),
    surfaceSunken: Color(0xFF070817),
    text: Color(0xFFECEDF7),
    textSecondary: Color(0xFFA7ABC6),
    textTertiary: Color(0x8CA7ABC6),
    primary: Color(0xFF4B42B8),
    primaryStrong: Color(0xFF7D74F0),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFF232452),
    onPrimarySoft: Color(0xFFC7C4F8),
    accent: Color(0xFF33C2FF),
    onAccent: Color(0xFF8FDCFB),
    accentSoft: Color(0xFF123544),
    border: Color(0xFF2B3052),
    borderStrong: Color(0xFF3C4068),
    divider: Color(0x14FFFFFF),
    success: Color(0xFF57CA22),
    onSuccess: Color(0xFF06320F),
    successSoft: Color(0xFF173620),
    onSuccessSoft: Color(0xFF8EE06A),
    warning: Color(0xFFFFA319),
    onWarning: Color(0xFF2A1A00),
    warningSoft: Color(0xFF382909),
    onWarningSoft: Color(0xFFFFC25C),
    error: Color(0xFFFF1943),
    onError: Color(0xFFFFFFFF),
    errorSoft: Color(0xFF3B1622),
    onErrorSoft: Color(0xFFFF8A9C),
    info: Color(0xFF33C2FF),
    onInfo: Color(0xFF8FDCFB),
    infoSoft: Color(0xFF123544),
    onInfoSoft: Color(0xFF82D6FB),
    stateHover: Color(0x0FFFFFFF),
    statePressed: Color(0x1CFFFFFF),
    stateSelected: Color(0x3D7D74F0),
    stateDisabled: Color(0x42ECEDF7),
    focusRing: Color(0x997D74F0),
    overlay: Color(0xA8000000),
    scrim: Color(0x0AFFFFFF),
  );
}
