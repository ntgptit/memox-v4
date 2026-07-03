import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';

/// Export-local in-progress card (kit `ExportingCard`): a spinner, an
/// "Exporting…" label, and an indeterminate progress bar. Copy is from ARB.
class ExportingCard extends StatelessWidget {
  const ExportingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space5),
        child: Column(
          children: [
            SizedBox(
              width: MxIconSize.lg,
              height: MxIconSize.lg,
              child: CircularProgressIndicator(
                strokeWidth: MxSpacing.space1,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: MxSpacing.space4),
            Text(
              '${l10n.exportingLabel}…',
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeBase,
                fontWeight: MxTypography.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: MxSpacing.space4),
            const MxProgressBar(value: 0.7),
          ],
        ),
      ),
    );
  }
}
