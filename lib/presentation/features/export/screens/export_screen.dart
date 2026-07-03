import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/export/providers/export_providers.dart';
import 'package:memox_v4/presentation/features/export/widgets/exporting_card.dart';
import 'package:memox_v4/presentation/features/export/widgets/format_list.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_segmented_control.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

/// Fixed height for the done box.
const double _doneBoxHeight = 400;

/// The Export screen (S.11): a scope · format · separator · review-state config
/// then an exporting → done flow. Drives DM.7 `BuildExport` (D-026) + DM.8 file
/// service through [exportControllerProvider]. No `setState`. Copy is from ARB.
class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(exportControllerProvider);

    return MxScaffold(
      appBar: MxAppBar(
        title: l10n.exportTitle,
        leading: MxIconButton(
          icon: Icons.arrow_back,
          semanticLabel: l10n.exportBack,
          onPressed: state.step == ExportStep.exporting ? null : () => context.pop(),
        ),
      ),
      children: switch (state.step) {
        ExportStep.config => _config(context, ref, l10n, state),
        ExportStep.exporting => const [ExportingCard()],
        ExportStep.done => _done(context, ref, l10n, state),
      },
    );
  }

  List<Widget> _config(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ExportState state,
  ) {
    final controller = ref.read(exportControllerProvider.notifier);

    return [
      _Label(l10n.exportScope),
      MxSegmentedControl(
        block: true,
        value: state.scope.name,
        segments: [
          MxSegment(value: ExportScope.deck.name, label: l10n.exportScopeDeck),
          MxSegment(value: ExportScope.subtree.name, label: l10n.exportScopeSubtree),
        ],
        onChanged: (value) => controller.setScope(ExportScope.values.byName(value)),
      ),
      _Label(l10n.exportFormat),
      FormatList(selected: state.format, onSelect: controller.setFormat),
      _Label(l10n.importSeparator),
      Row(
        children: [
          for (final (index, separator) in ExportSeparator.values.indexed) ...[
            if (index > 0) const SizedBox(width: MxSpacing.space2),
            MxChip(
              label: _separatorLabel(l10n, separator),
              selected: state.separator == separator,
              onPressed: () => controller.setSeparator(separator),
            ),
          ],
        ],
      ),
      MxCard(
        padding: MxCardPadding.small,
        child: MxListRow(
          icon: Icons.schedule,
          tone: MxIconTileTone.success,
          title: l10n.exportIncludeSrs,
          subtitle: l10n.exportIncludeSrsSub,
          last: true,
          trailing: MxSwitch(
            value: state.includeSrs,
            semanticLabel: l10n.exportIncludeSrs,
            onChanged: controller.setIncludeSrs,
          ),
        ),
      ),
      MxButton(
        label: l10n.exportAction,
        icon: Icons.download,
        block: true,
        onPressed: controller.run,
      ),
    ];
  }

  List<Widget> _done(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ExportState state,
  ) {
    final controller = ref.read(exportControllerProvider.notifier);
    return [
      SizedBox(
        height: _doneBoxHeight,
        child: MxEmptyState(
          icon: Icons.ios_share,
          tone: MxIconTileTone.success,
          title: l10n.exportDoneTitle(state.exportedCount),
          text: l10n.exportDoneText,
          action: SizedBox(
            width: MxSizes.size3xl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MxButton(
                  label: l10n.exportShare,
                  icon: Icons.share,
                  block: true,
                  onPressed: controller.share,
                ),
                const SizedBox(height: MxSpacing.space3),
                MxButton(
                  label: l10n.exportSave,
                  variant: MxButtonVariant.ghost,
                  icon: Icons.save_alt,
                  block: true,
                  onPressed: controller.save,
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  String _separatorLabel(AppLocalizations l10n, ExportSeparator separator) {
    return switch (separator) {
      ExportSeparator.tab => l10n.importSepTab,
      ExportSeparator.comma => l10n.importSepComma,
      ExportSeparator.semicolon => l10n.importSepSemicolon,
    };
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: MxSpacing.space1),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: MxTypography.fontFamily,
          fontSize: MxTypography.sizeSm,
          fontWeight: MxTypography.bold,
          letterSpacing: MxTypography.sizeSm * MxTypography.trackingWide,
          color: mx.textTertiary,
        ),
      ),
    );
  }
}
