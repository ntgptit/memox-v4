import 'package:memox_v4/core/theme/mx_spacing.dart';

/// Responsive width breakpoints (logical px), aligned to Material 3 window size
/// classes but tuned for MemoX's phone-first design. The single source of truth
/// for "is this a small / medium / large screen" decisions, so layouts adapt
/// across phones, foldables, tablets and desktop/web instead of stretching a
/// phone layout to fill a wide window (`docs/ui-ux/ui-ux-contract.md`).
enum MxScreenSize {
  /// Phones in portrait, small windows. width < 600.
  compact,

  /// Large phones in landscape, small tablets, foldables. 600–839.
  medium,

  /// Tablets, desktop, web. 840–1199.
  expanded,

  /// Large desktop / TV. ≥ 1200.
  large;

  /// Classify a width into a size class.
  static MxScreenSize fromWidth(double width) {
    if (width < MxBreakpoints.medium) return MxScreenSize.compact;
    if (width < MxBreakpoints.expanded) return MxScreenSize.medium;
    if (width < MxBreakpoints.large) return MxScreenSize.expanded;
    return MxScreenSize.large;
  }

  bool get isCompact => this == MxScreenSize.compact;
  bool get isMedium => this == MxScreenSize.medium;
  bool get isExpanded => this == MxScreenSize.expanded;
  bool get isLarge => this == MxScreenSize.large;

  /// True when this size is [other] or wider (e.g. `size.atLeast(medium)`).
  bool atLeast(MxScreenSize other) => index >= other.index;
}

/// Breakpoint thresholds and the size-dependent layout tokens derived from them.
abstract final class MxBreakpoints {
  const MxBreakpoints._();

  /// Lower bound of [MxScreenSize.medium].
  static const double medium = 600;

  /// Lower bound of [MxScreenSize.expanded].
  static const double expanded = 840;

  /// Lower bound of [MxScreenSize.large].
  static const double large = 1200;

  /// Screen-edge padding for a size class. The phone value is the design token
  /// gutter (20); larger screens breathe more.
  static double gutterOf(MxScreenSize size) => switch (size) {
    MxScreenSize.compact => MxSpacing.gutter, // 20
    MxScreenSize.medium => MxSpacing.space6, // 24
    MxScreenSize.expanded => MxSpacing.space7, // 32
    MxScreenSize.large => MxSpacing.space8, // 40
  };

  /// Max readable content width for a size class — cap so text and forms don't
  /// stretch into unreadable line lengths on wide screens. Compact is
  /// unbounded (fill the phone).
  static double maxContentWidth(MxScreenSize size) => switch (size) {
    MxScreenSize.compact => double.infinity,
    MxScreenSize.medium => 640,
    MxScreenSize.expanded => 840,
    MxScreenSize.large => 1040,
  };
}
