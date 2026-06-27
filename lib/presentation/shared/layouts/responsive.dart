import 'package:flutter/widgets.dart';
import 'package:memox_v4/core/theme/mx_breakpoints.dart';

/// Ergonomic responsive reads off the active window size. Use for screen-level
/// decisions (which layout, how wide a gutter); for component-level adaptivity
/// driven by local constraints, prefer [MxResponsiveBuilder].
extension MxResponsiveContext on BuildContext {
  /// Size class of the current window.
  MxScreenSize get mxScreenSize =>
      MxScreenSize.fromWidth(MediaQuery.sizeOf(this).width);

  bool get isCompactScreen => mxScreenSize.isCompact;

  /// Screen-edge gutter for the current size class.
  double get screenGutter => MxBreakpoints.gutterOf(mxScreenSize);

  /// Pick a value by current size class, falling back to the nearest smaller
  /// one provided — so callers only specify what differs from [compact].
  T responsive<T>({required T compact, T? medium, T? expanded, T? large}) =>
      switch (mxScreenSize) {
        MxScreenSize.compact => compact,
        MxScreenSize.medium => medium ?? compact,
        MxScreenSize.expanded => expanded ?? medium ?? compact,
        MxScreenSize.large => large ?? expanded ?? medium ?? compact,
      };
}

/// Rebuilds against the size class derived from the **local** constraints
/// (LayoutBuilder), so a widget adapts to the box it's placed in — e.g. a panel
/// inside a split view reads as `compact` even on a wide screen.
class MxResponsiveBuilder extends StatelessWidget {
  const MxResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, MxScreenSize size) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      return builder(context, MxScreenSize.fromWidth(width));
    },
  );
}

/// Centers [child] and caps it at the size class's readable max width, with the
/// size-appropriate gutter. The standard wrapper for page content so screens
/// stay readable from small phones to wide desktops.
class MxContentBounds extends StatelessWidget {
  const MxContentBounds({
    super.key,
    required this.child,
    this.applyGutter = true,
  });

  final Widget child;

  /// Whether to add horizontal screen gutter padding (off when the caller
  /// already pads, e.g. a list that bleeds to the edge).
  final bool applyGutter;

  @override
  Widget build(BuildContext context) {
    final size = context.mxScreenSize;
    final gutter = applyGutter ? MxBreakpoints.gutterOf(size) : 0.0;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MxBreakpoints.maxContentWidth(size),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: child,
        ),
      ),
    );
  }
}
