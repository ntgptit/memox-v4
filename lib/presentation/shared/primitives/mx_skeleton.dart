import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_motion.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// The kit's `Skeleton` helper as a reusable primitive: a sunken placeholder block
/// that gently pulses while content loads. Token-driven via [MxTheme].
///
/// Width mirrors the kit `Skeleton({ w })`, which is a fraction of the parent
/// (`w="40%"`): pass [widthFactor] (0..1) for a text-line placeholder, or [width]
/// for an absolute square (kit `w={48}`, e.g. an avatar). Omit both to fill the
/// parent. [height]/[radius] size the block. Honours the platform "reduce motion"
/// setting — when animations are disabled the block is shown static (dimmed).
class MxSkeleton extends StatefulWidget {
  const MxSkeleton({
    this.width,
    this.widthFactor,
    this.height = _defaultHeight,
    this.radius = _defaultRadius,
    super.key,
  }) : assert(
          width == null || widthFactor == null,
          'Use width (absolute) or widthFactor (fraction of parent), not both',
        );

  final double? width;

  /// Width as a fraction of the parent (0..1), mirroring the kit `w="X%"`.
  final double? widthFactor;
  final double height;
  final double radius;

  // Kit `Skeleton` defaults (16px tall, 8px radius) — no matching size tokens.
  static const double _defaultHeight = 16;
  static const double _defaultRadius = 8;

  // Kit `.mxg-skel` pulse: opacity .5 ↔ 1 over the `pulse` motion token
  // (1.3s), ease-in-out, infinite.
  static const double _minOpacity = 0.5;
  static const Duration _period = MxDurations.pulse;

  @override
  State<MxSkeleton> createState() => _MxSkeletonState();
}

class _MxSkeletonState extends State<MxSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: MxSkeleton._period)
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: MxSkeleton._minOpacity, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);

    // A decoration-only Container (fills the width/height its parent gives it).
    final bar = Container(
      decoration: BoxDecoration(
        color: mx.surfaceSunken,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );
    // Height always bounds the vertical axis; the width is either a fraction of
    // the parent (kit `w="X%"`) or absolute (kit `w={48}`) or fills the parent.
    final block = SizedBox(
      height: widget.height,
      width: widget.widthFactor == null ? (widget.width ?? double.infinity) : null,
      child: widget.widthFactor == null
          ? bar
          : FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: widget.widthFactor,
              child: bar,
            ),
    );

    if (MediaQuery.of(context).disableAnimations) {
      return Opacity(opacity: MxSkeleton._minOpacity, child: block);
    }
    return FadeTransition(opacity: _opacity, child: block);
  }
}
