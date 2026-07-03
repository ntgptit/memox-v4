import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/export/providers/export_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';

/// Export-local format radio list (kit `FormatList`): CSV / Excel / Copy text,
/// with the selected one carrying a filled radio. Copy is from ARB.
class FormatList extends StatelessWidget {
  const FormatList({required this.selected, required this.onSelect, super.key});

  final ExportFormat selected;
  final ValueChanged<ExportFormat> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    final formats = <(ExportFormat, IconData, String, String)>[
      (ExportFormat.csv, Icons.description, l10n.exportFormatCsv, l10n.exportFormatCsvSub),
      (ExportFormat.excel, Icons.table_chart, l10n.exportFormatExcel, l10n.exportFormatExcelSub),
      (ExportFormat.copy, Icons.content_copy, l10n.exportFormatCopy, l10n.exportFormatCopySub),
    ];

    return MxCard(
      padding: MxCardPadding.small,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, format) in formats.indexed)
            MxListRow(
              icon: format.$2,
              title: format.$3,
              subtitle: format.$4,
              last: index == formats.length - 1,
              onPressed: () => onSelect(format.$1),
              trailing: Icon(
                format.$1 == selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: format.$1 == selected ? scheme.primary : mx.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}
