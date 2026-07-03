import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/data/services/device_services.dart';
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

  test('the seam resolves to real adapters without the harness (DT.5/DT.7)', () {
    // Every seam provider now has a real default: repositories over Drift (DT.5),
    // services over their device adapters (DT.7). The plugin-free audio adapter is
    // a safe probe (no appDatabase / no plugin channel needed).
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(audioServiceProvider), isA<NoopAudioService>());
  });
}
