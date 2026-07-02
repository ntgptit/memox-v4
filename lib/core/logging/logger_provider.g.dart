// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app [AppLogger]. Features/services read it via `ref.watch(loggerProvider)`
/// — never construct a logger directly. Override in tests to capture output.

@ProviderFor(logger)
final loggerProvider = LoggerProvider._();

/// The app [AppLogger]. Features/services read it via `ref.watch(loggerProvider)`
/// — never construct a logger directly. Override in tests to capture output.

final class LoggerProvider
    extends $FunctionalProvider<AppLogger, AppLogger, AppLogger>
    with $Provider<AppLogger> {
  /// The app [AppLogger]. Features/services read it via `ref.watch(loggerProvider)`
  /// — never construct a logger directly. Override in tests to capture output.
  LoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerHash();

  @$internal
  @override
  $ProviderElement<AppLogger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLogger create(Ref ref) {
    return logger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLogger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLogger>(value),
    );
  }
}

String _$loggerHash() => r'2c18c922e55fa604ac2b502943703766c0028cee';
