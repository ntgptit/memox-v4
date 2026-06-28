import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Visual treatment for [MxIconButton].
enum MxIconButtonVariant { plain, filled, primary }

/// A tappable icon — the design kit's `MxIconButton`.
///
/// Purpose:
/// A circular icon-only action for app bars, toolbars, and inline actions.
///
/// Use when:
/// A compact action needs only an icon (back, menu, more, close).
///
/// Do not use when:
/// The action needs a text label (use MxButton).
///
/// Category:
/// button
///
/// Public API:
/// - icon: the icon to show
/// - onPressed: tap callback
/// - variant: plain / filled / primary
/// - small: a smaller hit target
/// - tooltip: accessibility/hover label
///
/// States:
/// default, pressed, disabled
///
/// Variants:
/// plain, filled, primary
class MxIconButton extends StatelessWidget {
  const MxIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = MxIconButtonVariant.plain,
    this.small = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final MxIconButtonVariant variant;
  final bool small;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = MxTheme.of(context).colors;
    final (background, foreground) = switch (variant) {
      MxIconButtonVariant.plain => (Colors.transparent, colors.text),
      MxIconButtonVariant.filled => (colors.surfaceMuted, colors.text),
      MxIconButtonVariant.primary => (colors.primary, colors.onPrimary),
    };
    final diameter = small ? MxSpacing.space8 : MxSpacing.space9;
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Icon(
            icon,
            size: small ? MxSpacing.space4 : MxSpacing.space5,
            color: foreground,
          ),
        ),
      ),
    );
    final label = tooltip;
    return label == null ? button : Tooltip(message: label, child: button);
  }
}
