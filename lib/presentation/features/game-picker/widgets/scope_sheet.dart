import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/game-picker/providers/game_picker_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';

/// Game-picker local card-source sheet (kit `ScopeSheet`) — the content of an
/// [showMxSheet]. By schedule / All cards / Unlearned only, with a check on the
/// active one. Each item dismisses the sheet before applying. Copy is from ARB.
class ScopeSheet extends StatelessWidget {
  const ScopeSheet({required this.selected, required this.onSelect, super.key});

  final GameSource selected;
  final ValueChanged<GameSource> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <(GameSource, IconData, String)>[
      (GameSource.schedule, Icons.schedule, l10n.gamePickerSourceSchedule),
      (GameSource.all, Icons.apps, l10n.gamePickerSourceAll),
      (GameSource.unlearned, Icons.hourglass_empty, l10n.gamePickerSourceUnlearned),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, option) in options.indexed)
          MxListRow(
            icon: option.$2,
            title: option.$3,
            last: index == options.length - 1,
            trailing: option.$1 == selected
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onPressed: () {
              Navigator.of(context).pop();
              onSelect(option.$1);
            },
          ),
      ],
    );
  }
}
