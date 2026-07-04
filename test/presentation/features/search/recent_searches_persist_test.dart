import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/data/fakes/fake_services.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/presentation/features/search/providers/search_providers.dart';

/// Lets the async seed / persist futures settle.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

ProviderContainer _container(FakeRecentSearchService service) {
  final container = ProviderContainer(
    // RecentSearches only reads the recent-search service (+ the real logger).
    overrides: [recentSearchServiceProvider.overrideWithValue(service)],
  );
  addTearDown(container.dispose);
  final sub = container.listen(recentSearchesProvider, (_, _) {});
  addTearDown(sub.close);
  return container;
}

void main() {
  test('recent searches seed from the persisted store on build', () async {
    final service = FakeRecentSearchService();
    await service.save(['가방', '학교']);

    final container = _container(service);
    await _settle();

    expect(container.read(recentSearchesProvider), ['가방', '학교']);
  });

  test('add persists the recent searches across the store', () async {
    final service = FakeRecentSearchService();
    final container = _container(service);
    await _settle(); // initial (empty) seed

    container.read(recentSearchesProvider.notifier).add('사랑');
    await _settle(); // persist

    expect(container.read(recentSearchesProvider), ['사랑']);
    expect(await service.load(), ['사랑']);
  });
}
