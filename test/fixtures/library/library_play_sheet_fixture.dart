// library · play-sheet — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/library/widgets/library_node_card.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// The play sheet (study entry points) for a deck.
final StateFixture libraryPlaySheetFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.tap(find.byType(LibraryNodeCard).first);
  },
);
