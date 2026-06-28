// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$statisticsHash() => r'696094c0585c2706aac46daef6079a1056ede1bf';

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
