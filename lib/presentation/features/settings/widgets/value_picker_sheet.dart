import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/settings/providers/settings_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';

/// Settings-local words-per-round picker (kit `settings/picker-sheet`) — the
/// content of an [showMxSheet]. Radio-style: the active count carries a check.
/// Each option dismisses the sheet before applying. Copy is from ARB.
class ValuePickerSheet extends StatelessWidget {
  const ValuePickerSheet({
    required this.current,
    required this.onSelect,
    super.key,
  });

  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const options = gameWordsPerRoundOptions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, count) in options.indexed)
          MxListRow(
            icon: count == current ? Icons.check_circle : Icons.circle_outlined,
            title: l10n.settingsWordsOption(count),
            last: index == options.length - 1,
            trailing: count == current
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onPressed: () {
              Navigator.of(context).pop();
              onSelect(count);
            },
          ),
      ],
    );
  }
}
