import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// One option in an [MxSegmentedControl].
typedef MxSegment = ({String value, String label, IconData? icon});

/// A pill-track multiple choice — the design kit's `MxSegmentedControl`.
///
/// Purpose:
/// A compact 2–4 option selector on a single track (e.g. scope toggles).
///
/// Use when:
/// Switching between a small set of mutually exclusive views.
///
/// Do not use when:
/// There are many options (use a dropdown) or a binary on/off (use MxSwitch).
///
/// Category:
/// input
///
/// Public API:
/// - segments: the option list (value + label + optional icon)
/// - value: the selected value
/// - onChanged: selection callback
/// - block: stretch segments to fill the width
///
/// States:
/// default, selected
class MxSegmentedControl extends StatelessWidget {
  const MxSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
    this.block = true,
  });

  final List<MxSegment> segments;
  final String value;
  final ValueChanged<String> onChanged;
  final bool block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(MxSpacing.space1),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: MxRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
        children: <Widget>[
          for (final segment in segments)
            _Segment(
              segment: segment,
              selected: segment.value == value,
              block: block,
              onTap: () => onChanged(segment.value),
              selectedColor: colors.surfaceRaised,
              selectedText: colors.primary,
              unselectedText: colors.textSecondary,
              textStyle: theme.textTheme.labelMedium,
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.selected,
    required this.block,
    required this.onTap,
    required this.selectedColor,
    required this.selectedText,
    required this.unselectedText,
    required this.textStyle,
  });

  final MxSegment segment;
  final bool selected;
  final bool block;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedText;
  final Color unselectedText;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? selectedText : unselectedText;
    final tile = Material(
      color: selected ? selectedColor : Colors.transparent,
      borderRadius: MxRadius.pillRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: MxRadius.pillRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.space3,
            vertical: MxSpacing.space2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (segment.icon case final i?) ...<Widget>[
                Icon(i, size: MxSpacing.space4, color: fg),
                const SizedBox(width: MxSpacing.space1),
              ],
              Text(segment.label, style: textStyle?.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
    return block ? Expanded(child: tile) : tile;
  }
}
