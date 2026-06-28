import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/types/sort.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck/viewmodels/library_notifier.dart';
import 'package:memox_v4/presentation/features/deck/widgets/deck_actions.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/mx_deck_tile.dart';
import 'package:memox_v4/presentation/shared/widgets/states/mx_state_view.dart';

/// Library home — the Library tab body: the active pair's root deck tree, with
/// sort + create-deck, and per-node rename/move/delete (`01-library.md`).
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncNodes = ref.watch(libraryProvider);
    return Column(
      children: <Widget>[
        _toolbar(l10n),
        Expanded(
          child: asyncNodes.when(
            loading: () => const MxStateView.loading(),
            error: (error, stack) => _error(l10n),
            data: (nodes) => nodes.isEmpty ? _empty(l10n) : _list(nodes),
          ),
        ),
      ],
    );
  }

  Widget _toolbar(AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.fromLTRB(
      MxSpacing.space4,
      MxSpacing.space2,
      MxSpacing.space2,
      MxSpacing.space2,
    ),
    child: Row(
      children: <Widget>[
        Expanded(child: MxText.title(l10n.tabLibrary)),
        MxIconButton(
          key: const Key('librarySearch'),
          icon: Icons.search,
          tooltip: l10n.searchHint,
          onPressed: () => context.push(RoutePaths.search),
        ),
        MxIconButton(
          key: const Key('librarySort'),
          icon: Icons.sort,
          tooltip: l10n.sortLabel,
          onPressed: () => unawaited(_showSortSheet()),
        ),
        MxButton(
          key: const Key('libraryNewDeck'),
          label: l10n.libraryCreateDeck,
          icon: Icons.create_new_folder_outlined,
          variant: MxButtonVariant.ghost,
          size: MxButtonSize.sm,
          onPressed: () => unawaited(_createRootDeck()),
        ),
      ],
    ),
  );

  Widget _list(List<DeckNode> nodes) => ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: MxSpacing.space2),
    itemCount: nodes.length,
    itemBuilder: (context, index) {
      final node = nodes[index];
      return MxDeckTile(
        node: node,
        onTap: () => context.push(RoutePaths.deckDetailLocation(node.deck.id)),
        onMenu: () => unawaited(_onDeckMenu(node)),
      );
    },
  );

  Widget _empty(AppLocalizations l10n) => MxContentBounds(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.library_books_outlined,
            size: MxSpacing.space10,
            color: MxTheme.of(context).colors.primary,
          ),
          const SizedBox(height: MxSpacing.space4),
          MxText.headline(l10n.libraryEmptyTitle),
          const SizedBox(height: MxSpacing.space2),
          MxText.body(l10n.libraryEmptySubtitle, textAlign: TextAlign.center),
          const SizedBox(height: MxSpacing.space5),
          MxButton(
            key: const Key('libraryCreateDeck'),
            label: l10n.libraryCreateDeck,
            icon: Icons.add,
            onPressed: () => unawaited(_createRootDeck()),
          ),
        ],
      ),
    ),
  );

  Widget _error(AppLocalizations l10n) => MxContentBounds(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: MxSpacing.space9,
            color: MxTheme.of(context).colors.error,
          ),
          const SizedBox(height: MxSpacing.space3),
          MxText(l10n.libraryError),
          const SizedBox(height: MxSpacing.space4),
          MxButton(
            label: l10n.commonRetry,
            onPressed: () =>
                unawaited(ref.read(libraryProvider.notifier).refresh()),
          ),
        ],
      ),
    ),
  );

  Future<void> _createRootDeck() async {
    final name = await promptDeckName(
      context,
      title: AppLocalizations.of(context).deckNewTitle,
    );
    if (!mounted || name == null) return;
    await ref.read(libraryProvider.notifier).createDeck(name: name);
  }

  Future<void> _onDeckMenu(DeckNode node) async {
    final notifier = ref.read(libraryProvider.notifier);
    final action = await showDeckActions(context);
    if (!mounted || action == null) return;
    switch (action) {
      case DeckAction.rename:
        final name = await promptDeckName(
          context,
          title: AppLocalizations.of(context).deckRename,
          initial: node.deck.name,
        );
        if (!mounted || name == null) return;
        await notifier.renameDeck(node.deck.id, name);
      case DeckAction.move:
        final roots = ref.read(libraryProvider).value ?? const <DeckNode>[];
        final candidates = <Deck>[
          for (final n in roots)
            if (n.deck.id != node.deck.id) n.deck,
        ];
        final target = await promptMoveDeck(context, candidates: candidates);
        if (!mounted || target == null) return;
        await notifier.moveDeck(node.deck.id, newParentId: target.parentId);
      case DeckAction.delete:
        final confirmed = await confirmDeleteDeck(context);
        if (!mounted || !confirmed) return;
        await notifier.deleteDeck(node.deck.id);
    }
  }

  Future<void> _showSortSheet() async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(libraryProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        Widget tile(SortBy by, SortDirection dir, String label) => ListTile(
          leading: Icon(
            dir == SortDirection.asc
                ? Icons.arrow_upward
                : Icons.arrow_downward,
          ),
          title: Text(label),
          selected: notifier.sortBy == by && notifier.sortDirection == dir,
          onTap: () {
            notifier.setSort(by, dir);
            Navigator.of(ctx).pop();
          },
        );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              tile(SortBy.alphabet, SortDirection.asc, l10n.sortAlphabet),
              tile(SortBy.alphabet, SortDirection.desc, l10n.sortAlphabet),
              tile(SortBy.createdAt, SortDirection.asc, l10n.sortCreated),
              tile(SortBy.createdAt, SortDirection.desc, l10n.sortCreated),
              tile(SortBy.lastStudied, SortDirection.asc, l10n.sortLastStudied),
              tile(
                SortBy.lastStudied,
                SortDirection.desc,
                l10n.sortLastStudied,
              ),
            ],
          ),
        );
      },
    );
  }
}
