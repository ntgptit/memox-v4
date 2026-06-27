import 'package:flutter/widgets.dart';

/// Elevation / shadow tokens, mirroring the frozen tokens in
/// `docs/design/MemoX Design System/tokens/elevation.css`
/// (`--memox-shadow-*`).
///
/// Theme-dependent: soft blue-grey casts in light, crisp hairline + deep
/// ambient in dark. One [MxShadows] instance per brightness ([light]/[dark]);
/// surfaces read them through the `MxTheme` extension rather than hardcoding
/// `BoxShadow`s. The 4-value CSS rings (`0 0 0 1px`) map to a zero-blur shadow
/// with `spreadRadius: 1`.
@immutable
class MxShadows {
  const MxShadows({
    required this.sm,
    required this.card,
    required this.lg,
    required this.fab,
    required this.nav,
  });

  final List<BoxShadow> sm;
  final List<BoxShadow> card;
  final List<BoxShadow> lg;
  final List<BoxShadow> fab;

  /// Bottom-nav bar — casts upward (negative dy).
  final List<BoxShadow> nav;

  static const MxShadows light = MxShadows(
    sm: [
      BoxShadow(color: Color(0x2E787CB2), offset: Offset(0, 2), blurRadius: 3),
      BoxShadow(color: Color(0x4D787CB2), offset: Offset(0, 1), blurRadius: 1),
    ],
    card: [
      BoxShadow(color: Color(0x2E787CB2), offset: Offset(0, 9), blurRadius: 16),
      BoxShadow(color: Color(0x47787CB2), offset: Offset(0, 2), blurRadius: 2),
    ],
    lg: [
      BoxShadow(
        color: Color(0x2E4F46E5),
        offset: Offset(0, 18),
        blurRadius: 40,
      ),
      BoxShadow(color: Color(0x3D787CB2), offset: Offset(0, 4), blurRadius: 8),
    ],
    fab: [
      BoxShadow(color: Color(0x614F46E5), offset: Offset(0, 8), blurRadius: 18),
    ],
    nav: [
      BoxShadow(
        color: Color(0x33787CB2),
        offset: Offset(0, -2),
        blurRadius: 14,
      ),
    ],
  );

  static const MxShadows dark = MxShadows(
    sm: [BoxShadow(color: Color(0xFF2B3052), spreadRadius: 1)],
    card: [
      BoxShadow(color: Color(0x73000000), offset: Offset(0, 2), blurRadius: 8),
      BoxShadow(color: Color(0xFF2B3052), spreadRadius: 1),
    ],
    lg: [
      BoxShadow(
        color: Color(0x99000000),
        offset: Offset(0, 20),
        blurRadius: 48,
      ),
      BoxShadow(color: Color(0xFF2B3052), spreadRadius: 1),
    ],
    fab: [
      BoxShadow(color: Color(0x4D574ED6), offset: Offset(0, 6), blurRadius: 16),
    ],
    nav: [
      BoxShadow(
        color: Color(0x8C000000),
        offset: Offset(0, -2),
        blurRadius: 16,
      ),
      BoxShadow(color: Color(0xFF2B3052), offset: Offset(0, -1)),
    ],
  );
}
