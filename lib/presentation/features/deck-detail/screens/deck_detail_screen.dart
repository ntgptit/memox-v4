import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck-detail/providers/deck_detail_providers.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/deck_header.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/deck_menu.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/delete_confirm_dialog.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/flashcard_row.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/sub_deck_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_search_dock.dart';
import 'package:memox_v4/presentation/shared/composites/mx_sheet.dart';
import 'package:memox_v4/presentation/shared/composites/status_card_row.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
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

  static const List<MxIconTileTone> _tones = [
    MxIconTileTone.accent,
    MxIconTileTone.success,
    MxIconTileTone.warning,
    MxIconTileTone.primary,
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

    return async.when(
      loading: () => MxScaffold(appBar: _header(''), children: _loadingBody()),
      error: (_, _) => MxScaffold(
        appBar: _header(''),
        children: [
          _StateBox(
            child: _ErrorBody(
              onRetry: () => ref.invalidate(
                deckDetailControllerProvider(widget.deckId),
              ),
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
        onMenu: title.isEmpty ? null : _openDeckMenu,
      );

  Widget _content(DeckDetailData data) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(deckSearchQueryProvider);
    final header = DeckHeader(
      title: data.deckName,
      onBack: () => context.pop(),
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
            )
          else
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
      onChanged: (value) => ref.read(deckSearchQueryProvider.notifier).set(value),
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
    return cards.where((card) {
      if (!_matchesFilter(card, filter)) return false;
      if (needle.isEmpty) return true;
      return card.term.toLowerCase().contains(needle) ||
          card.meaning.toLowerCase().contains(needle);
    }).toList(growable: false);
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

  void _openMove(DeckDetailData data) {
    final l10n = AppLocalizations.of(context);
    final roots = ref.read(rootDecksProvider).value ?? const [];
    showMxSheet<void>(
      context: context,
      title: l10n.deckDetailMoveTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxListRow(
            icon: Icons.home,
            title: l10n.deckDetailMoveRoot,
            onPressed: () {
              Navigator.of(context).pop();
              _controller.moveTo(null);
            },
          ),
          for (final root in roots)
            if (root.id.value != data.deckId.value)
              MxListRow(
                icon: Icons.layers,
                title: root.name,
                onPressed: () {
                  Navigator.of(context).pop();
                  _controller.moveTo(root.id);
                },
              ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteDeck() async {
    final ok = await showDeleteDeckDialog(context);
    if (!ok) return;
    await _controller.deleteDeck();
    if (mounted) context.pop();
  }

  void _openAddMenu() {
    final l10n = AppLocalizations.of(context);
    showMxSheet<void>(
      context: context,
      title: l10n.deckDetailAddTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxListRow(
            icon: Icons.add,
            title: l10n.deckDetailAddWord,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(Routes.add);
            },
          ),
          MxListRow(
            icon: Icons.library_add,
            title: l10n.deckDetailAddSubdeck,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(Routes.add);
            },
          ),
          MxListRow(
            icon: Icons.upload_file,
            title: l10n.deckDetailAddImport,
            last: true,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(Routes.import_);
            },
          ),
        ],
      ),
    );
  }

  void _openCardActions(DeckCardInfo card) {
    final l10n = AppLocalizations.of(context);
    showMxSheet<void>(
      context: context,
      title: card.term,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxListRow(
            icon: Icons.edit,
            title: l10n.deckDetailCardEdit,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(Routes.editCard(card.id.value));
            },
          ),
          MxListRow(
            icon: card.hidden ? Icons.visibility : Icons.visibility_off,
            title: card.hidden ? l10n.deckDetailCardUnhide : l10n.deckDetailCardHide,
            onPressed: () {
              Navigator.of(context).pop();
              _controller.setCardHidden(card.id, hidden: !card.hidden);
            },
          ),
          MxListRow(
            icon: Icons.delete,
            tone: MxIconTileTone.error,
            title: l10n.deckDetailCardDelete,
            last: true,
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
                onPressed: () => context.push(Routes.add),
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
    final mx = MxTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: MxSpacing.space1),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: MxTypography.fontFamily,
          fontSize: MxTypography.sizeSm,
          fontWeight: MxTypography.bold,
          letterSpacing: MxTypography.sizeSm * MxTypography.trackingWide,
          color: mx.textTertiary,
        ),
      ),
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
                MxSkeleton(width: 120, height: 16),
                SizedBox(height: MxSpacing.space2),
                MxSkeleton(width: 180, height: 10),
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
