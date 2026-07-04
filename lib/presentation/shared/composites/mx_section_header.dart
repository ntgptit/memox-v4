import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// The kit's section / list header (`MxSectionHeader` · base class
/// `.section-head`): a title, an optional caption beneath it, and an optional
/// trailing text action (e.g. "See all"). A composite, token-driven via
/// [MxTheme]. All copy is supplied by the caller (from ARB).
class MxSectionHeader extends StatelessWidget {
  const MxSectionHeader({
    required this.title,
    this.caption,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? caption;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Kit `.section-head__text { gap: 2px }` — raw px with no matching token.
  static const double _titleCaptionGap = 2;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final caption = this.caption;
    final actionLabel = this.actionLabel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeMd,
                  fontWeight: MxTypography.bold,
                  letterSpacing: MxTypography.sizeMd * MxTypography.trackingTight,
                  color: scheme.onSurface,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: _titleCaptionGap),
                Text(
                  caption,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeSm,
                    color: mx.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(width: MxSpacing.space3),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: mx.primaryStrong,
              padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space2),
              textStyle: const TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeSm,
                fontWeight: MxTypography.semibold,
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ],
    );
  }
}
