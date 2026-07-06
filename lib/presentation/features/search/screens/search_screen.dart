import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/search/providers/search_providers.dart';
import 'package:memox_v4/presentation/features/search/widgets/result_row.dart';
import 'package:memox_v4/presentation/features/search/widgets/search_app_bar.dart';
import 'package:memox_v4/presentation/features/search/widgets/search_chips.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_status_card_row.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_section_label.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// Fixed height for the full-screen hint / no-results / error boxes.
const double _stateBoxHeight = 460;

/// The global search screen (S.04): search cards by word or meaning across every
/// deck (DM.6 `SearchCardsUseCase`, D-019). Renders empty-recent · loading · results ·
/// filtered · no-results · error. The query / filter / recents live in Riverpod
/// (the text-field controller is not app state); no `setState`. Copy is from ARB.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final appBar = SearchAppBar(
      controller: _search,
      onBack: () => context.pop(),
      onChanged: (value) => ref.read(searchQueryProvider.notifier).set(value),
      onClear: _clear,
      showClear: query.trim().isNotEmpty,
    );

    if (query.trim().isEmpty) {
      return MxScaffold(appBar: appBar, children: _recentOrHint());
    }

    final async = ref.watch(searchResultsProvider);
    return async.when(
      loading: () => MxScaffold(appBar: appBar, children: _loadingBody()),
      error: (_, _) => MxScaffold(
        appBar: appBar,
        children: [
          SizedBox(
            height: _stateBoxHeight,
            child: _ErrorBody(
              onRetry: () => ref.invalidate(searchResultsProvider),
            ),
          ),
        ],
      ),
      data: (results) => _results(appBar, results, query),
    );
  }

  Widget _results(
    SearchAppBar appBar,
    List<SearchResult> results,
    String query,
  ) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(searchFilterStateProvider);
    final visible = results.where((r) => _matches(r, filter)).toList();

    return MxScaffold(
      appBar: appBar,
      children: [
        SearchChips(
          active: filter,
          onSelect: (f) =>
              ref.read(searchFilterStateProvider.notifier).select(f),
        ),
        if (visible.isEmpty)
          SizedBox(
            height: _stateBoxHeight,
            child: MxEmptyState(
              icon: Icons.search_off,
              tone: MxIconTileTone.warning,
              title: l10n.searchNoResultsTitle,
              text: l10n.searchNoResultsText(query),
            ),
          ),
        for (final result in visible)
          MxCard(
            padding: MxCardPadding.small,
            onPressed: () => context.push(Routes.editCard(result.cardId.value)),
            child: ResultRow(result: result),
          ),
      ],
    );
  }

  bool _matches(SearchResult result, SearchFilter filter) {
    return switch (filter) {
      SearchFilter.all => true,
      SearchFilter.newCards => result.status == MxCardStatus.newCard,
      SearchFilter.due => result.status == MxCardStatus.due,
      SearchFilter.mastered => result.status == MxCardStatus.mastered,
    };
  }

  List<Widget> _recentOrHint() {
    final l10n = AppLocalizations.of(context);
    final recents = ref.watch(recentSearchesProvider);

    if (recents.isEmpty) {
      return [
        SizedBox(
          height: _stateBoxHeight,
          child: MxEmptyState(
            icon: Icons.search,
            title: l10n.searchHintTitle,
            text: l10n.searchHintText,
          ),
        ),
      ];
    }

    return [
      _Label(l10n.searchRecentLabel),
      MxCard(
        padding: MxCardPadding.small,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (index, term) in recents.indexed)
              MxListRow(
                icon: Icons.history,
                title: term,
                last: index == recents.length - 1,
                onPressed: () => _fill(term),
                trailing: MxIconButton(
                  icon: Icons.north_west,
                  semanticLabel: l10n.searchRecentFill,
                  size: MxIconButtonSize.small,
                  onPressed: () => _fill(term),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  void _fill(String term) {
    _search.text = term;
    ref.read(searchQueryProvider.notifier).set(term);
  }

  void _clear() {
    ref
        .read(recentSearchesProvider.notifier)
        .add(ref.read(searchQueryProvider));
    _search.clear();
    ref.read(searchQueryProvider.notifier).clear();
  }

  List<Widget> _loadingBody() {
    return [
      SearchChips(
        active: ref.watch(searchFilterStateProvider),
        onSelect: (f) => ref.read(searchFilterStateProvider.notifier).select(f),
      ),
      for (var i = 0; i < 3; i++) const _SkeletonResultRow(),
    ];
  }
}

/// A small uppercase section label (kit `RECENT`).
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: MxSpacing.space1),
      child: MxSectionLabel(text: text, uppercase: true),
    );
  }
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
      title: l10n.searchErrorTitle,
      text: l10n.searchErrorText,
      action: MxButton(
        label: l10n.actionRetry,
        icon: Icons.refresh,
        onPressed: onRetry,
      ),
    );
  }
}

class _SkeletonResultRow extends StatelessWidget {
  const _SkeletonResultRow();

  @override
  Widget build(BuildContext context) {
    return const MxCard(
      padding: MxCardPadding.small,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxSkeleton(widthFactor: 0.4, height: 16),
          SizedBox(height: MxSpacing.space2),
          MxSkeleton(widthFactor: 0.62, height: 10),
          SizedBox(height: MxSpacing.space2),
          MxSkeleton(widthFactor: 0.5, height: 10),
        ],
      ),
    );
  }
}
