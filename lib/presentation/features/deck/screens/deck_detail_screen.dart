import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/entities/card.dart' as domain;
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/types/card_status.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck/viewmodels/deck_detail_notifier.dart';
import 'package:memox_v4/presentation/features/deck/viewmodels/library_notifier.dart';
import 'package:memox_v4/presentation/features/deck/widgets/deck_actions.dart';
import 'package:memox_v4/presentation/features/study/widgets/play_menu_sheet.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/mx_deck_tile.dart';
import 'package:memox_v4/presentation/shared/widgets/navigation/mx_fab.dart';
import 'package:memox_v4/presentation/shared/widgets/states/mx_state_view.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_scaffold.dart';

/// Deck detail — a node's sub-decks + direct cards (a mixed node). Pushed route
/// `/deck/:id` (`docs/design/screens/04-deck-detail.md`).
class DeckDetailScreen extends ConsumerStatefulWidget {
  const DeckDetailScreen({super.key, required this.deckId});

  final int deckId;

  @override
  ConsumerState<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends ConsumerState<DeckDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(deckDetailProvider(widget.deckId));
    final state = async.value;
    final node = state?.node;
    // The kit hides the add FAB in the empty state (the empty-add CTA covers it);
    // only show it when the node has content.
    final hasContent =
        node != null && (node.children.isNotEmpty || state!.cards.isNotEmpty);
    return MxScaffold(
      key: const ValueKey('mx-node:deck-detail/screen'),
      appBar: MxAppBar(
        key: const ValueKey('mx-node:deck-detail/appbar'),
        title: node?.deck.name ?? '',
        trailing: <Widget>[
          if (node != null)
            MxIconButton(
              key: const Key('deckDetailImport'),
              icon: Icons.download_outlined,
              tooltip: l10n.drawerImport,
              onPressed: () => unawaited(
                context.push(RoutePaths.deckImportLocation(widget.deckId)),
              ),
            ),
          if (node != null)
            MxIconButton(
              key: const Key('deckDetailExport'),
              icon: Icons.upload_outlined,
              tooltip: l10n.drawerExport,
              onPressed: () => unawaited(
                context.push(RoutePaths.deckExportLocation(widget.deckId)),
              ),
            ),
          if (node != null)
            MxIconButton(
              key: const Key('deckDetailPlay'),
              icon: Icons.play_circle_outline,
              onPressed: () => unawaited(showPlayMenu(context, widget.deckId)),
            ),
          if (node != null)
            MxIconButton(
              key: const ValueKey('mx-node:deck-detail/menu'),
              icon: Icons.more_vert,
              onPressed: () => unawaited(_deckMenu(node, isSelf: true)),
            ),
        ],
      ),
      flush: true,
      fab: !hasContent
          ? null
          : MxFab(
              key: const ValueKey('mx-node:deck-detail/add'),
              icon: Icons.add,
              label: l10n.deckAddWord,
              onPressed: () => unawaited(_addWord()),
            ),
      body: async.when(
        loading: () => const MxStateView.loading(),
        error: (error, stack) => _error(l10n),
        data: (state) => state.node == null
            ? _message(l10n.deckNotFound)
            : _content(l10n, state),
      ),
    );
  }

  Widget _content(AppLocalizations l10n, DeckDetailState state) {
    final children = state.node!.children;
    final cards = state.cards;
    if (children.isEmpty && cards.isEmpty) {
      return MxContentBounds(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxText.body(l10n.deckDetailEmpty, textAlign: TextAlign.center),
              const SizedBox(height: MxSpacing.space4),
              MxButton(
                key: const ValueKey('mx-node:deck-detail/empty-add'),
                label: l10n.deckAddWord,
                icon: Icons.add,
                onPressed: () => unawaited(_addWord()),
              ),
              const SizedBox(height: MxSpacing.space2),
              MxButton(
                key: const ValueKey('mx-node:deck-detail/empty-subdeck'),
                label: l10n.deckNewSubdeck,
                icon: Icons.create_new_folder_outlined,
                variant: MxButtonVariant.outline,
                onPressed: () => unawaited(_createSubDeck()),
              ),
              const SizedBox(height: MxSpacing.space2),
              MxButton(
                key: const ValueKey('mx-node:deck-detail/empty-import'),
                label: l10n.drawerImport,
                icon: Icons.download_outlined,
                variant: MxButtonVariant.ghost,
                onPressed: () => unawaited(
                  context.push(RoutePaths.deckImportLocation(widget.deckId)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: MxSpacing.space12),
      children: <Widget>[
        _sectionHeader(
          l10n.deckDetailSubdecks,
          actionKey: const Key('deckDetailNewSubdeck'),
          actionLabel: l10n.deckNewSubdeck,
          onAction: () => unawaited(_createSubDeck()),
        ),
        for (final child in children)
          MxDeckTile(
            node: child,
            onTap: () => unawaited(_openChild(child.deck.id)),
            onMenu: () => unawaited(_deckMenu(child, isSelf: false)),
          ),
        _sectionHeader(
          l10n.deckDetailCards,
          actionKey: const Key('deckDetailAddWordSection'),
          actionLabel: l10n.deckAddWord,
          onAction: () => unawaited(_addWord()),
        ),
        for (final card in cards) _cardRow(l10n, card),
      ],
    );
  }

  Widget _sectionHeader(
    String title, {
    required Key actionKey,
    required String actionLabel,
    required VoidCallback onAction,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(
      MxSpacing.space5,
      MxSpacing.space4,
      MxSpacing.space2,
      MxSpacing.space1,
    ),
    child: Row(
      children: <Widget>[
        Expanded(child: MxText.label(title)),
        MxButton(
          key: actionKey,
          label: actionLabel,
          icon: Icons.add,
          variant: MxButtonVariant.ghost,
          size: MxButtonSize.sm,
          onPressed: onAction,
        ),
      ],
    ),
  );

  Widget _cardRow(AppLocalizations l10n, domain.Card card) {
    final status = deriveCardStatus(
      hidden: card.hidden,
      box: null,
      isDue: false,
    );
    final meaning = card.meanings.isEmpty ? '' : card.meanings.first.content;
    return Opacity(
      opacity: card.hidden ? 0.5 : 1,
      child: ListTile(
        key: Key('cardRow-${card.id}'),
        title: MxText.title(
          card.term,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(meaning, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: MxText(
          _statusLabel(l10n, status),
          role: MxTextRole.labelSmall,
        ),
        onTap: () => unawaited(_editCard(card.id)),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, CardStatus status) =>
      switch (status) {
        CardStatus.newCard => l10n.cardStatusNew,
        CardStatus.due => l10n.cardStatusDue,
        CardStatus.mastered => l10n.cardStatusMastered,
        CardStatus.learning => l10n.cardStatusLearning,
        CardStatus.hidden => l10n.cardStatusNew,
      };

  Widget _message(String text) =>
      MxContentBounds(child: Center(child: MxText(text)));

  Widget _error(AppLocalizations l10n) => MxContentBounds(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MxText(l10n.libraryError),
          const SizedBox(height: MxSpacing.space4),
          MxButton(
            key: const ValueKey('mx-node:deck-detail/retry'),
            label: l10n.commonRetry,
            onPressed: () => unawaited(_notifier.refresh()),
          ),
        ],
      ),
    ),
  );

  // ── actions ────────────────────────────────────────────────────────────────
  DeckDetailNotifier get _notifier =>
      ref.read(deckDetailProvider(widget.deckId).notifier);

  Future<void> _openChild(int childId) async {
    await context.push(RoutePaths.deckDetailLocation(childId));
    if (mounted) await _notifier.refresh();
  }

  Future<void> _addWord() async {
    await context.push(RoutePaths.flashcardEditorLocation(widget.deckId));
    if (mounted) await _notifier.refresh();
  }

  Future<void> _editCard(int cardId) async {
    await context.push(
      RoutePaths.flashcardEditorLocation(widget.deckId, cardId: cardId),
    );
    if (mounted) await _notifier.refresh();
  }

  Future<void> _createSubDeck() async {
    final name = await promptDeckName(
      context,
      title: AppLocalizations.of(context).deckNewSubdeck,
    );
    if (!mounted || name == null) return;
    await _notifier.createSubDeck(name);
  }

  Future<void> _deckMenu(DeckNode node, {required bool isSelf}) async {
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
        await _notifier.renameDeck(node.deck.id, name);
      case DeckAction.move:
        final roots = ref.read(libraryProvider).value ?? const <DeckNode>[];
        final candidates = <Deck>[
          for (final n in roots)
            if (n.deck.id != node.deck.id) n.deck,
        ];
        final target = await promptMoveDeck(context, candidates: candidates);
        if (!mounted || target == null) return;
        await _notifier.moveDeck(node.deck.id, newParentId: target.parentId);
      case DeckAction.delete:
        final confirmed = await confirmDeleteDeck(context);
        if (!mounted || !confirmed) return;
        await _notifier.deleteDeck(node.deck.id);
        if (isSelf && mounted) await Navigator.of(context).maybePop();
    }
  }
}
