import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/models/search_result.dart';
import 'package:memox_v4/domain/types/card_status.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/search/viewmodels/search_notifier.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_chip.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/states/mx_state_view.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_scaffold.dart';

/// Global search by term + meaning, with status filter chips (`15-search.md`).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  SearchNotifier get _notifier => ref.read(searchProvider.notifier);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(searchProvider);
    final now = ref.read(clockProvider).now().millisecondsSinceEpoch;
    return MxScaffold(
      key: const ValueKey('mx-node:search/screen'),
      flush: true,
      appBar: AppBar(
        key: const ValueKey('mx-node:search/appbar'),
        title: TextField(
          key: const ValueKey('mx-node:search/dock'),
          controller: _controller,
          autofocus: true,
          onChanged: (value) => unawaited(_notifier.search(value)),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            suffixIcon: state.query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _notifier.clear();
                    },
                  ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          _filterChips(l10n, state),
          Expanded(child: _body(l10n, state, now)),
        ],
      ),
    );
  }

  Widget _filterChips(AppLocalizations l10n, SearchUiState state) {
    Widget chip(String label, CardStatus? value) => Padding(
      padding: const EdgeInsets.only(right: MxSpacing.space2),
      child: MxChip(
        label: label,
        selected: state.filter == value,
        onTap: () => _notifier.setFilter(value),
      ),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.space4,
        vertical: MxSpacing.space2,
      ),
      child: Row(
        children: <Widget>[
          chip(l10n.searchFilterAll, null),
          chip(l10n.cardStatusNew, CardStatus.newCard),
          chip(l10n.cardStatusDue, CardStatus.due),
          chip(l10n.cardStatusMastered, CardStatus.mastered),
        ],
      ),
    );
  }

  Widget _body(AppLocalizations l10n, SearchUiState state, int now) {
    if (state.searching) {
      return const MxStateView.loading();
    }
    if (state.query.trim().isEmpty) return _recent(l10n, state);
    final filtered = <SearchResult>[
      for (final result in state.results)
        if (state.filter == null || result.status(now) == state.filter) result,
    ];
    if (filtered.isEmpty) {
      return MxContentBounds(
        child: Center(child: MxText(l10n.searchNoResults(state.query.trim()))),
      );
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) => _resultTile(l10n, filtered[index], now),
    );
  }

  Widget _resultTile(
    AppLocalizations l10n,
    SearchResult result,
    int now,
  ) => Opacity(
    opacity: result.hidden ? 0.5 : 1,
    child: ListTile(
      key: Key('searchResult-${result.cardId}'),
      leading: result.hidden ? const Icon(Icons.visibility_off_outlined) : null,
      title: Text(result.term, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${result.meaning} · ${result.deckName}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: MxText(
        _statusLabel(l10n, result.status(now)),
        role: MxTextRole.labelSmall,
      ),
      onTap: () => unawaited(
        context.push(
          RoutePaths.flashcardEditorLocation(
            result.deckId,
            cardId: result.cardId,
          ),
        ),
      ),
    ),
  );

  Widget _recent(AppLocalizations l10n, SearchUiState state) {
    if (state.recent.isEmpty) {
      return MxContentBounds(child: Center(child: MxText(l10n.searchHint)));
    }
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MxSpacing.space5,
            MxSpacing.space4,
            MxSpacing.space5,
            MxSpacing.space1,
          ),
          child: MxText.label(l10n.searchRecent),
        ),
        for (final query in state.recent)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            onTap: () {
              _controller.text = query;
              unawaited(_notifier.search(query));
            },
          ),
      ],
    );
  }

  String _statusLabel(AppLocalizations l10n, CardStatus status) =>
      switch (status) {
        CardStatus.newCard => l10n.cardStatusNew,
        CardStatus.due => l10n.cardStatusDue,
        CardStatus.mastered => l10n.cardStatusMastered,
        CardStatus.learning => l10n.cardStatusLearning,
        CardStatus.hidden => '',
      };
}
