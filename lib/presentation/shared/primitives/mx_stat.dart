import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_component.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Size of an [MxStat] figure (kit `Stat` helper: `md` default, `lg` hero).
enum MxStatSize { medium, large }

/// The kit's `Stat` helper: THE big-figure-over-small-label block (K.3 — no
/// inline copies). [onTint] = on a colored card (label inherits the card
/// foreground at label opacity instead of text-secondary); [alignStart] for
/// left-aligned hero figures; [tone] tints the figure. Copy is from ARB.
class MxStat extends StatelessWidget {
  const MxStat({
    required this.value,
    required this.label,
    this.size = MxStatSize.medium,
    this.alignStart = false,
    this.onTint = false,
    this.tone,
    super.key,
  });

  final String value;
  final String label;
  final MxStatSize size;
  final bool alignStart;
  final bool onTint;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final large = size == MxStatSize.large;

    final figure = Text(
      value,
      style: TextStyle(
        fontFamily: MxTypography.fontFamily,
        fontSize: large ? MxTypography.size2xl : MxIconSize.md,
        fontWeight: MxTypography.extrabold,
        height: large ? null : MxTypography.lineHeightNone,
        color: tone,
      ),
    );
    final caption = Text(
      label,
      style: TextStyle(
        fontFamily: MxTypography.fontFamily,
        fontSize: large ? MxTypography.sizeSm : MxTypography.sizeXs,
        color: onTint ? null : mx.textSecondary,
      ),
    );

    return Column(
      crossAxisAlignment:
          alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        figure,
        const SizedBox(height: MxSpacing.space1),
        if (onTint) Opacity(opacity: MxOpacity.label, child: caption) else caption,
      ],
    );
  }
}
