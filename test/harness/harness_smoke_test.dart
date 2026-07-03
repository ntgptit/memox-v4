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

  testWidgets('an override-only service throws without the harness', (tester) async {
    // Repositories now default to their Drift impls (DT.5); the device/plugin
    // services stay override-only until DT.7, so a bare read must throw — proving
    // the DI seam is still enforced for them.
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            ref.watch(audioServiceProvider);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    // Riverpod wraps the creation error; the underlying cause is our guard.
    expect(tester.takeException().toString(), contains('must be overridden'));
  });
}
