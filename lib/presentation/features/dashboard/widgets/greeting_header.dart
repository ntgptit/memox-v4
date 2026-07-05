import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Dashboard greeting block (kit `dashboard/greeting`): the date eyebrow above
/// the greeting headline, as the first child of the scroll body — split OUT of
/// the app bar so it scrolls away with content while the slim bar (actions
/// only) stays. Same type ramp the large app bar used. Copy is from ARB /
/// locale-formatted by the caller.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    required this.eyebrow,
    required this.title,
    super.key,
  });

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            fontFamily: MxTypography.fontFamily,
            fontSize: MxTypography.sizeSm,
            fontWeight: MxTypography.semibold,
            color: mx.textSecondary,
          ),
        ),
        const SizedBox(height: MxSpacing.space1),
        Text(
          title,
          style: TextStyle(
            fontFamily: MxTypography.fontFamily,
            fontSize: MxTypography.size2xl,
            fontWeight: MxTypography.extrabold,
            letterSpacing: MxTypography.size2xl * MxTypography.trackingTight,
            height: MxTypography.lineHeightTight,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
