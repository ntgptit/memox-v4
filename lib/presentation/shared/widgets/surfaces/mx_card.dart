import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Surface treatment for [MxCard].
enum MxCardVariant { flat, muted, primary, primarySoft }

/// Inner padding step for [MxCard].
enum MxCardPadding { sm, lg }

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
/// flat, muted, primary, primarySoft
class MxCard extends StatelessWidget {
  const MxCard({
    super.key,
    this.variant = MxCardVariant.flat,
    this.padding = MxCardPadding.lg,
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
    final (background, foreground) = switch (variant) {
      MxCardVariant.flat => (colors.surfaceRaised, colors.text),
      MxCardVariant.muted => (colors.surfaceMuted, colors.text),
      MxCardVariant.primary => (colors.primary, colors.onPrimary),
      MxCardVariant.primarySoft => (colors.primarySoft, colors.onPrimarySoft),
    };
    final pad = switch (padding) {
      MxCardPadding.sm => MxSpacing.space3,
      MxCardPadding.lg => MxSpacing.space4,
    };
    return Material(
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
    );
  }
}
