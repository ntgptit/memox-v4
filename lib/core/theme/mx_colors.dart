import 'package:flutter/material.dart';

/// Brand color seed for the Material 3 scheme.
///
/// The light/dark [ColorScheme]s are derived from [seed] via
/// `ColorScheme.fromSeed`. Value mirrors the design token `--memox-primary`
/// in `docs/design/MemoX Design System/tokens/colors.css`. The full token
/// palette is wired in later (personalization, W14) — W1 needs only the seed.
abstract final class MxColors {
  const MxColors._();

  /// Brand primary (refined indigo) — design token `--memox-primary`.
  static const Color seed = Color(0xFF4F46E5);
}
