import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/study-result/widgets/result_hero.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// Skeleton height for the finalizing streak/goal placeholder.
const double _goalSkeletonHeight = 120;

/// Study-result local (kit `FinalizingView`): the "saving your results…" view
/// shown while the session commits. [retry] reframes it as a re-attempt after a
/// finalize error. Copy is from ARB.
class FinalizingView extends StatelessWidget {
  const FinalizingView({this.retry = false, this.onClose, super.key});

  final bool retry;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxScaffold(
      appBar: MxAppBar(
        title: l10n.resultTitle,
        leading: MxIconButton(
          icon: Icons.close,
          semanticLabel: l10n.resultClose,
          onPressed: onClose,
        ),
      ),
      children: [
        ResultHero(
          icon: retry ? Icons.refresh : Icons.cloud_sync,
          tone: MxIconTileTone.accent,
          title: retry ? l10n.resultRetrying : l10n.resultSaving,
          text: retry ? l10n.resultRetryingText : l10n.resultSavingText,
        ),
        const Row(
          children: [
            Expanded(child: MxSkeleton(height: 64)),
            SizedBox(width: MxSpacing.space3),
            Expanded(child: MxSkeleton(height: 64)),
            SizedBox(width: MxSpacing.space3),
            Expanded(child: MxSkeleton(height: 64)),
          ],
        ),
        const MxSkeleton(height: _goalSkeletonHeight),
      ],
    );
  }
}
