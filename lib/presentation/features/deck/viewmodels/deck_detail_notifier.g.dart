// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deck-detail state for one deck id. Mutations refresh this view and invalidate
/// the library so its recursive counts stay in sync.

@ProviderFor(DeckDetailNotifier)
final deckDetailProvider = DeckDetailNotifierFamily._();

/// Deck-detail state for one deck id. Mutations refresh this view and invalidate
/// the library so its recursive counts stay in sync.
final class DeckDetailNotifierProvider
    extends $AsyncNotifierProvider<DeckDetailNotifier, DeckDetailState> {
  /// Deck-detail state for one deck id. Mutations refresh this view and invalidate
  /// the library so its recursive counts stay in sync.
  DeckDetailNotifierProvider._({
    required DeckDetailNotifierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'deckDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deckDetailNotifierHash();

  @override
  String toString() {
    return r'deckDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeckDetailNotifier create() => DeckDetailNotifier();

  @override
  bool operator ==(Object other) {
    return other is DeckDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deckDetailNotifierHash() =>
    r'bc37629bfa7cb595142f1db6344648fa1eee955a';

/// Deck-detail state for one deck id. Mutations refresh this view and invalidate
/// the library so its recursive counts stay in sync.

final class DeckDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          DeckDetailNotifier,
          AsyncValue<DeckDetailState>,
          DeckDetailState,
          FutureOr<DeckDetailState>,
          int
        > {
  DeckDetailNotifierFamily._()
    : super(
        retry: null,
        name: r'deckDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Deck-detail state for one deck id. Mutations refresh this view and invalidate
  /// the library so its recursive counts stay in sync.

  DeckDetailNotifierProvider call(int deckId) =>
      DeckDetailNotifierProvider._(argument: deckId, from: this);

  @override
  String toString() => r'deckDetailProvider';
}

/// Deck-detail state for one deck id. Mutations refresh this view and invalidate
/// the library so its recursive counts stay in sync.

abstract class _$DeckDetailNotifier extends $AsyncNotifier<DeckDetailState> {
  late final _$args = ref.$arg as int;
  int get deckId => _$args;

  FutureOr<DeckDetailState> build(int deckId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DeckDetailState>, DeckDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DeckDetailState>, DeckDetailState>,
              AsyncValue<DeckDetailState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
