// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for the search slice.

@ProviderFor(searchDao)
final searchDaoProvider = SearchDaoProvider._();

/// Composition root for the search slice.

final class SearchDaoProvider
    extends $FunctionalProvider<SearchDao, SearchDao, SearchDao>
    with $Provider<SearchDao> {
  /// Composition root for the search slice.
  SearchDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchDaoHash();

  @$internal
  @override
  $ProviderElement<SearchDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchDao create(Ref ref) {
    return searchDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchDao>(value),
    );
  }
}

String _$searchDaoHash() => r'847927c1c67c72b6def417f99a306569fd1dff05';

@ProviderFor(searchRepository)
final searchRepositoryProvider = SearchRepositoryProvider._();

final class SearchRepositoryProvider
    extends
        $FunctionalProvider<
          SearchRepository,
          SearchRepository,
          SearchRepository
        >
    with $Provider<SearchRepository> {
  SearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchRepository create(Ref ref) {
    return searchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRepository>(value),
    );
  }
}

String _$searchRepositoryHash() => r'b7fd8abfc54bb5f40feb403089e0a40eab0522ba';
