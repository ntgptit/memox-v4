import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// The kit's bottom-sheet menu row (`MenuItem`, kit-helpers) — a full-width
/// button with a **plain leading icon** (no coloured tile), a label, and an
/// optional trailing widget or a `selected` check. This is the action-sheet
/// counterpart to [MxListRow] (settings rows), which carries an `MxIconTile`;
/// sheet menus (deck/​card actions, overflow, play, pair-picker, select sheets)
/// use THIS so they match the kit's plain-icon treatment. Copy comes from ARB.
class MxMenuItem extends StatelessWidget {
  const MxMenuItem({
    required this.icon,
    required this.label,
    this.danger = false,
    this.trailing,
    this.selected = false,
    this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;

  /// Destructive action — icon + label tint to the error role (kit `danger`).
  final bool danger;

  final Widget? trailing;

  /// Single-select sheets — renders the primary-tinted check unless an explicit
  /// [trailing] is given.
  final bool selected;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final foreground = danger ? scheme.error : scheme.onSurface;
    final iconColor = danger ? scheme.error : mx.textSecondary;
    final trailingWidget =
        trailing ?? (selected ? Icon(Icons.check, color: scheme.primary) : null);

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: MxSpacing.space3,
        horizontal: MxSpacing.space2,
      ),
      child: Row(
        spacing: MxSpacing.space4,
        children: [
          Icon(icon, size: MxIconSize.md, color: iconColor),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeBase,
                fontWeight: MxTypography.semibold,
                color: foreground,
              ),
            ),
          ),
          ?trailingWidget,
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: MxRadius.controlRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: MxSpacing.minTouchTarget,
            ),
            child: row,
          ),
        ),
      ),
    );
  }
}
