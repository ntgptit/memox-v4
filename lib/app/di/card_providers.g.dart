// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for the flashcard slice. Presentation reads the repository
/// provider (a domain type); it never imports `data` directly.

@ProviderFor(cardDao)
final cardDaoProvider = CardDaoProvider._();

/// Composition root for the flashcard slice. Presentation reads the repository
/// provider (a domain type); it never imports `data` directly.

final class CardDaoProvider
    extends $FunctionalProvider<CardDao, CardDao, CardDao>
    with $Provider<CardDao> {
  /// Composition root for the flashcard slice. Presentation reads the repository
  /// provider (a domain type); it never imports `data` directly.
  CardDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardDaoHash();

  @$internal
  @override
  $ProviderElement<CardDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CardDao create(Ref ref) {
    return cardDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardDao>(value),
    );
  }
}

String _$cardDaoHash() => r'de4345faa7b6d4549d34f48bfd377ce49524e086';

@ProviderFor(cardRepository)
final cardRepositoryProvider = CardRepositoryProvider._();

final class CardRepositoryProvider
    extends $FunctionalProvider<CardRepository, CardRepository, CardRepository>
    with $Provider<CardRepository> {
  CardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardRepositoryHash();

  @$internal
  @override
  $ProviderElement<CardRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CardRepository create(Ref ref) {
    return cardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardRepository>(value),
    );
  }
}

String _$cardRepositoryHash() => r'db14a3241b2cf3a84f67be3cec0320d4c98620e1';
