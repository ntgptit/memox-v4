// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'srs_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for the SRS slice (the W4 study flow consumes these). The
/// study use cases are constructed by their callers with the repository + clock.

@ProviderFor(srsDao)
final srsDaoProvider = SrsDaoProvider._();

/// Composition root for the SRS slice (the W4 study flow consumes these). The
/// study use cases are constructed by their callers with the repository + clock.

final class SrsDaoProvider extends $FunctionalProvider<SrsDao, SrsDao, SrsDao>
    with $Provider<SrsDao> {
  /// Composition root for the SRS slice (the W4 study flow consumes these). The
  /// study use cases are constructed by their callers with the repository + clock.
  SrsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'srsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$srsDaoHash();

  @$internal
  @override
  $ProviderElement<SrsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SrsDao create(Ref ref) {
    return srsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SrsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SrsDao>(value),
    );
  }
}

String _$srsDaoHash() => r'2b376952e2627de83a120a268553733adb0dc60b';

@ProviderFor(srsRepository)
final srsRepositoryProvider = SrsRepositoryProvider._();

final class SrsRepositoryProvider
    extends $FunctionalProvider<SrsRepository, SrsRepository, SrsRepository>
    with $Provider<SrsRepository> {
  SrsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'srsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$srsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SrsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SrsRepository create(Ref ref) {
    return srsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SrsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SrsRepository>(value),
    );
  }
}

String _$srsRepositoryHash() => r'21c03b281b8d31952ebede4560697e881daa8935';
