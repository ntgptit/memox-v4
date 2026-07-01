import 'package:flutter/animation.dart';

/// Motion scale — durations + easing curves — mirroring the frozen tokens in
/// `docs/design/MemoX Design System/tokens/motion.css` (`--memox-duration-*`,
/// `--memox-ease-*`).
///
/// Theme-independent: timings do not change between light and dark. Durations
/// scale with the size of the moving surface; easings follow the standard /
/// enter ([decelerate]) / exit ([accelerate]) split. Animated widgets read
/// these instead of hardcoding `Duration`s or `Curve`s.
abstract final class MxMotion {
  const MxMotion._();

  // durations — scale up with the size of the moving surface
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);

  // easings (control points mirror the cubic-bezier() tokens)
  static const Cubic standard = Cubic(0.2, 0, 0, 1);
  static const Cubic decelerate = Cubic(0, 0, 0, 1); // enter
  static const Cubic accelerate = Cubic(0.3, 0, 1, 1); // exit
}
