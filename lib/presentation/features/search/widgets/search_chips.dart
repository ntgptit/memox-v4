import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/search/providers/search_providers.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';

/// Search-local status filter chips (kit `search/filters`): All · New · Due ·
/// Mastered. Dumb — the screen supplies [active] + [onSelect]. Copy is from ARB
/// (shared filter keys).
class SearchChips extends StatelessWidget {
  const SearchChips({required this.active, required this.onSelect, super.key});

  final SearchFilter active;
  final ValueChanged<SearchFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = <(SearchFilter, String)>[
      (SearchFilter.all, l10n.deckDetailFilterAll),
      (SearchFilter.newCards, l10n.deckDetailFilterNew),
      (SearchFilter.due, l10n.deckDetailFilterDue),
      (SearchFilter.mastered, l10n.deckDetailFilterMastered),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: MxSpacing.space2,
        children: [
          for (final (filter, label) in chips)
            MxChip(
              label: label,
              selected: filter == active,
              onPressed: () => onSelect(filter),
            ),
        ],
      ),
    );
  }
}
