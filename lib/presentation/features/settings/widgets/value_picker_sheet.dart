import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/settings/providers/settings_providers.dart';
import 'package:memox_v4/presentation/shared/composites/select_sheet.dart';

/// Settings-local words-per-round picker (kit `settings/picker-sheet`) — the
/// content of an [showMxSheet]. Radio-style: the active count carries a check.
/// Delegates layout to the shared [SelectSheet]. Copy is from ARB.
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

    return MxSelectSheet<int>(
      selected: current,
      onSelect: onSelect,
      options: [
        for (final count in gameWordsPerRoundOptions)
          MxSelectOption(
            value: count,
            icon: count == current ? Icons.check_circle : Icons.circle_outlined,
            label: l10n.settingsWordsOption(count),
          ),
      ],
    );
  }
}
