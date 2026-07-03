import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';

/// The kit's `ListRow` helper as a reusable composite: an optional leading icon
/// tile, a title (+ optional subtitle), and an optional trailing widget, with a
/// hairline divider below unless [last]. Token-driven via [MxTheme]; composes
/// [MxIconTile]. [muted] dims the row; [onPressed] makes it an accessible button.
/// Copy is supplied by the caller (from ARB).
class MxListRow extends StatelessWidget {
  const MxListRow({
    required this.title,
    this.icon,
    this.tone = MxIconTileTone.primary,
    this.subtitle,
    this.trailing,
    this.last = false,
    this.muted = false,
    this.onPressed,
    super.key,
  });

  final String title;
  final IconData? icon;
  final MxIconTileTone tone;
  final String? subtitle;
  final Widget? trailing;
  final bool last;
  final bool muted;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget row = Row(
      spacing: MxSpacing.space4,
      children: [
        if (icon != null) MxIconTile(icon: icon!, tone: tone),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeBase,
                  fontWeight: MxTypography.bold,
                  color: scheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: MxSpacing.space1),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeSm,
                    color: mx.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );

    if (muted) row = Opacity(opacity: 0.55, child: row);
    if (onPressed != null) {
      row = Semantics(
        button: true,
        label: title,
        child: InkWell(onTap: onPressed, child: row),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: last ? 0 : MxSpacing.space4),
      padding: EdgeInsets.only(bottom: last ? 0 : MxSpacing.space4),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: mx.divider, width: MxStroke.hairline),
              ),
            ),
      child: row,
    );
  }
}
