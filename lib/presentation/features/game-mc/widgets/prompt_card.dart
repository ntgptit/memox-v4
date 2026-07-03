import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';

/// Game-mc local prompt (kit `PromptCard`): the prompt term with audio + edit
/// controls. Copy is from ARB.
class PromptCard extends StatelessWidget {
  const PromptCard({
    required this.term,
    this.onAudio,
    this.onEdit,
    super.key,
  });

  final String term;
  final VoidCallback? onAudio;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Column(
        children: [
          Text(
            term,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.size4xl,
              fontWeight: MxTypography.extrabold,
              letterSpacing: MxTypography.size4xl * MxTypography.trackingTight,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: MxSpacing.space3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MxIconButton(
                icon: Icons.volume_up,
                semanticLabel: l10n.mcAudio,
                onPressed: onAudio,
              ),
              const SizedBox(width: MxSpacing.space2),
              MxIconButton(
                icon: Icons.edit,
                semanticLabel: l10n.mcEdit,
                size: MxIconButtonSize.small,
                onPressed: onEdit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
