import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/theme/widgets/accent_picker.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';

/// Theme-local live preview (kit `PreviewCard`): a sample term/meaning/CTA that
/// reflects the selected accent + text size, so choices are visible without
/// re-theming the whole app. Copy (sample) is from ARB.
class PreviewCard extends StatelessWidget {
  const PreviewCard({required this.accent, required this.fontScale, super.key});

  final AccentColor accent;
  final FontScale fontScale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final termSize = _termSize(fontScale);

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.themePreviewLabel.toUpperCase(),
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeSm,
              fontWeight: MxTypography.bold,
              letterSpacing: MxTypography.sizeSm * MxTypography.trackingWide,
              color: mx.textSecondary,
            ),
          ),
          const SizedBox(height: MxSpacing.space3),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(MxSpacing.space5),
            decoration: BoxDecoration(
              borderRadius: MxRadius.controlRadius,
              border: Border.all(color: mx.divider, width: MxStroke.hairline),
            ),
            child: Column(
              children: [
                Text(
                  l10n.themePreviewTerm,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: termSize,
                    fontWeight: MxTypography.extrabold,
                    letterSpacing: termSize * MxTypography.trackingTight,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: MxSpacing.space1),
                Text(
                  l10n.themePreviewMeaning,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeBase,
                    color: mx.textSecondary,
                  ),
                ),
                const SizedBox(height: MxSpacing.space4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: MxSpacing.space2,
                    horizontal: MxSpacing.space5,
                  ),
                  decoration: BoxDecoration(
                    color: accentSwatchColor(accent),
                    borderRadius: MxRadius.pillRadius,
                  ),
                  child: Text(
                    l10n.themePreviewCta,
                    style: TextStyle(
                      fontFamily: MxTypography.fontFamily,
                      fontSize: MxTypography.sizeSm,
                      fontWeight: MxTypography.bold,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _termSize(FontScale scale) => switch (scale) {
        FontScale.small => MxTypography.sizeXl,
        FontScale.medium => MxTypography.size2xl,
        FontScale.large => MxTypography.size3xl,
      };
}
