import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/library/providers/library_providers.dart';
import 'package:memox_v4/presentation/features/library/widgets/context_bar.dart';
import 'package:memox_v4/presentation/features/library/widgets/library_header.dart';
import 'package:memox_v4/presentation/features/library/widgets/library_node_card.dart';
import 'package:memox_v4/presentation/features/library/widgets/overflow_menu_sheet.dart';
import 'package:memox_v4/presentation/features/library/widgets/pair_picker_sheet.dart';
import 'package:memox_v4/presentation/features/library/widgets/play_sheet.dart';
import 'package:memox_v4/presentation/features/library/widgets/sort_sheet.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_sheet.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// Fixed height for the full-screen empty / error boxes — [MxEmptyState] centers
/// within it, and it is generous enough that the icon + copy + actions never clip.
const double _stateBoxHeight = 460;

/// The Library screen (S.02): the deck tree with sort + language-pair context.
/// Reads DM.6 state through [libraryControllerProvider], rendered with
/// `AsyncValue.when` across loading · empty · loaded · error. State lives in the
/// providers (no `setState`); the sort/pair/overflow/play sheets are modal
/// [showMxSheet]s. Copy is from ARB. (search-active → S.04, drawer → S.06.)
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  /// Empty-state action column width (kit `size-3xl`).
  static const double _actionWidth = MxSizes.size3xl;

  /// Skeleton pill radius for the loading search placeholder.
  static const double _pillRadius = 999;

  static const List<MxIconTileTone> _tones = [
    MxIconTileTone.accent,
    MxIconTileTone.success,
    MxIconTileTone.warning,
    MxIconTileTone.primary,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(libraryControllerProvider);
    final header = LibraryHeader(
      onMenu: () => context.push(Routes.drawer),
      onOverflow: () => _openOverflow(context),
    );

    return async.when(
      loading: () => MxScaffold(appBar: header, children: _loadingBody()),
      error: (_, _) => MxScaffold(
        appBar: header,
        children: [_ErrorBody(onRetry: () => ref.invalidate(libraryControllerProvider))],
      ),
      data: (data) => data.isEmpty
          ? _empty(context, ref, header)
          : _loaded(context, ref, header, data),
    );
  }

  Widget _loaded(
    BuildContext context,
    WidgetRef ref,
    LibraryHeader header,
    LibraryData data,
  ) {
    final l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: header,
      fab: MxFab(
        icon: Icons.add,
        label: l10n.libraryNew,
        onPressed: () => context.push(Routes.add),
      ),
      children: [
        _contextBar(context, ref),
        for (final (index, node) in data.nodes.indexed)
          LibraryNodeCard(
            node: node,
            tone: _tones[index % _tones.length],
            onPressed: () => _openPlay(context, node),
          ),
      ],
    );
  }

  Widget _empty(BuildContext context, WidgetRef ref, LibraryHeader header) {
    final l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: header,
      children: [
        _contextBar(context, ref),
        SizedBox(
          height: _stateBoxHeight,
          child: MxEmptyState(
            icon: Icons.style,
            title: l10n.libraryEmptyTitle,
            text: l10n.libraryEmptyText,
            action: SizedBox(
              width: _actionWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MxButton(
                    label: l10n.libraryCreateDeck,
                    icon: Icons.style,
                    block: true,
                    onPressed: () => context.push(Routes.add),
                  ),
                  const SizedBox(height: MxSpacing.space3),
                  MxButton(
                    label: l10n.libraryAddWords,
                    variant: MxButtonVariant.ghost,
                    icon: Icons.add,
                    block: true,
                    onPressed: () => context.push(Routes.add),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _contextBar(BuildContext context, WidgetRef ref) {
    return ContextBar(
      onSearch: () => context.push(Routes.search),
      onPair: () => _openPair(context, ref),
      onSort: () => _openSort(context, ref),
    );
  }

  // ── Sheets ─────────────────────────────────────────────────────────────────

  void _openOverflow(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showMxSheet<void>(
      context: context,
      title: l10n.librarySheetOverflowTitle,
      child: OverflowMenuSheet(
        onImport: () => context.push(Routes.import_),
        onExport: () => context.push(Routes.export_),
        onSettings: () => context.go(Routes.profile),
      ),
    );
  }

  void _openSort(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showMxSheet<void>(
      context: context,
      title: l10n.librarySheetSortTitle,
      child: SortSheet(
        current: ref.read(librarySortProvider),
        onSelect: (order) => ref.read(librarySortProvider.notifier).select(order),
      ),
    );
  }

  void _openPair(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showMxSheet<void>(
      context: context,
      title: l10n.librarySheetPairTitle,
      child: PairPickerSheet(
        pairs: ref.read(languagePairsProvider).asData?.value ?? const [],
        selectedId: ref.read(selectedLanguagePairIdProvider).asData?.value,
        onSelect: (id) => _selectPair(ref, id),
        onAdd: () => context.go(Routes.profile),
      ),
    );
  }

  void _selectPair(WidgetRef ref, LanguagePairId id) {
    ref.read(languagePairServiceProvider).select(id).then((result) {
      result.fold(
        (_) {},
        (failure) =>
            ref.read(loggerProvider).error('select pair failed', error: failure),
      );
    });
  }

  void _openPlay(BuildContext context, LibraryNode node) {
    showMxSheet<void>(
      context: context,
      title: node.name,
      child: PlaySheet(
        node: node,
        onLearn: () => context.push(Routes.study),
        onReview: () => context.push(Routes.review),
        onBrowse: () => context.go(Routes.deckDetail(node.id.value)),
        onGame: () => context.push(Routes.games),
        onPlayer: () => context.push(Routes.player),
      ),
    );
  }

  // ── Loading skeleton ───────────────────────────────────────────────────────

  List<Widget> _loadingBody() {
    return [
      const MxSkeleton(height: MxSpacing.minTouchTarget, radius: _pillRadius),
      const _SkeletonRow(),
      const _SkeletonRow(),
      const _SkeletonRow(),
      const _SkeletonRow(),
    ];
  }
}

/// Localized error surface for a failed library load (the cause is logged in
/// [libraryControllerProvider]). Offers a retry that re-runs the load.
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: _stateBoxHeight,
      child: MxEmptyState(
        icon: Icons.error_outline,
        tone: MxIconTileTone.error,
        title: l10n.libraryErrorTitle,
        text: l10n.libraryErrorText,
        action: MxButton(
          label: l10n.actionRetry,
          icon: Icons.refresh,
          onPressed: onRetry,
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const MxCard(
      padding: MxCardPadding.small,
      child: Row(
        children: [
          MxSkeleton(width: 48, height: 48, radius: 16),
          SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxSkeleton(width: 150, height: 14),
                SizedBox(height: MxSpacing.space2),
                MxSkeleton(width: 100, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
