import 'package:flutter/widgets.dart';

/// Corner-radius scale + role aliases, mirroring the frozen tokens in
/// `docs/design/MemoX Design System/tokens/radius.css` (`--memox-radius-*`).
///
/// Raw `double` steps plus ready [BorderRadius] for the common roles, so
/// surfaces never hardcode corner values.
abstract final class MxRadius {
  const MxRadius._();

  // scale
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 28; // --memox-radius-2xl

  // role aliases
  static const double card = 20;
  static const double tile = 16;
  static const double control = 12;
  static const double field = 14;

  /// Fully rounded (chips, pills) — large enough to clamp to a stadium.
  static const double pill = 999;
  static const double full = 9999;

  // ── BorderRadius helpers (common roles) ────────────────────────────────────
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius tileRadius = BorderRadius.all(
    Radius.circular(tile),
  );
  static const BorderRadius controlRadius = BorderRadius.all(
    Radius.circular(control),
  );
  static const BorderRadius fieldRadius = BorderRadius.all(
    Radius.circular(field),
  );
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(pill),
  );
}
