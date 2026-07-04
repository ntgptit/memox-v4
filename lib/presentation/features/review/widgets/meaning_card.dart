import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_text_field.dart';

/// Review-local (kit `review/meaning`): the meaning with an inline edit
/// affordance — a read-only value, or (when [editing]) a bordered field with
/// Cancel / Save. Copy is from ARB.
class MeaningCard extends StatelessWidget {
  const MeaningCard({
    required this.meaning,
    required this.editing,
    this.controller,
    this.onEdit,
    this.onCancel,
    this.onSave,
    super.key,
  });

  final String meaning;
  final bool editing;
  final TextEditingController? controller;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.reviewMeaningLabel,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeSm,
                    fontWeight: MxTypography.bold,
                    letterSpacing:
                        MxTypography.sizeSm * MxTypography.trackingWide,
                    color: mx.textTertiary,
                  ),
                ),
              ),
              MxIconButton(
                icon: editing ? Icons.close : Icons.edit,
                semanticLabel: editing
                    ? l10n.reviewEditCancel
                    : l10n.reviewEdit,
                size: MxIconButtonSize.small,
                onPressed: editing ? onCancel : onEdit,
              ),
            ],
          ),
          const SizedBox(height: MxSpacing.space3),
          editing
              ? _editor(l10n, scheme)
              : Text(
                  meaning,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.size2xl,
                    fontWeight: MxTypography.bold,
                    color: scheme.onSurface,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _editor(AppLocalizations l10n, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.space4,
            vertical: MxSpacing.space3,
          ),
          decoration: BoxDecoration(
            borderRadius: MxRadius.controlRadius,
            border: Border.all(color: scheme.primary, width: MxStroke.emphasis),
          ),
          child: MxTextField(
            controller: controller,
            autofocus: true,
            onSubmitted: (_) => onSave?.call(),
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeMd,
              fontWeight: MxTypography.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: MxSpacing.space2),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MxButton(
              label: l10n.reviewEditCancelAction,
              variant: MxButtonVariant.ghost,
              size: MxButtonSize.small,
              onPressed: onCancel,
            ),
            const SizedBox(width: MxSpacing.space2),
            MxButton(
              label: l10n.reviewEditSave,
              size: MxButtonSize.small,
              onPressed: onSave,
            ),
          ],
        ),
      ],
    );
  }
}
