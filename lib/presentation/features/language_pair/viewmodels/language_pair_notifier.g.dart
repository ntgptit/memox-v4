// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_pair_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide language-pair context (active pair + display direction), kept alive
/// for the app's lifetime. Orchestrates the language-pair use cases only; holds
/// no business logic and no sole copy of data (`state-management-contract`).

@ProviderFor(LanguagePairNotifier)
final languagePairProvider = LanguagePairNotifierProvider._();

/// App-wide language-pair context (active pair + display direction), kept alive
/// for the app's lifetime. Orchestrates the language-pair use cases only; holds
/// no business logic and no sole copy of data (`state-management-contract`).
final class LanguagePairNotifierProvider
    extends $AsyncNotifierProvider<LanguagePairNotifier, LanguagePairContext> {
  /// App-wide language-pair context (active pair + display direction), kept alive
  /// for the app's lifetime. Orchestrates the language-pair use cases only; holds
  /// no business logic and no sole copy of data (`state-management-contract`).
  LanguagePairNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languagePairProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languagePairNotifierHash();

  @$internal
  @override
  LanguagePairNotifier create() => LanguagePairNotifier();
}

String _$languagePairNotifierHash() =>
    r'570a1b3250f0832c60619bc6f5a917f56c8ba071';

/// App-wide language-pair context (active pair + display direction), kept alive
/// for the app's lifetime. Orchestrates the language-pair use cases only; holds
/// no business logic and no sole copy of data (`state-management-contract`).

abstract class _$LanguagePairNotifier
    extends $AsyncNotifier<LanguagePairContext> {
  FutureOr<LanguagePairContext> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LanguagePairContext>, LanguagePairContext>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LanguagePairContext>, LanguagePairContext>,
              AsyncValue<LanguagePairContext>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
