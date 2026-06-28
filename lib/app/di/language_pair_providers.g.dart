// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_pair_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for the language-pair slice. Wires the Drift DAO and the
/// repository implementation behind the domain interface. Presentation reads the
/// repository provider (a domain type) and never imports `data` directly.

@ProviderFor(languagePairDao)
final languagePairDaoProvider = LanguagePairDaoProvider._();

/// Composition root for the language-pair slice. Wires the Drift DAO and the
/// repository implementation behind the domain interface. Presentation reads the
/// repository provider (a domain type) and never imports `data` directly.

final class LanguagePairDaoProvider
    extends
        $FunctionalProvider<LanguagePairDao, LanguagePairDao, LanguagePairDao>
    with $Provider<LanguagePairDao> {
  /// Composition root for the language-pair slice. Wires the Drift DAO and the
  /// repository implementation behind the domain interface. Presentation reads the
  /// repository provider (a domain type) and never imports `data` directly.
  LanguagePairDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languagePairDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languagePairDaoHash();

  @$internal
  @override
  $ProviderElement<LanguagePairDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LanguagePairDao create(Ref ref) {
    return languagePairDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LanguagePairDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LanguagePairDao>(value),
    );
  }
}

String _$languagePairDaoHash() => r'7f83666fd8c28afed5d11c244994209e3e6ec9dd';

@ProviderFor(languagePairRepository)
final languagePairRepositoryProvider = LanguagePairRepositoryProvider._();

final class LanguagePairRepositoryProvider
    extends
        $FunctionalProvider<
          LanguagePairRepository,
          LanguagePairRepository,
          LanguagePairRepository
        >
    with $Provider<LanguagePairRepository> {
  LanguagePairRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languagePairRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languagePairRepositoryHash();

  @$internal
  @override
  $ProviderElement<LanguagePairRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LanguagePairRepository create(Ref ref) {
    return languagePairRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LanguagePairRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LanguagePairRepository>(value),
    );
  }
}

String _$languagePairRepositoryHash() =>
    r'653321ad17fda40acf9e21d27fc738430f54713a';
