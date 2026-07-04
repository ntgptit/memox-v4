import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// One option of an [MxSegmentedControl].
class MxSegment {
  const MxSegment({required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;
}

/// The kit's segmented control for 2–3 mutually-exclusive views (`MxSegmentedControl`
/// · base class `.segmented`). A primitive, token-driven via [MxTheme]. It is a
/// radio group: each segment is individually addressable with radio semantics
/// (`inMutuallyExclusiveGroup` + `selected`); the active segment lifts onto a
/// surface pill. [block] stretches the segments to fill the width. Segment labels
/// are supplied by the caller (from ARB).
class MxSegmentedControl extends StatelessWidget {
  const MxSegmentedControl({
    required this.segments,
    required this.value,
    this.onChanged,
    this.block = false,
    super.key,
  });

  final List<MxSegment> segments;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool block;

  /// Kit `.segmented__seg` min-height — raw px with no matching token.
  static const double _segmentMinHeight = 38;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);

    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(MxSpacing.space1),
        decoration: BoxDecoration(
          color: mx.surfaceMuted,
          borderRadius: MxRadius.pillRadius,
        ),
        child: Row(
          mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (var i = 0; i < segments.length; i++) ...[
              block ? Expanded(child: _tile(i)) : _tile(i),
              if (i < segments.length - 1)
                const SizedBox(width: MxSpacing.space1),
            ],
          ],
        ),
      ),
    );
  }

  /// One segment tile. [onChanged] is copied to a local so the null-check
  /// promotes for the tap closure (a field would not).
  Widget _tile(int i) {
    final segment = segments[i];
    final changed = onChanged;
    return _Segment(
      segment: segment,
      active: segment.value == value,
      onTap: changed == null ? null : () => changed(segment.value),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.segment, required this.active, this.onTap});

  final MxSegment segment;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final foreground = active ? mx.primaryStrong : mx.textSecondary;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: active,
      button: true,
      label: segment.label,
      child: Material(
        color: active ? mx.surface : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: MxSegmentedControl._segmentMinHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (segment.icon != null) ...[
                    Icon(segment.icon, size: MxIconSize.sm, color: foreground),
                    const SizedBox(width: MxSpacing.space2),
                  ],
                  Text(
                    segment.label,
                    style: TextStyle(
                      fontFamily: MxTypography.fontFamily,
                      fontSize: MxTypography.sizeSm,
                      fontWeight: MxTypography.semibold,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
