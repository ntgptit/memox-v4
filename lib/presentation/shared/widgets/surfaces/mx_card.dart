import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Surface treatment for [MxCard].
enum MxCardVariant { elevated, flat, muted, primary, primarySoft }

/// Inner padding step for [MxCard].
enum MxCardPadding { sm, md, lg }

/// A rounded content surface — the design kit's `MxCard`.
///
/// Purpose:
/// One container for grouped content, with the four brand surface treatments.
///
/// Use when:
/// Wrapping a block of related content (a stat, a list section, a banner).
///
/// Do not use when:
/// The element is a full screen frame (use MxScaffold) or a tappable list row.
///
/// Category:
/// card
///
/// Public API:
/// - variant: flat / muted / primary / primarySoft surface treatment
/// - padding: sm or lg inner padding
/// - interactive: adds a tap ripple (requires onTap)
/// - onTap: tap callback
/// - child: card content
///
/// States:
/// default, pressed (when interactive)
///
/// Variants:
/// elevated, flat, muted, primary, primarySoft
class MxCard extends StatelessWidget {
  const MxCard({
    super.key,
    this.variant = MxCardVariant.elevated,
    this.padding = MxCardPadding.md,
    this.interactive = false,
    this.onTap,
    required this.child,
  });

  final MxCardVariant variant;
  final MxCardPadding padding;
  final bool interactive;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = MxTheme.of(context).colors;
    final shadows = MxTheme.of(context).shadows;
    final (background, foreground, shadow, border) = switch (variant) {
      MxCardVariant.elevated => (
        colors.surface,
        colors.text,
        shadows.card,
        null,
      ),
      MxCardVariant.flat => (
        colors.surface,
        colors.text,
        <BoxShadow>[],
        Border.all(color: colors.border),
      ),
      MxCardVariant.muted => (
        colors.surfaceMuted,
        colors.text,
        <BoxShadow>[],
        null,
      ),
      MxCardVariant.primary => (
        colors.primary,
        colors.onPrimary,
        shadows.fab,
        null,
      ),
      MxCardVariant.primarySoft => (
        colors.primarySoft,
        colors.onPrimarySoft,
        <BoxShadow>[],
        null,
      ),
    };
    final pad = switch (padding) {
      MxCardPadding.sm => MxSpacing.space4,
      MxCardPadding.md => MxSpacing.space5,
      MxCardPadding.lg => MxSpacing.space6,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: MxRadius.cardRadius,
        border: border,
        boxShadow: shadow,
      ),
      child: Material(
        color: background,
        borderRadius: MxRadius.cardRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: interactive ? onTap : null,
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: foreground),
              child: IconTheme.merge(
                data: IconThemeData(color: foreground),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
