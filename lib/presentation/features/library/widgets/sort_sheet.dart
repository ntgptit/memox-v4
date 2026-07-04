import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/library/providers/library_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_select_sheet.dart';

/// Library-local sort picker (kit `library/sort-sheet`) — the content of an
/// [showMxSheet]. Only name-based orders are offered; the kit's date-created /
/// last-studied options are undrivable in v1 (no such deck columns) and are
/// omitted (documented gap). Delegates layout to the shared [SelectSheet]. Copy
/// is from ARB.
class SortSheet extends StatelessWidget {
  const SortSheet({required this.current, required this.onSelect, super.key});

  final LibrarySortOrder current;
  final ValueChanged<LibrarySortOrder> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxSelectSheet<LibrarySortOrder>(
      selected: current,
      onSelect: onSelect,
      options: [
        MxSelectOption(
          value: LibrarySortOrder.alphaAsc,
          icon: Icons.sort_by_alpha,
          label: l10n.librarySortAlphaAsc,
        ),
        MxSelectOption(
          value: LibrarySortOrder.alphaDesc,
          icon: Icons.sort_by_alpha,
          label: l10n.librarySortAlphaDesc,
        ),
      ],
    );
  }
}
