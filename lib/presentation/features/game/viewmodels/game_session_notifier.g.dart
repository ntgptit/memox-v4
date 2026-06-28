// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives a practice round. Never touches `srs_state` (D-007): wrong answers
/// re-queue the card within the round (D-015), nothing is scheduled.

@ProviderFor(GameSessionNotifier)
final gameSessionProvider = GameSessionNotifierFamily._();

/// Drives a practice round. Never touches `srs_state` (D-007): wrong answers
/// re-queue the card within the round (D-015), nothing is scheduled.
final class GameSessionNotifierProvider
    extends $AsyncNotifierProvider<GameSessionNotifier, GameSessionState> {
  /// Drives a practice round. Never touches `srs_state` (D-007): wrong answers
  /// re-queue the card within the round (D-015), nothing is scheduled.
  GameSessionNotifierProvider._({
    required GameSessionNotifierFamily super.from,
    required GameRequest super.argument,
  }) : super(
         retry: null,
         name: r'gameSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gameSessionNotifierHash();

  @override
  String toString() {
    return r'gameSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GameSessionNotifier create() => GameSessionNotifier();

  @override
  bool operator ==(Object other) {
    return other is GameSessionNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameSessionNotifierHash() =>
    r'6fb74d4ed6d7f0df8395bf214cf08a18f8978f9d';

/// Drives a practice round. Never touches `srs_state` (D-007): wrong answers
/// re-queue the card within the round (D-015), nothing is scheduled.

final class GameSessionNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          GameSessionNotifier,
          AsyncValue<GameSessionState>,
          GameSessionState,
          FutureOr<GameSessionState>,
          GameRequest
        > {
  GameSessionNotifierFamily._()
    : super(
        retry: null,
        name: r'gameSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives a practice round. Never touches `srs_state` (D-007): wrong answers
  /// re-queue the card within the round (D-015), nothing is scheduled.

  GameSessionNotifierProvider call(GameRequest arg) =>
      GameSessionNotifierProvider._(argument: arg, from: this);

  @override
  String toString() => r'gameSessionProvider';
}

/// Drives a practice round. Never touches `srs_state` (D-007): wrong answers
/// re-queue the card within the round (D-015), nothing is scheduled.

abstract class _$GameSessionNotifier extends $AsyncNotifier<GameSessionState> {
  late final _$args = ref.$arg as GameRequest;
  GameRequest get arg => _$args;

  FutureOr<GameSessionState> build(GameRequest arg);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<GameSessionState>, GameSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GameSessionState>, GameSessionState>,
              AsyncValue<GameSessionState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
