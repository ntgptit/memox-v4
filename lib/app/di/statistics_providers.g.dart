// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for statistics reads (W9).

@ProviderFor(statsDao)
final statsDaoProvider = StatsDaoProvider._();

/// Composition root for statistics reads (W9).

final class StatsDaoProvider
    extends $FunctionalProvider<StatsDao, StatsDao, StatsDao>
    with $Provider<StatsDao> {
  /// Composition root for statistics reads (W9).
  StatsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsDaoHash();

  @$internal
  @override
  $ProviderElement<StatsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsDao create(Ref ref) {
    return statsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsDao>(value),
    );
  }
}

String _$statsDaoHash() => r'a5783113a10b6897242758cb7721a49ca08472b9';

@ProviderFor(statisticsRepository)
final statisticsRepositoryProvider = StatisticsRepositoryProvider._();

final class StatisticsRepositoryProvider
    extends
        $FunctionalProvider<
          StatisticsRepository,
          StatisticsRepository,
          StatisticsRepository
        >
    with $Provider<StatisticsRepository> {
  StatisticsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statisticsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statisticsRepositoryHash();

  @$internal
  @override
  $ProviderElement<StatisticsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StatisticsRepository create(Ref ref) {
    return statisticsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatisticsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatisticsRepository>(value),
    );
  }
}

String _$statisticsRepositoryHash() =>
    r'62c1a6b0b97df9a5e676496162c8de256627b52e';
