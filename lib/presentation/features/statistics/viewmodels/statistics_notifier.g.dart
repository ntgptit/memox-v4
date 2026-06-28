// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The selected statistics scope (current pair vs whole app).

@ProviderFor(StatsScopeNotifier)
final statsScopeProvider = StatsScopeNotifierProvider._();

/// The selected statistics scope (current pair vs whole app).
final class StatsScopeNotifierProvider
    extends $NotifierProvider<StatsScopeNotifier, StatsScope> {
  /// The selected statistics scope (current pair vs whole app).
  StatsScopeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsScopeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsScopeNotifierHash();

  @$internal
  @override
  StatsScopeNotifier create() => StatsScopeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsScope value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsScope>(value),
    );
  }
}

String _$statsScopeNotifierHash() =>
    r'3f7a17c60713fe4a8fd90bed5e73baec54bfb62c';

/// The selected statistics scope (current pair vs whole app).

abstract class _$StatsScopeNotifier extends $Notifier<StatsScope> {
  StatsScope build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StatsScope, StatsScope>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StatsScope, StatsScope>,
              StatsScope,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The statistics summary for a scope (autoDispose family — switching scope
/// discards the previous computation).

@ProviderFor(Statistics)
final statisticsProvider = StatisticsFamily._();

/// The statistics summary for a scope (autoDispose family — switching scope
/// discards the previous computation).
final class StatisticsProvider
    extends $AsyncNotifierProvider<Statistics, StatisticsSummary> {
  /// The statistics summary for a scope (autoDispose family — switching scope
  /// discards the previous computation).
  StatisticsProvider._({
    required StatisticsFamily super.from,
    required StatsScope super.argument,
  }) : super(
         retry: null,
         name: r'statisticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$statisticsHash();

  @override
  String toString() {
    return r'statisticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Statistics create() => Statistics();

  @override
  bool operator ==(Object other) {
    return other is StatisticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$statisticsHash() => r'273aa82dce513574cd256810767558954a237139';

/// The statistics summary for a scope (autoDispose family — switching scope
/// discards the previous computation).

final class StatisticsFamily extends $Family
    with
        $ClassFamilyOverride<
          Statistics,
          AsyncValue<StatisticsSummary>,
          StatisticsSummary,
          FutureOr<StatisticsSummary>,
          StatsScope
        > {
  StatisticsFamily._()
    : super(
        retry: null,
        name: r'statisticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The statistics summary for a scope (autoDispose family — switching scope
  /// discards the previous computation).

  StatisticsProvider call(StatsScope scope) =>
      StatisticsProvider._(argument: scope, from: this);

  @override
  String toString() => r'statisticsProvider';
}

/// The statistics summary for a scope (autoDispose family — switching scope
/// discards the previous computation).

abstract class _$Statistics extends $AsyncNotifier<StatisticsSummary> {
  late final _$args = ref.$arg as StatsScope;
  StatsScope get scope => _$args;

  FutureOr<StatisticsSummary> build(StatsScope scope);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<StatisticsSummary>, StatisticsSummary>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StatisticsSummary>, StatisticsSummary>,
              AsyncValue<StatisticsSummary>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
