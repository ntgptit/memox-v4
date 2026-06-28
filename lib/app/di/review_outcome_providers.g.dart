// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_outcome_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for review-outcome recording (W9 accuracy stats).

@ProviderFor(reviewOutcomeRepository)
final reviewOutcomeRepositoryProvider = ReviewOutcomeRepositoryProvider._();

/// Composition root for review-outcome recording (W9 accuracy stats).

final class ReviewOutcomeRepositoryProvider
    extends
        $FunctionalProvider<
          ReviewOutcomeRepository,
          ReviewOutcomeRepository,
          ReviewOutcomeRepository
        >
    with $Provider<ReviewOutcomeRepository> {
  /// Composition root for review-outcome recording (W9 accuracy stats).
  ReviewOutcomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewOutcomeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewOutcomeRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReviewOutcomeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReviewOutcomeRepository create(Ref ref) {
    return reviewOutcomeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewOutcomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewOutcomeRepository>(value),
    );
  }
}

String _$reviewOutcomeRepositoryHash() =>
    r'772158e2c93676effc4a7d4c3050fc8e5245ddf0';
