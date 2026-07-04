import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/library/providers/library_providers.dart';
import 'package:memox_v4/presentation/features/library/screens/library_screen.dart';
import 'package:memox_v4/presentation/features/library/widgets/library_node_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

import '../../../harness/provider_harness.dart';

Deck _deck(String id, String name, {String? parent}) => (Deck.create(
      id: DeckId(id),
      name: name,
      parentId: parent == null ? null : DeckId(parent),
    ) as Ok<Deck>)
    .value;

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool dark,
    FakeStore? store,
    DeckRepository? deckRepository,
    List<Override> extra = const [],
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness(store: store, deckRepository: deckRepository);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...harness.overrides, ...extra],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('loaded: seeded tree renders nodes + FAB ($theme)', (tester) async {
      await pump(tester, dark: dark);

      expect(find.byType(LibraryNodeCard), findsWidgets);
      expect(find.byType(MxFab), findsOneWidget);
      expect(find.text('Library'), findsOneWidget); // header title
      expect(find.byType(MxEmptyState), findsNothing);
    });

    testWidgets('empty: no decks → empty state, no nodes/FAB ($theme)',
        (tester) async {
      await pump(tester, dark: dark, store: FakeStore());

      expect(find.text('Your library is empty'), findsOneWidget);
      expect(find.text('Create deck'), findsOneWidget);
      expect(find.byType(LibraryNodeCard), findsNothing);
      expect(find.byType(MxFab), findsNothing);
    });

    testWidgets('loading: unresolved read shows skeletons ($theme)',
        (tester) async {
      await pump(
        tester,
        dark: dark,
        deckRepository: _StuckDeckRepository(),
        settle: false,
      );
      await tester.pump();

      expect(find.byType(MxSkeleton), findsWidgets);
      expect(find.byType(LibraryNodeCard), findsNothing);
    });

    testWidgets('error: failed read → localized surface + retry ($theme)',
        (tester) async {
      await pump(
        tester,
        dark: dark,
        deckRepository: _ErroringDeckRepository(),
      );

      expect(find.text("Couldn't load your library"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  }

  testWidgets('New FAB opens the create-deck dialog', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.byType(MxFab));
    await tester.pumpAndSettle();

    expect(find.text('New deck'), findsOneWidget);
    expect(find.text('Deck name'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
  });

  testWidgets('sort sheet opens from the context bar', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.byIcon(Icons.swap_vert));
    await tester.pumpAndSettle();

    expect(find.text('Alphabetical A–Z'), findsOneWidget);
    expect(find.text('Alphabetical Z–A'), findsOneWidget);
  });

  testWidgets('overflow sheet opens from the header', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Import cards'), findsOneWidget);
    expect(find.text('Export cards'), findsOneWidget);
  });

  test('createDeck persists a new root deck and refreshes the tree', () async {
    final harness = FakeHarness(store: FakeStore()); // empty library
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    final before = await container.read(libraryControllerProvider.future);
    expect(before.nodes, isEmpty);

    await container
        .read(libraryControllerProvider.notifier)
        .createDeck('Korean Basics');

    final after = await container.read(libraryControllerProvider.future);
    expect(after.nodes.map((n) => n.name), ['Korean Basics']);
    expect(after.nodes.single.isFolder, isFalse); // a leaf deck, not a folder
  });

  test('library sort orders nodes by name, reversing on desc', () async {
    final store = FakeStore();
    for (final deck in [_deck('b', 'Beta'), _deck('a', 'Alpha')]) {
      store.decks[deck.id.value] = deck;
    }
    final harness = FakeHarness(store: store);
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    final asc = await container.read(libraryControllerProvider.future);
    expect(asc.nodes.map((n) => n.name).toList(), ['Alpha', 'Beta']);

    container.read(librarySortProvider.notifier).select(LibrarySortOrder.alphaDesc);
    final desc = await container.read(libraryControllerProvider.future);
    expect(desc.nodes.map((n) => n.name).toList(), ['Beta', 'Alpha']);
  });
}

/// Never completes its tree stream → the provider stays loading.
class _StuckDeckRepository implements DeckRepository {
  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) =>
      Stream.fromFuture(Completer<List<Deck>>().future);
  @override
  Future<Result<Deck>> getById(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<DeckStats>> statsFor(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<Deck>> save(Deck deck) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(DeckId id) => throw UnimplementedError();
}

/// Errors its tree stream → the provider surfaces an error.
class _ErroringDeckRepository implements DeckRepository {
  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) =>
      Stream.error(const PersistenceFailure('deck read failed'));
  @override
  Future<Result<Deck>> getById(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<DeckStats>> statsFor(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<Deck>> save(Deck deck) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(DeckId id) => throw UnimplementedError();
}
