// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for the deck slice. Presentation reads the repository
/// provider (a domain type); it never imports `data` directly.

@ProviderFor(deckDao)
final deckDaoProvider = DeckDaoProvider._();

/// Composition root for the deck slice. Presentation reads the repository
/// provider (a domain type); it never imports `data` directly.

final class DeckDaoProvider
    extends $FunctionalProvider<DeckDao, DeckDao, DeckDao>
    with $Provider<DeckDao> {
  /// Composition root for the deck slice. Presentation reads the repository
  /// provider (a domain type); it never imports `data` directly.
  DeckDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckDaoHash();

  @$internal
  @override
  $ProviderElement<DeckDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeckDao create(Ref ref) {
    return deckDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeckDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeckDao>(value),
    );
  }
}

String _$deckDaoHash() => r'31510c94feed9d27b314fdff379731afdd9de90f';

@ProviderFor(deckRepository)
final deckRepositoryProvider = DeckRepositoryProvider._();

final class DeckRepositoryProvider
    extends $FunctionalProvider<DeckRepository, DeckRepository, DeckRepository>
    with $Provider<DeckRepository> {
  DeckRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeckRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeckRepository create(Ref ref) {
    return deckRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeckRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeckRepository>(value),
    );
  }
}

String _$deckRepositoryHash() => r'0ec86deeb2546021bc88740699b8f484a078bff1';
