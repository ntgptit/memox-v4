import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_component.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// The kit's `SectionLabel` helper: THE one ALL-CAPS overline label above a
/// group of rows/cards (K.3 — no inline copies). 13px bold, wide tracking,
/// text-secondary (AA at label size, audit G1). [onTint] renders on a colored
/// card: inherits the card's foreground at label opacity instead of the
/// secondary color. [uppercase] transforms mixed-case copy (ARB strings stay
/// mixed-case; the transform is presentation). Copy is from ARB.
class MxSectionLabel extends StatelessWidget {
  const MxSectionLabel({
    required this.text,
    this.onTint = false,
    this.uppercase = false,
    super.key,
  });

  final String text;
  final bool onTint;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final label = Text(
      uppercase ? text.toUpperCase() : text,
      style: TextStyle(
        fontFamily: MxTypography.fontFamily,
        fontSize: MxTypography.sizeSm,
        fontWeight: MxTypography.bold,
        letterSpacing: MxTypography.sizeSm * MxTypography.trackingWide,
        color: onTint ? null : mx.textSecondary,
      ),
    );
    if (!onTint) return label;
    return Opacity(opacity: MxOpacity.label, child: label);
  }
}
