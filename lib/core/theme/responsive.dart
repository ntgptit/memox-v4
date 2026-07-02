import 'package:flutter/widgets.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';

/// Centralized adaptive sizing — the single place layout adapts to window width,
/// so features never reach for ad-hoc `MediaQuery` breakpoint hacks. MemoX is
/// phone-first (see [MxSpacing]: gutter 20, app bar 64/112, bottom nav 72);
/// larger form factors only widen the gutter and cap content width for
/// readability.

/// Window-width breakpoints (Material 3 window size classes).
abstract final class Breakpoints {
  /// Below this width is [FormFactor.compact] (a phone in portrait).
  static const double compactMax = 600;

  /// Below this width (and ≥ [compactMax]) is [FormFactor.medium].
  static const double mediumMax = 840;

  /// Body content never grows past this for line-length readability; on wider
  /// windows it is centered with the surplus as margin.
  static const double maxContentWidth = 480;
}

/// The window size class the app currently renders at.
enum FormFactor {
  compact,
  medium,
  expanded;

  /// Classifies a window [width] into a form factor.
  static FormFactor fromWidth(double width) {
    if (width < Breakpoints.compactMax) return FormFactor.compact;
    if (width < Breakpoints.mediumMax) return FormFactor.medium;
    return FormFactor.expanded;
  }

  bool get isCompact => this == FormFactor.compact;
  bool get isMedium => this == FormFactor.medium;
  bool get isExpanded => this == FormFactor.expanded;
}

/// Adaptive layout values keyed off [FormFactor]. All sizes come from the spacing
/// tokens — no magic numbers.
abstract final class Responsive {
  /// The page gutter (horizontal padding) for a form factor. Phone-first: the
  /// token gutter on compact, widening on larger windows.
  static double gutterFor(FormFactor factor) => switch (factor) {
        FormFactor.compact => MxSpacing.gutter,
        FormFactor.medium => MxSpacing.space7,
        FormFactor.expanded => MxSpacing.space8,
      };
}

/// Ergonomic access to the responsive foundation from a [BuildContext].
extension ResponsiveContext on BuildContext {
  /// The current form factor from the ambient window width.
  FormFactor get formFactor =>
      FormFactor.fromWidth(MediaQuery.sizeOf(this).width);

  bool get isCompact => formFactor.isCompact;
  bool get isExpanded => formFactor.isExpanded;

  /// The adaptive page gutter for the current form factor.
  double get gutter => Responsive.gutterFor(formFactor);
}
