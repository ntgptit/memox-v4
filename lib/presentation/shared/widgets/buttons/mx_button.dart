import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Emphasis level for [MxButton].
enum MxButtonVariant { primary, secondary, outline, ghost, contrast }

/// Size step for [MxButton].
enum MxButtonSize { sm, lg }

/// The primary action button — the design kit's `MxButton`.
///
/// Purpose:
/// A pill action button with five emphasis levels, optional icons, and a
/// destructive color, used for every tappable call-to-action.
///
/// Use when:
/// A screen needs a save, create, continue, or other primary/secondary action.
///
/// Do not use when:
/// The action is a bare icon (use MxIconButton) or a navigation row.
///
/// Category:
/// button
///
/// Public API:
/// - label: visible button text
/// - onPressed: action callback (null disables the button)
/// - variant: primary / secondary / outline / ghost / contrast
/// - size: sm or lg
/// - icon / trailingIcon: optional leading/trailing icons
/// - block: stretch to full width
/// - danger: destructive (error) color, composes with variant
///
/// States:
/// default, pressed, disabled
///
/// Variants:
/// primary, secondary, outline, ghost, contrast
class MxButton extends StatelessWidget {
  const MxButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MxButtonVariant.primary,
    this.size = MxButtonSize.lg,
    this.icon,
    this.trailingIcon,
    this.block = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final MxButtonVariant variant;
  final MxButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool block;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
    final disabled = onPressed == null;
    final (background, foreground, border) = _style(colors);

    final iconSize = size == MxButtonSize.sm
        ? MxSpacing.space4
        : MxSpacing.space5;
    final content = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon case final i?) ...<Widget>[
          Icon(i, size: iconSize),
          const SizedBox(width: MxSpacing.space2),
        ],
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(color: foreground),
        ),
        if (trailingIcon case final t?) ...<Widget>[
          const SizedBox(width: MxSpacing.space2),
          Icon(t, size: iconSize),
        ],
      ],
    );

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: background,
        borderRadius: MxRadius.controlRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            decoration: border == null
                ? null
                : BoxDecoration(
                    borderRadius: MxRadius.controlRadius,
                    border: Border.all(color: border),
                  ),
            padding: EdgeInsets.symmetric(
              horizontal: size == MxButtonSize.sm
                  ? MxSpacing.space4
                  : MxSpacing.space6,
              vertical: size == MxButtonSize.sm
                  ? MxSpacing.space2
                  : MxSpacing.space3,
            ),
            constraints: const BoxConstraints(
              minHeight: MxSpacing.minTouchTarget,
            ),
            alignment: Alignment.center,
            child: IconTheme.merge(
              data: IconThemeData(color: foreground),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: foreground),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color background, Color foreground, Color? border) _style(MxColors c) {
    final accent = danger ? c.error : c.primary;
    final onAccent = danger ? c.onError : c.onPrimary;
    final soft = danger ? c.errorSoft : c.primarySoft;
    final onSoft = danger ? c.onErrorSoft : c.onPrimarySoft;
    return switch (variant) {
      MxButtonVariant.primary => (accent, onAccent, null),
      MxButtonVariant.secondary => (soft, onSoft, null),
      MxButtonVariant.outline => (
        Colors.transparent,
        danger ? c.error : c.text,
        c.borderStrong,
      ),
      // kit `.btn.ghost` reads `--memox-primary-strong`, not primary
      // (components.css) — the stronger hue keeps text-only actions legible.
      // NOTE ghost+danger: the kit CSS cascade composes `.btn.danger` ON TOP of
      // `.btn.ghost` (bg:error, on-error fill) — here danger ghost stays a
      // text-only error action. No callsite combines them today; if one appears,
      // align with the kit cascade first.
      MxButtonVariant.ghost => (
        Colors.transparent,
        danger ? c.error : c.primaryStrong,
        null,
      ),
      MxButtonVariant.contrast => (c.surface, accent, null),
    };
  }
}
