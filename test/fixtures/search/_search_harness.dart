import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/presentation/features/search/providers/search_providers.dart';

import '../../harness/provider_harness.dart';

// The real search resolves synchronously after the query is set, so there's no
// deterministic loading frame. Override the results provider with a
// never-completing future — the screen's AsyncValue.when lands on its loading
// body (the same stuck-future trick as the dashboard loading skeleton).
List<Override> searchLoadingOverrides() => [
  ...FakeHarness().overrides,
  searchResultsProvider.overrideWith(
    (ref) => Completer<List<SearchResult>>().future,
  ),
];
