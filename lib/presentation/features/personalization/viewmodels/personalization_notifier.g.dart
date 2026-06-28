// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personalization_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Theme personalization (kept alive): mode + accent + font scale, persisted via
/// the W12 settings store and applied live by `MemoXApp`.

@ProviderFor(PersonalizationNotifier)
final personalizationProvider = PersonalizationNotifierProvider._();

/// Theme personalization (kept alive): mode + accent + font scale, persisted via
/// the W12 settings store and applied live by `MemoXApp`.
final class PersonalizationNotifierProvider
    extends $AsyncNotifierProvider<PersonalizationNotifier, ThemePrefs> {
  /// Theme personalization (kept alive): mode + accent + font scale, persisted via
  /// the W12 settings store and applied live by `MemoXApp`.
  PersonalizationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalizationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalizationNotifierHash();

  @$internal
  @override
  PersonalizationNotifier create() => PersonalizationNotifier();
}

String _$personalizationNotifierHash() =>
    r'f8f7220faafeb676371d15881a5311f577f4c62b';

/// Theme personalization (kept alive): mode + accent + font scale, persisted via
/// the W12 settings store and applied live by `MemoXApp`.

abstract class _$PersonalizationNotifier extends $AsyncNotifier<ThemePrefs> {
  FutureOr<ThemePrefs> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemePrefs>, ThemePrefs>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemePrefs>, ThemePrefs>,
              AsyncValue<ThemePrefs>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
