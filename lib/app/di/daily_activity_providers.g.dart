// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_activity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for the daily-activity slice (used by study finalize, W4;
/// the Today dashboard reads it in W11).

@ProviderFor(dailyActivityDao)
final dailyActivityDaoProvider = DailyActivityDaoProvider._();

/// Composition root for the daily-activity slice (used by study finalize, W4;
/// the Today dashboard reads it in W11).

final class DailyActivityDaoProvider
    extends
        $FunctionalProvider<
          DailyActivityDao,
          DailyActivityDao,
          DailyActivityDao
        >
    with $Provider<DailyActivityDao> {
  /// Composition root for the daily-activity slice (used by study finalize, W4;
  /// the Today dashboard reads it in W11).
  DailyActivityDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyActivityDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyActivityDaoHash();

  @$internal
  @override
  $ProviderElement<DailyActivityDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DailyActivityDao create(Ref ref) {
    return dailyActivityDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailyActivityDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailyActivityDao>(value),
    );
  }
}

String _$dailyActivityDaoHash() => r'9b75487ef9b4e1edd5e3b05e07512d32bcc75253';

@ProviderFor(dailyActivityRepository)
final dailyActivityRepositoryProvider = DailyActivityRepositoryProvider._();

final class DailyActivityRepositoryProvider
    extends
        $FunctionalProvider<
          DailyActivityRepository,
          DailyActivityRepository,
          DailyActivityRepository
        >
    with $Provider<DailyActivityRepository> {
  DailyActivityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyActivityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyActivityRepositoryHash();

  @$internal
  @override
  $ProviderElement<DailyActivityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DailyActivityRepository create(Ref ref) {
    return dailyActivityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailyActivityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailyActivityRepository>(value),
    );
  }
}

String _$dailyActivityRepositoryHash() =>
    r'7cffe90ffb83ececc1d70ac15691c175da58227c';
