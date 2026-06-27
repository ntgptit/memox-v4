import 'package:flutter/widgets.dart';

/// Typography tokens, mirroring the frozen tokens in
/// `docs/design/MemoX Design System/tokens/typography.css`
/// (`--memox-font-*`, `--memox-line-height-*`, `--memox-letter-spacing-*`).
///
/// These are the raw type primitives; `app_theme.dart` composes them into the
/// Material [TextTheme] slots that features actually read.
///
/// Letter spacing is stored as an **em multiplier** (the CSS unit). Flutter's
/// `letterSpacing` is logical pixels, so multiply by the slot's font size:
/// `letterSpacing: size * MxTypography.trackingTight`.
abstract final class MxTypography {
  const MxTypography._();

  /// Brand family. The variable font ships at
  /// `docs/design/MemoX Design System/fonts/PlusJakartaSans[wght].ttf`; it is
  /// registered with `pubspec.yaml` when the asset is wired (deferred — not a
  /// W1 blocker, the theme degrades to the platform sans until then).
  static const String fontFamily = 'Plus Jakarta Sans';

  // ── font sizes ─────────────────────────────────────────────────────────────
  static const double sizeXs = 12;
  static const double sizeSm = 13;
  static const double sizeBase = 15;
  static const double sizeMd = 17;
  static const double sizeLg = 20;
  static const double sizeXl = 24;
  static const double size2xl = 30;
  static const double size3xl = 38;
  static const double size4xl = 48;

  // ── weights ────────────────────────────────────────────────────────────────
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extrabold = FontWeight.w800;

  // ── line heights (unitless → Flutter `height`) ─────────────────────────────
  static const double lineHeightNone = 1;
  static const double lineHeightTight = 1.15;
  static const double lineHeightSnug = 1.32;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.7;

  // ── letter spacing (em multipliers — see class doc) ────────────────────────
  static const double trackingTight = -0.02;
  static const double trackingNormal = 0;
  static const double trackingWide = 0.04;
  static const double trackingCaps = 0.08;
}
