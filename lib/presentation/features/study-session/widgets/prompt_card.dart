import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';

/// Study-session local (kit `PromptCard`): a centered term with an optional
/// sub-label. Shared by the choice / recall / typing stages.
class PromptCard extends StatelessWidget {
  const PromptCard({required this.term, this.sub, super.key});

  final String term;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
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
          if (sub != null) ...[
            const SizedBox(height: MxSpacing.space3),
            Text(
              sub!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeBase,
                color: mx.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
