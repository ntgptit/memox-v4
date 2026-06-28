// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives a scheduled session (NewLearn / DueReview). DueReview grades each card
/// into SRS (W3); NewLearn schedules cards into box 1 only after all 5 stages
/// complete (D-002) — quitting before then leaves them new (D-017). Finalize
/// adds activity for these entries only (D-010).

@ProviderFor(StudySessionNotifier)
final studySessionProvider = StudySessionNotifierFamily._();

/// Drives a scheduled session (NewLearn / DueReview). DueReview grades each card
/// into SRS (W3); NewLearn schedules cards into box 1 only after all 5 stages
/// complete (D-002) — quitting before then leaves them new (D-017). Finalize
/// adds activity for these entries only (D-010).
final class StudySessionNotifierProvider
    extends $AsyncNotifierProvider<StudySessionNotifier, StudySessionState> {
  /// Drives a scheduled session (NewLearn / DueReview). DueReview grades each card
  /// into SRS (W3); NewLearn schedules cards into box 1 only after all 5 stages
  /// complete (D-002) — quitting before then leaves them new (D-017). Finalize
  /// adds activity for these entries only (D-010).
  StudySessionNotifierProvider._({
    required StudySessionNotifierFamily super.from,
    required StudyRequest super.argument,
  }) : super(
         retry: null,
         name: r'studySessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studySessionNotifierHash();

  @override
  String toString() {
    return r'studySessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StudySessionNotifier create() => StudySessionNotifier();

  @override
  bool operator ==(Object other) {
    return other is StudySessionNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studySessionNotifierHash() =>
    r'828f786f0f8165f1115ef53e5ea833eb4c15a769';

/// Drives a scheduled session (NewLearn / DueReview). DueReview grades each card
/// into SRS (W3); NewLearn schedules cards into box 1 only after all 5 stages
/// complete (D-002) — quitting before then leaves them new (D-017). Finalize
/// adds activity for these entries only (D-010).

final class StudySessionNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          StudySessionNotifier,
          AsyncValue<StudySessionState>,
          StudySessionState,
          FutureOr<StudySessionState>,
          StudyRequest
        > {
  StudySessionNotifierFamily._()
    : super(
        retry: null,
        name: r'studySessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives a scheduled session (NewLearn / DueReview). DueReview grades each card
  /// into SRS (W3); NewLearn schedules cards into box 1 only after all 5 stages
  /// complete (D-002) — quitting before then leaves them new (D-017). Finalize
  /// adds activity for these entries only (D-010).

  StudySessionNotifierProvider call(StudyRequest arg) =>
      StudySessionNotifierProvider._(argument: arg, from: this);

  @override
  String toString() => r'studySessionProvider';
}

/// Drives a scheduled session (NewLearn / DueReview). DueReview grades each card
/// into SRS (W3); NewLearn schedules cards into box 1 only after all 5 stages
/// complete (D-002) — quitting before then leaves them new (D-017). Finalize
/// adds activity for these entries only (D-010).

abstract class _$StudySessionNotifier
    extends $AsyncNotifier<StudySessionState> {
  late final _$args = ref.$arg as StudyRequest;
  StudyRequest get arg => _$args;

  FutureOr<StudySessionState> build(StudyRequest arg);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<StudySessionState>, StudySessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StudySessionState>, StudySessionState>,
              AsyncValue<StudySessionState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
