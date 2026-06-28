// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kept alive so recent searches survive within a session.

@ProviderFor(SearchNotifier)
final searchProvider = SearchNotifierProvider._();

/// Kept alive so recent searches survive within a session.
final class SearchNotifierProvider
    extends $NotifierProvider<SearchNotifier, SearchUiState> {
  /// Kept alive so recent searches survive within a session.
  SearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchNotifierHash();

  @$internal
  @override
  SearchNotifier create() => SearchNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchUiState>(value),
    );
  }
}

String _$searchNotifierHash() => r'a9467738e7dc69d052b0dc66f8604b5c638a3645';

/// Kept alive so recent searches survive within a session.

abstract class _$SearchNotifier extends $Notifier<SearchUiState> {
  SearchUiState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchUiState, SearchUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchUiState, SearchUiState>,
              SearchUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
