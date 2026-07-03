import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Tone for [MxActionCallout] — picks the `*Soft` / `on*Soft` token pair.
enum MxCalloutTone { warning, success, error }

/// The kit's shared `ActionCallout`: a soft-tinted inline banner (icon + message)
/// with an optional trailing [action] (usually a small `MxButton`). A composite,
/// token-driven via [MxTheme]. Used for the import dup-warning + game-picker
/// not-enough banners; the message is supplied by the caller (from ARB).
class MxActionCallout extends StatelessWidget {
  const MxActionCallout({
    required this.icon,
    required this.text,
    this.tone = MxCalloutTone.warning,
    this.action,
    super.key,
  });

  final IconData icon;
  final String text;
  final MxCalloutTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final (background, foreground) = _colors(mx);

    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: MxSpacing.space3,
          horizontal: MxSpacing.space4,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: MxRadius.controlRadius,
        ),
        child: Row(
          spacing: MxSpacing.space3,
          children: [
            Icon(icon, size: MxIconSize.md, color: foreground),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeSm,
                  color: foreground,
                ),
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }

  (Color, Color) _colors(MxTheme mx) {
    return switch (tone) {
      MxCalloutTone.warning => (mx.warningSoft, mx.onWarningSoft),
      MxCalloutTone.success => (mx.successSoft, mx.onSuccessSoft),
      MxCalloutTone.error => (mx.errorSoft, mx.onErrorSoft),
    };
  }
}
