import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/game-picker/providers/game_picker_providers.dart';
import 'package:memox_v4/presentation/shared/composites/select_sheet.dart';

/// Game-picker local card-source sheet (kit `ScopeSheet`) — the content of an
/// [showMxSheet]. By schedule / All cards / Unlearned only, with a check on the
/// active one. Delegates layout to the shared [SelectSheet]. Copy is from ARB.
class ScopeSheet extends StatelessWidget {
  const ScopeSheet({required this.selected, required this.onSelect, super.key});

  final GameSource selected;
  final ValueChanged<GameSource> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxSelectSheet<GameSource>(
      selected: selected,
      onSelect: onSelect,
      options: [
        MxSelectOption(
          value: GameSource.schedule,
          icon: Icons.schedule,
          label: l10n.gamePickerSourceSchedule,
        ),
        MxSelectOption(
          value: GameSource.all,
          icon: Icons.apps,
          label: l10n.gamePickerSourceAll,
        ),
        MxSelectOption(
          value: GameSource.unlearned,
          icon: Icons.hourglass_empty,
          label: l10n.gamePickerSourceUnlearned,
        ),
      ],
    );
  }
}
