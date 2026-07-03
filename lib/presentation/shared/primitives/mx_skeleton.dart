import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// The kit's `Skeleton` helper as a reusable primitive: a sunken placeholder block
/// that gently pulses while content loads. Token-driven via [MxTheme].
///
/// [width] defaults to filling the parent; [height]/[radius] size the block.
/// Honours the platform "reduce motion" setting — when animations are disabled the
/// block is shown static (dimmed) instead of pulsing.
class MxSkeleton extends StatefulWidget {
  const MxSkeleton({
    this.width,
    this.height = _defaultHeight,
    this.radius = _defaultRadius,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  // Kit `Skeleton` defaults (16px tall, 8px radius) — no matching size tokens.
  static const double _defaultHeight = 16;
  static const double _defaultRadius = 8;

  // Kit `.mxg-skel` pulse: opacity .5 ↔ 1 over 1.3s, ease-in-out, infinite.
  static const double _minOpacity = 0.5;
  static const Duration _period = Duration(milliseconds: 1300);

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

    final block = Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: mx.surfaceSunken,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );

    if (MediaQuery.of(context).disableAnimations) {
      return Opacity(opacity: MxSkeleton._minOpacity, child: block);
    }
    return FadeTransition(opacity: _opacity, child: block);
  }
}
