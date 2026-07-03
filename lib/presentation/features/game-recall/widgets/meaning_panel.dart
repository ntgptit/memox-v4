import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';

/// Game-recall local meaning panel (kit `MeaningPanel`): a recall hint until
/// [revealed], then the card meaning. Copy is from ARB.
class MeaningPanel extends StatelessWidget {
  const MeaningPanel({required this.meaning, required this.revealed, super.key});

  final String meaning;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Container(
        constraints: const BoxConstraints(minHeight: MxSizes.size2xl),
        alignment: Alignment.center,
        child: revealed
            ? Text(
                meaning,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.size2xl,
                  fontWeight: MxTypography.bold,
                  color: scheme.onSurface,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility, size: MxIconSize.sm, color: mx.textTertiary),
                  const SizedBox(width: MxSpacing.space2),
                  Text(
                    l10n.recallHint,
                    style: TextStyle(
                      fontFamily: MxTypography.fontFamily,
                      fontSize: MxTypography.sizeSm,
                      fontWeight: MxTypography.semibold,
                      color: mx.textTertiary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
