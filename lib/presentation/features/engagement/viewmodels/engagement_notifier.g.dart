// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engagement_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Today dashboard state (kept alive). Composes daily activity (W4), the goal
/// (settings), the streak (D-021), and the library's due/mastered snapshot.

@ProviderFor(EngagementNotifier)
final engagementProvider = EngagementNotifierProvider._();

/// Today dashboard state (kept alive). Composes daily activity (W4), the goal
/// (settings), the streak (D-021), and the library's due/mastered snapshot.
final class EngagementNotifierProvider
    extends $AsyncNotifierProvider<EngagementNotifier, EngagementSummary> {
  /// Today dashboard state (kept alive). Composes daily activity (W4), the goal
  /// (settings), the streak (D-021), and the library's due/mastered snapshot.
  EngagementNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engagementProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engagementNotifierHash();

  @$internal
  @override
  EngagementNotifier create() => EngagementNotifier();
}

String _$engagementNotifierHash() =>
    r'20a66bdbff395044521a7510c4ff57a7638b7eba';

/// Today dashboard state (kept alive). Composes daily activity (W4), the goal
/// (settings), the streak (D-021), and the library's due/mastered snapshot.

abstract class _$EngagementNotifier extends $AsyncNotifier<EngagementSummary> {
  FutureOr<EngagementSummary> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<EngagementSummary>, EngagementSummary>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EngagementSummary>, EngagementSummary>,
              AsyncValue<EngagementSummary>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
