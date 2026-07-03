import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// Study-session local (kit `StageReview`): stage 1 — see the term + meaning,
/// then advance. Copy is from ARB.
class StageReview extends StatelessWidget {
  const StageReview({
    required this.term,
    required this.meaning,
    this.onNext,
    super.key,
  });

  final String term;
  final String meaning;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxCard(
          child: Container(
            constraints: const BoxConstraints(minHeight: MxSizes.size4xl),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  term,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.size4xl,
                    fontWeight: MxTypography.extrabold,
                    letterSpacing:
                        MxTypography.size4xl * MxTypography.trackingTight,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: MxSpacing.space4),
                Container(
                  width: MxSizes.sizeMd,
                  height: MxSizes.size3xs,
                  decoration: BoxDecoration(
                    color: mx.divider,
                    borderRadius:
                        const BorderRadius.all(Radius.circular(MxRadius.xs)),
                  ),
                ),
                const SizedBox(height: MxSpacing.space4),
                Text(
                  meaning,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.size2xl,
                    fontWeight: MxTypography.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: MxSpacing.space5),
        MxButton(
          label: l10n.studyNext,
          icon: Icons.arrow_forward,
          size: MxButtonSize.large,
          block: true,
          onPressed: onNext,
        ),
      ],
    );
  }
}
