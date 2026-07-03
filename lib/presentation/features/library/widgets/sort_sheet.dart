import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/library/providers/library_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';

/// Library-local sort picker (kit `library/sort-sheet`) — the content of an
/// [showMxSheet]. Only name-based orders are offered; the kit's date-created /
/// last-studied options are undrivable in v1 (no such deck columns) and are
/// omitted (documented gap). Copy is from ARB.
class SortSheet extends StatelessWidget {
  const SortSheet({required this.current, required this.onSelect, super.key});

  final LibrarySortOrder current;
  final ValueChanged<LibrarySortOrder> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget option(LibrarySortOrder order, String label, {bool last = false}) {
      return MxListRow(
        icon: Icons.sort_by_alpha,
        title: label,
        last: last,
        trailing: current == order
            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
            : null,
        onPressed: () {
          Navigator.of(context).pop();
          onSelect(order);
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        option(LibrarySortOrder.alphaAsc, l10n.librarySortAlphaAsc),
        option(LibrarySortOrder.alphaDesc, l10n.librarySortAlphaDesc, last: true),
      ],
    );
  }
}
