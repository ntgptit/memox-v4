// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Library home state: the active pair's root deck nodes, sorted. Owns the
/// current sort and the deck mutations (`state-management-contract`). Reloads
/// when the active pair changes.

@ProviderFor(LibraryNotifier)
final libraryProvider = LibraryNotifierProvider._();

/// Library home state: the active pair's root deck nodes, sorted. Owns the
/// current sort and the deck mutations (`state-management-contract`). Reloads
/// when the active pair changes.
final class LibraryNotifierProvider
    extends $AsyncNotifierProvider<LibraryNotifier, List<DeckNode>> {
  /// Library home state: the active pair's root deck nodes, sorted. Owns the
  /// current sort and the deck mutations (`state-management-contract`). Reloads
  /// when the active pair changes.
  LibraryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryNotifierHash();

  @$internal
  @override
  LibraryNotifier create() => LibraryNotifier();
}

String _$libraryNotifierHash() => r'e76f17763c9425b6ec4ca1c3b88ca978af274c56';

/// Library home state: the active pair's root deck nodes, sorted. Owns the
/// current sort and the deck mutations (`state-management-contract`). Reloads
/// when the active pair changes.

abstract class _$LibraryNotifier extends $AsyncNotifier<List<DeckNode>> {
  FutureOr<List<DeckNode>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<DeckNode>>, List<DeckNode>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<DeckNode>>, List<DeckNode>>,
              AsyncValue<List<DeckNode>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
