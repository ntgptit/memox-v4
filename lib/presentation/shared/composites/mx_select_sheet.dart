import 'package:flutter/material.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';

/// One selectable option in a [MxSelectSheet]: its [value], a leading [icon], and a
/// [label] (from ARB). The icon may encode selection (radio style) — the caller
/// computes it against the current value when building the list.
class MxSelectOption<T> {
  const MxSelectOption({
    required this.value,
    required this.icon,
    required this.label,
  });

  final T value;
  final IconData icon;
  final String label;
}

/// The kit's `_shared/SelectSheet` as a reusable composite (`MxSelectSheet`): a
/// single-select option
/// list for a bottom sheet — a column of [MxListRow]s, each an icon + label, with a
/// primary-tinted trailing check on the active one. Present it as the child of
/// [showMxSheet] (which supplies the surface + scrim). Each row pops the sheet, then
/// reports its value via [onSelect]. Owns the pattern shared by game-picker
/// (ScopeSheet), library (SortSheet) and settings (ValuePickerSheet). Copy is
/// supplied by the caller (from ARB).
class MxSelectSheet<T> extends StatelessWidget {
  const MxSelectSheet({
    required this.options,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<MxSelectOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, option) in options.indexed)
          MxListRow(
            icon: option.icon,
            title: option.label,
            last: index == options.length - 1,
            selected: option.value == selected,
            onPressed: () {
              Navigator.of(context).pop();
              onSelect(option.value);
            },
          ),
      ],
    );
  }
}
