import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/domain/usecases/io/import_cards.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/import/providers/import_providers.dart';
import 'package:memox_v4/presentation/features/import/widgets/import_table.dart';
import 'package:memox_v4/presentation/features/import/widgets/source_card.dart';
import 'package:memox_v4/presentation/shared/composites/action_callout.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

/// Fixed height for the done / empty boxes.
const double _stateBoxHeight = 360;

/// How many preview rows to show in the table.
const int _previewRowLimit = 6;

/// The Import screen (S.10): a source → mapping → preview → done wizard. Drives
/// DM.7 `ParseImport` (D-025) + DM.8 file service through [importControllerProvider]
/// (no `setState`; the paste field's text controller is not app state). Copy is
/// from ARB.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final TextEditingController _paste = TextEditingController();
  final FocusNode _pasteFocus = FocusNode();

  ImportController get _controller => ref.read(importControllerProvider.notifier);

  @override
  void dispose() {
    _paste.dispose();
    _pasteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(importControllerProvider);

    return MxScaffold(
      appBar: MxAppBar(
        title: l10n.importTitle,
        leading: MxIconButton(
          icon: Icons.arrow_back,
          semanticLabel: l10n.importBack,
          onPressed: () => _back(state.step),
        ),
      ),
      children: switch (state.step) {
        ImportStep.source => _source(l10n, state),
        ImportStep.mapping => _mapping(l10n, state),
        ImportStep.preview => _preview(l10n, state),
        ImportStep.done => _done(l10n, state),
      },
    );
  }

  void _back(ImportStep step) {
    switch (step) {
      case ImportStep.source || ImportStep.done:
        context.pop();
      case ImportStep.mapping:
        _controller.goTo(ImportStep.source);
      case ImportStep.preview:
        _controller.goTo(ImportStep.mapping);
    }
  }

  // ── Source ─────────────────────────────────────────────────────────────────

  List<Widget> _source(AppLocalizations l10n, ImportState state) {
    return [
      _Label(l10n.importChooseSource),
      SourceCard(
        icon: Icons.description,
        name: l10n.importSourceCsv,
        description: l10n.importSourceCsvDesc,
        onPressed: _controller.pickFile,
      ),
      SourceCard(
        icon: Icons.table_chart,
        name: l10n.importSourceExcel,
        description: l10n.importSourceExcelDesc,
        onPressed: _controller.pickFile,
      ),
      SourceCard(
        icon: Icons.content_paste,
        name: l10n.importSourcePaste,
        description: l10n.importSourcePasteDesc,
        onPressed: _pasteFocus.requestFocus,
      ),
      _PasteField(
        controller: _paste,
        focusNode: _pasteFocus,
        hint: l10n.importPastePlaceholder,
        onChanged: _controller.setInput,
      ),
      MxButton(
        label: l10n.importContinue,
        block: true,
        onPressed: state.input.trim().isEmpty
            ? null
            : _controller.continueFromSource,
      ),
    ];
  }

  // ── Mapping ────────────────────────────────────────────────────────────────

  List<Widget> _mapping(AppLocalizations l10n, ImportState state) {
    final preview = _controller.parseCurrent();
    return [
      _Label(l10n.importSeparator),
      Row(
        children: [
          for (final (index, separator) in ImportSeparator.values.indexed) ...[
            if (index > 0) const SizedBox(width: MxSpacing.space2),
            MxChip(
              label: _separatorLabel(l10n, separator),
              selected: state.separator == separator,
              onPressed: () => _controller.setSeparator(separator),
            ),
          ],
        ],
      ),
      MxCard(
        padding: MxCardPadding.small,
        child: MxListRow(
          icon: Icons.table_rows,
          title: l10n.importHasHeader,
          last: true,
          trailing: MxSwitch(
            value: state.hasHeader,
            semanticLabel: l10n.importHasHeader,
            onChanged: _controller.setHasHeader,
          ),
        ),
      ),
      if (_controller.columnCount() > 1) ...[
        _columnPicker(
          l10n,
          label: l10n.importTermColumn,
          selected: state.termColumn,
          count: _controller.columnCount(),
          onPick: _controller.setTermColumn,
        ),
        _columnPicker(
          l10n,
          label: l10n.importMeaningColumn,
          selected: state.meaningColumn,
          count: _controller.columnCount(),
          onPick: _controller.setMeaningColumn,
        ),
      ],
      _tableOrEmpty(l10n, preview),
      MxButton(
        label: l10n.importContinue,
        block: true,
        onPressed:
            preview.drafts.isEmpty ? null : () => _controller.toPreview(),
      ),
    ];
  }

  /// A labelled row of column chips for picking the term / meaning column.
  Widget _columnPicker(
    AppLocalizations l10n, {
    required String label,
    required int selected,
    required int count,
    required void Function(int) onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        Wrap(
          spacing: MxSpacing.space2,
          runSpacing: MxSpacing.space2,
          children: [
            for (var i = 0; i < count; i++)
              MxChip(
                label: l10n.importColumnLabel(i + 1),
                selected: selected == i,
                onPressed: () => onPick(i),
              ),
          ],
        ),
      ],
    );
  }

  // ── Preview / dup-warning ──────────────────────────────────────────────────

  List<Widget> _preview(AppLocalizations l10n, ImportState state) {
    final preview = state.preview ?? _controller.parseCurrent();
    if (preview.drafts.isEmpty) {
      return [
        SizedBox(
          height: _stateBoxHeight,
          child: MxEmptyState(
            icon: Icons.rule,
            tone: MxIconTileTone.warning,
            title: l10n.importEmptyPreview,
            text: l10n.importEmptyPreviewText,
          ),
        ),
      ];
    }
    return [
      if (state.duplicateCount > 0)
        MxActionCallout(
          icon: Icons.warning_amber,
          text: l10n.importDupWarning(state.duplicateCount),
        ),
      _Label(l10n.importPreviewLabel(preview.drafts.length)),
      if (preview.skipped > 0) _SkippedNote(text: l10n.importSkipped(preview.skipped)),
      _table(l10n, preview),
      MxButton(
        label: l10n.importDoImport(preview.drafts.length),
        icon: Icons.download,
        block: true,
        onPressed: () => _controller.commit(),
      ),
    ];
  }

  // ── Done ───────────────────────────────────────────────────────────────────

  List<Widget> _done(AppLocalizations l10n, ImportState state) {
    return [
      SizedBox(
        height: _stateBoxHeight,
        child: MxEmptyState(
          icon: Icons.task_alt,
          tone: MxIconTileTone.success,
          title: l10n.importDoneTitle(state.importedCount),
          text: l10n.importDoneText,
          action: MxButton(
            label: l10n.importBackToDeck,
            icon: Icons.arrow_forward,
            onPressed: () => context.pop(),
          ),
        ),
      ),
    ];
  }

  Widget _tableOrEmpty(AppLocalizations l10n, ImportPreview preview) {
    if (preview.drafts.isEmpty) {
      return _SkippedNote(text: l10n.importEmptyPreview);
    }
    return _table(l10n, preview);
  }

  Widget _table(AppLocalizations l10n, ImportPreview preview) {
    final rows = <List<String>>[
      [l10n.importColTerm, l10n.importColMeaning],
      for (final draft in preview.drafts.take(_previewRowLimit))
        [draft.term, draft.meaning],
    ];
    return ImportTable(rows: rows);
  }

  String _separatorLabel(AppLocalizations l10n, ImportSeparator separator) {
    return switch (separator) {
      ImportSeparator.tab => l10n.importSepTab,
      ImportSeparator.comma => l10n.importSepComma,
      ImportSeparator.semicolon => l10n.importSepSemicolon,
    };
  }
}

class _PasteField extends StatelessWidget {
  const _PasteField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: MxSizes.sizeXl),
      padding: const EdgeInsets.all(MxSpacing.space4),
      decoration: BoxDecoration(
        borderRadius: MxRadius.controlRadius,
        border: Border.all(color: mx.divider, width: MxStroke.hairline),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        maxLines: null,
        minLines: 4,
        style: TextStyle(
          fontFamily: MxTypography.fontFamily,
          fontSize: MxTypography.sizeBase,
          color: scheme.onSurface,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: MxTypography.fontFamily,
            fontSize: MxTypography.sizeBase,
            color: mx.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _SkippedNote extends StatelessWidget {
  const _SkippedNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: MxSpacing.space1),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: MxTypography.fontFamily,
          fontSize: MxTypography.sizeSm,
          color: mx.textTertiary,
        ),
      ),
    );
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
