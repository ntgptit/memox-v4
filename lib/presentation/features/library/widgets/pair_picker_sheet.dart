import 'package:flutter/material.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_menu_item.dart';

/// Library-local language-pair picker (kit `library/pair-sheet`) — the content of
/// an [showMxSheet]. Lists the learner's pairs with a check on the active one,
/// plus an add action. Each item dismisses the sheet before acting. Copy is from
/// ARB; pair names are content (not translatable).
class PairPickerSheet extends StatelessWidget {
  const PairPickerSheet({
    required this.pairs,
    required this.selectedId,
    required this.onSelect,
    required this.onAdd,
    super.key,
  });

  final List<LanguagePair> pairs;
  final LanguagePairId? selectedId;
  final ValueChanged<LanguagePairId> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final pair in pairs)
          MxMenuItem(
            icon: Icons.translate,
            label: [pair.learningLanguage, pair.nativeLanguage].join(' → '),
            selected: pair.id.value == selectedId?.value,
            onPressed: () {
              Navigator.of(context).pop();
              onSelect(pair.id);
            },
          ),
        MxMenuItem(
          icon: Icons.add,
          label: l10n.librarySheetPairAdd,
          onPressed: () {
            Navigator.of(context).pop();
            onAdd();
          },
        ),
      ],
    );
  }
}
