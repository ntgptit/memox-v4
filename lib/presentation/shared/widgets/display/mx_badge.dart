import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Semantic tone for [MxBadge].
enum MxBadgeTone { success, warning, error }

/// A small status label or dot — the design kit's `MxBadge`.
///
/// Purpose:
/// A compact semantic indicator: a counted/labelled pill or a bare status dot.
///
/// Use when:
/// Flagging status (due count, new, error) next to a label.
///
/// Do not use when:
/// It is interactive (use MxChip) or a primary action.
///
/// Category:
/// display
///
/// Public API:
/// - label: badge text (ignored when dot is true)
/// - tone: success / warning / error
/// - soft: soft tinted instead of solid fill
/// - dot: render a bare status dot with no text
///
/// States:
/// default
///
/// Variants:
/// solid, soft, dot
class MxBadge extends StatelessWidget {
  const MxBadge({
    super.key,
    this.label,
    this.tone = MxBadgeTone.error,
    this.soft = false,
    this.dot = false,
  });

  final String? label;
  final MxBadgeTone tone;
  final bool soft;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
    final (strong, onStrong, softBg, onSoft) = _palette(colors);

    if (dot) {
      return Container(
        width: MxSpacing.space2,
        height: MxSpacing.space2,
        decoration: BoxDecoration(color: strong, shape: BoxShape.circle),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: soft ? softBg : strong,
        borderRadius: MxRadius.pillRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MxSpacing.space2,
          vertical: MxSpacing.space1,
        ),
        child: Text(
          label ?? '',
          style: theme.textTheme.labelSmall?.copyWith(
            color: soft ? onSoft : onStrong,
          ),
        ),
      ),
    );
  }

  (Color strong, Color onStrong, Color soft, Color onSoft) _palette(
    MxColors c,
  ) => switch (tone) {
    MxBadgeTone.success => (
      c.success,
      c.onSuccess,
      c.successSoft,
      c.onSuccessSoft,
    ),
    MxBadgeTone.warning => (
      c.warning,
      c.onWarning,
      c.warningSoft,
      c.onWarningSoft,
    ),
    MxBadgeTone.error => (c.error, c.onError, c.errorSoft, c.onErrorSoft),
  };
}
