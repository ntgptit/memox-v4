import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';

/// The kit's `ProgressHeader` (K.4a, Đ-K-2): THE one progress presentation for
/// study / review / game flows — an 8px linear bar plus a "done/total" count.
/// Numeric-only label (no copy), so no l10n key is needed. Player's autoplay
/// dots are the sole sanctioned exception.
class MxProgressHeader extends StatelessWidget {
  const MxProgressHeader({
    required this.done,
    required this.total,
    super.key,
  });

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MxProgressBar(value: total == 0 ? 0 : done / total),
        ),
        const SizedBox(width: MxSpacing.space3),
        Text(
          '$done/$total',
          style: TextStyle(
            fontFamily: MxTypography.fontFamily,
            fontSize: MxTypography.sizeSm,
            fontWeight: MxTypography.bold,
            color: MxTheme.of(context).textSecondary,
          ),
        ),
      ],
    );
  }
}
