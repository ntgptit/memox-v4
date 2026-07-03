import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/deck.dart';

import 'provider_harness.dart';

/// A stand-in for a Phase S screen: a ConsumerWidget that reads a data-layer
/// provider. It renders purely on the fakes supplied by [FakeHarness] — proving a
/// screen can be built + tested before Drift exists.
class _DeckRootsView extends ConsumerWidget {
  const _DeckRootsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(deckRepositoryProvider);
    return Scaffold(
      body: StreamBuilder<List<Deck>>(
        stream: decks.watchChildren(null),
        builder: (context, snapshot) {
          final roots = snapshot.data ?? const [];
          return Center(child: Text('roots: ${roots.length}'));
        },
      ),
    );
  }
}

void main() {
  testWidgets('a screen renders against the fake providers (seeded state)', (
    tester,
  ) async {
    await pumpWithFakes(tester, const _DeckRootsView());
    expect(find.text('roots: 1'), findsOneWidget);
  });

  testWidgets('overriding a provider throws without the harness', (tester) async {
    // The bare provider must be overridden — proves the DI seam is enforced.
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            ref.watch(deckRepositoryProvider);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    // Riverpod wraps the creation error; the underlying cause is our guard.
    expect(tester.takeException().toString(), contains('must be overridden'));
  });
}
