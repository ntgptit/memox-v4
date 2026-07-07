import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck-detail/providers/deck_detail_providers.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/deck_header.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/deck_menu.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/delete_confirm_dialog.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/flashcard_row.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/move_sheet.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/sub_deck_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_input_dialog.dart';
import 'package:memox_v4/presentation/shared/composites/mx_menu_item.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_search_dock.dart';
import 'package:memox_v4/presentation/shared/composites/mx_sheet.dart';
import 'package:memox_v4/presentation/shared/composites/mx_status_card_row.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_section_label.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// Fixed height for the full-screen empty / error / no-results boxes.
const double _stateBoxHeight = 460;

/// Skeleton pill radius for the loading search placeholder.
const double _pillRadius = 999;

/// The deck-detail screen (S.03): a tree node's sub-decks + cards, with in-deck
/// search + status filters. Reads DM.6 state through [deckDetailControllerProvider]
/// and renders loading · empty · loaded · search · no-results · error with
/// `AsyncValue.when`. State lives in providers (the search field's text controller
/// is not app state); add / card-actions / deck-menu / move / delete are modal
/// sheets + dialogs. Copy is from ARB.
class DeckDetailScreen extends ConsumerStatefulWidget {
  const DeckDetailScreen({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends ConsumerState<DeckDetailScreen> {
  final TextEditingController _search = TextEditingController();

  // Kit sub-deck tiles cycle accent → primary(default) → … (DeckDetail SUBDECKS).
  static const List<MxIconTileTone> _tones = [
    MxIconTileTone.accent,
    MxIconTileTone.primary,
    MxIconTileTone.success,
    MxIconTileTone.warning,
  ];

  DeckDetailController get _controller =>
      ref.read(deckDetailControllerProvider(widget.deckId).notifier);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(deckDetailControllerProvider(widget.deckId));
    // Keep root decks warm so the "Move to" sheet's sibling destinations are
    // resolved the moment it opens (a bare read would still be loading).
    ref.watch(rootDecksProvider);

    return async.when(
      loading: () => MxScaffold(appBar: _header(''), children: _loadingBody()),
      error: (_, _) => MxScaffold(
        appBar: _header(''),
        children: [
          _StateBox(
            child: _ErrorBody(
              onRetry: () =>
                  ref.invalidate(deckDetailControllerProvider(widget.deckId)),
            ),
          ),
        ],
      ),
      data: _content,
    );
  }

  DeckHeader _header(String title) => DeckHeader(
    title: title,
    onBack: () => context.pop(),
    onPlayAudio: title.isEmpty ? null : _playDeckAudio,
    onMenu: title.isEmpty ? null : _openDeckMenu,
  );

  void _playDeckAudio() =>
      ref.read(deckDetailControllerProvider(widget.deckId).notifier).playDeckAudio();

  Widget _content(DeckDetailData data) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(deckSearchQueryProvider);
    final header = DeckHeader(
      title: data.deckName,
      onBack: () => context.pop(),
      onPlayAudio: _playDeckAudio,
      onMenu: _openDeckMenu,
    );
    final searching = query.trim().isNotEmpty;

    if (searching) {
      final filter = ref.watch(deckCardFilterStateProvider);
      final results = _filter(data.cards, query, filter);
      return MxScaffold(
        appBar: header,
        children: [
          _searchDock(searching: true),
          _filterChips(filter),
          if (results.isEmpty)
            _StateBox(
              child: MxEmptyState(
                icon: Icons.search_off,
                tone: MxIconTileTone.warning,
                title: l10n.deckDetailNoResultsTitle,
                text: l10n.deckDetailNoResultsText(query),
              ),
            ),
          for (final card in results) _cardTile(card),
        ],
      );
    }

    if (data.isEmpty) {
      return MxScaffold(appBar: header, children: [_emptyBody()]);
    }

    return MxScaffold(
      appBar: header,
      fab: MxFab(
        icon: Icons.add,
        label: l10n.deckDetailAddWord,
        onPressed: _openAddMenu,
      ),
      children: [
        _searchDock(searching: false),
        if (data.subDecks.isNotEmpty) ...[
          _SectionLabel(l10n.deckDetailSectionSubDecks),
          for (final (index, sub) in data.subDecks.indexed)
            SubDeckCard(
              info: sub,
              tone: _tones[index % _tones.length],
              onPressed: () => context.push(Routes.deckDetail(sub.id.value)),
            ),
        ],
        if (data.cards.isNotEmpty) ...[
          _SectionLabel(l10n.deckDetailSectionCards),
          for (final card in data.cards) _cardTile(card),
        ],
      ],
    );
  }

  Widget _cardTile(DeckCardInfo card) {
    return MxCard(
      padding: MxCardPadding.small,
      onPressed: () => _openCardActions(card),
      child: FlashcardRow(card: card),
    );
  }

  Widget _searchDock({required bool searching}) {
    final l10n = AppLocalizations.of(context);
    return MxSearchDock(
      controller: _search,
      placeholder: l10n.deckDetailSearchPlaceholder,
      onChanged: (value) =>
          ref.read(deckSearchQueryProvider.notifier).set(value),
      trailing: searching
          ? MxIconButton(
              icon: Icons.close,
              semanticLabel: l10n.deckDetailSearchClear,
              size: MxIconButtonSize.small,
              onPressed: _clearSearch,
            )
          : null,
    );
  }

  void _clearSearch() {
    _search.clear();
    ref.read(deckSearchQueryProvider.notifier).clear();
  }

  Widget _filterChips(DeckCardFilter active) {
    final l10n = AppLocalizations.of(context);
    final chips = <(DeckCardFilter, String)>[
      (DeckCardFilter.all, l10n.deckDetailFilterAll),
      (DeckCardFilter.newCards, l10n.deckDetailFilterNew),
      (DeckCardFilter.due, l10n.deckDetailFilterDue),
      (DeckCardFilter.mastered, l10n.deckDetailFilterMastered),
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
              onPressed: () =>
                  ref.read(deckCardFilterStateProvider.notifier).select(filter),
            ),
        ],
      ),
    );
  }

  List<DeckCardInfo> _filter(
    List<DeckCardInfo> cards,
    String query,
    DeckCardFilter filter,
  ) {
    final needle = query.trim().toLowerCase();
    return cards
        .where((card) {
          if (!_matchesFilter(card, filter)) return false;
          if (needle.isEmpty) return true;
          return card.term.toLowerCase().contains(needle) ||
              card.meaning.toLowerCase().contains(needle);
        })
        .toList(growable: false);
  }

  bool _matchesFilter(DeckCardInfo card, DeckCardFilter filter) {
    return switch (filter) {
      DeckCardFilter.all => true,
      DeckCardFilter.newCards => card.status == MxCardStatus.newCard,
      DeckCardFilter.due => card.status == MxCardStatus.due,
      DeckCardFilter.mastered => card.status == MxCardStatus.mastered,
    };
  }

  // ── Sheets + dialogs ─────────────────────────────────────────────────────────

  void _openDeckMenu() {
    final data = ref.read(deckDetailControllerProvider(widget.deckId)).value;
    if (data == null) return;
    showMxSheet<void>(
      context: context,
      title: data.deckName,
      child: DeckMenu(
        onMove: () => _openMove(data),
        onReset: _confirmResetDeckProgress,
        onDelete: _confirmDeleteDeck,
      ),
    );
  }

  void _openMove(DeckDetailData data) => showMoveSheet(
        context: context,
        ref: ref,
        data: data,
        onMove: (targetId) => _controller.moveTo(targetId),
      );

  Future<void> _confirmDeleteDeck() async {
    final ok = await showDeleteDeckDialog(context);
    if (!ok) return;
    await _controller.deleteDeck();
    if (mounted) context.pop();
  }

  void _openAddMenu() {
    final l10n = AppLocalizations.of(context);
    final deckName =
        ref.read(deckDetailControllerProvider(widget.deckId)).value?.deckName;
    showMxSheet<void>(
      context: context,
      title: deckName == null
          ? l10n.deckDetailAddTitle
          : l10n.deckDetailAddToTitle(deckName),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxMenuItem(
            icon: Icons.add,
            label: l10n.deckDetailAddWord,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(Routes.add);
            },
          ),
          MxMenuItem(
            icon: Icons.library_add,
            label: l10n.deckDetailAddSubdeck,
            onPressed: () {
              Navigator.of(context).pop();
              _openCreateSubDeck();
            },
          ),
          MxMenuItem(
            icon: Icons.upload_file,
            label: l10n.deckDetailAddImport,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(Routes.import_);
            },
          ),
        ],
      ),
    );
  }

  /// Prompt for a name (kit `deck-detail/new-subdeck`) and create a sub-deck
  /// under the current deck.
  Future<void> _openCreateSubDeck() async {
    final l10n = AppLocalizations.of(context);
    final name = await showMxInputDialog(
      context: context,
      icon: Icons.library_add,
      title: l10n.deckDetailAddSubdeck,
      label: l10n.deckNameLabel,
      placeholder: l10n.deckDetailSubdeckPlaceholder,
      confirmLabel: l10n.actionCreate,
      cancelLabel: l10n.actionCancel,
    );
    if (name == null) return;
    await _controller.createSubDeck(name);
  }

  void _openCardActions(DeckCardInfo card) {
    final l10n = AppLocalizations.of(context);
    showMxSheet<void>(
      context: context,
      title: card.term,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxMenuItem(
            icon: Icons.edit,
            label: l10n.deckDetailCardEdit,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(Routes.editCard(card.id.value));
            },
          ),
          MxMenuItem(
            icon: card.hidden ? Icons.visibility : Icons.visibility_off,
            label: card.hidden
                ? l10n.deckDetailCardUnhide
                : l10n.deckDetailCardHide,
            onPressed: () {
              Navigator.of(context).pop();
              _controller.setCardHidden(card.id, hidden: !card.hidden);
            },
          ),
          MxMenuItem(
            icon: Icons.delete,
            label: l10n.deckDetailCardDelete,
            danger: true,
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteCard(card);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteCard(DeckCardInfo card) async {
    final ok = await showDeleteCardDialog(context, term: card.term);
    if (!ok) return;
    await _controller.deleteCard(card.id);
  }

  Future<void> _confirmResetDeckProgress() async {
    final ok = await showResetProgressDialog(context);
    if (!ok) return;
    await _controller.resetDeckProgress();
  }

  // ── Empty / loading ──────────────────────────────────────────────────────────

  Widget _emptyBody() {
    final l10n = AppLocalizations.of(context);
    return _StateBox(
      child: MxEmptyState(
        icon: Icons.style,
        title: l10n.deckDetailEmptyTitle,
        text: l10n.deckDetailEmptyText,
        action: SizedBox(
          width: MxSizes.size3xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MxButton(
                label: l10n.deckDetailEmptyAdd,
                icon: Icons.add,
                block: true,
                onPressed: () => context.push(Routes.add),
              ),
              const SizedBox(height: MxSpacing.space3),
              MxButton(
                label: l10n.deckDetailEmptySubdeck,
                variant: MxButtonVariant.ghost,
                icon: Icons.library_add,
                block: true,
                onPressed: _openCreateSubDeck,
              ),
              const SizedBox(height: MxSpacing.space3),
              MxButton(
                label: l10n.deckDetailEmptyImport,
                variant: MxButtonVariant.ghost,
                icon: Icons.upload_file,
                block: true,
                onPressed: () => context.push(Routes.import_),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _loadingBody() {
    return [
      const MxSkeleton(height: MxSpacing.minTouchTarget, radius: _pillRadius),
      for (var i = 0; i < 5; i++) const _SkeletonCardRow(),
    ];
  }
}

/// A small uppercase section label (kit `SectionLabel`).
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: MxSpacing.space1),
      child: MxSectionLabel(text: text, uppercase: true),
    );
  }
}

/// Bounds a centered full-screen state (empty/error/no-results) inside the
/// scrolling body so [MxEmptyState]'s Center has a finite height.
class _StateBox extends StatelessWidget {
  const _StateBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: _stateBoxHeight, child: child);
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      icon: Icons.error_outline,
      tone: MxIconTileTone.error,
      title: l10n.deckDetailErrorTitle,
      text: l10n.deckDetailErrorText,
      action: MxButton(
        label: l10n.actionRetry,
        icon: Icons.refresh,
        onPressed: onRetry,
      ),
    );
  }
}

class _SkeletonCardRow extends StatelessWidget {
  const _SkeletonCardRow();

  @override
  Widget build(BuildContext context) {
    return const MxCard(
      padding: MxCardPadding.small,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxSkeleton(widthFactor: 0.4, height: 16),
                SizedBox(height: MxSpacing.space2),
                MxSkeleton(widthFactor: 0.62, height: 10),
              ],
            ),
          ),
          SizedBox(width: MxSpacing.space3),
          MxSkeleton(width: 56, height: 22, radius: _pillRadius),
        ],
      ),
    );
  }
}
