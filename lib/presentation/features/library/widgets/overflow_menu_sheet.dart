import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';

/// Library-local overflow menu (kit `library/overflow-sheet`) — the content of an
/// [showMxSheet]. Import / Export / Settings. The kit's "Select multiple" item is
/// omitted (multi-select mode is not in v1 scope; documented gap). Copy is from
/// ARB. Each item dismisses the sheet before acting.
class OverflowMenuSheet extends StatelessWidget {
  const OverflowMenuSheet({
    required this.onImport,
    required this.onExport,
    required this.onSettings,
    super.key,
  });

  final VoidCallback onImport;
  final VoidCallback onExport;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget item(IconData icon, String label, VoidCallback action,
        {bool last = false}) {
      return MxListRow(
        icon: icon,
        title: label,
        last: last,
        onPressed: () {
          Navigator.of(context).pop();
          action();
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        item(Icons.upload_file, l10n.librarySheetImport, onImport),
        item(Icons.download, l10n.librarySheetExport, onExport),
        item(Icons.settings, l10n.librarySheetSettings, onSettings, last: true),
      ],
    );
  }
}
