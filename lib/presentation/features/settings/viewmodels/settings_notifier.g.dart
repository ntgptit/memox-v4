// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User settings (kept alive). Persists each change, then refreshes the
/// dashboard goal when the daily goal changes.

@ProviderFor(SettingsNotifier)
final settingsProvider = SettingsNotifierProvider._();

/// User settings (kept alive). Persists each change, then refreshes the
/// dashboard goal when the daily goal changes.
final class SettingsNotifierProvider
    extends $AsyncNotifierProvider<SettingsNotifier, AppSettings> {
  /// User settings (kept alive). Persists each change, then refreshes the
  /// dashboard goal when the daily goal changes.
  SettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsNotifierHash();

  @$internal
  @override
  SettingsNotifier create() => SettingsNotifier();
}

String _$settingsNotifierHash() => r'dfcc2f84f1087104837dd5a0f8404adf41d08d30';

/// User settings (kept alive). Persists each change, then refreshes the
/// dashboard goal when the daily goal changes.

abstract class _$SettingsNotifier extends $AsyncNotifier<AppSettings> {
  FutureOr<AppSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppSettings>, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppSettings>, AppSettings>,
              AsyncValue<AppSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
