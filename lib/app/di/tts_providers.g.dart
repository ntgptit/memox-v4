// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Text-to-speech for card terms. Tests override with a fake — the real plugin
/// is platform-channel only.

@ProviderFor(ttsService)
final ttsServiceProvider = TtsServiceProvider._();

/// Text-to-speech for card terms. Tests override with a fake — the real plugin
/// is platform-channel only.

final class TtsServiceProvider
    extends $FunctionalProvider<TtsService, TtsService, TtsService>
    with $Provider<TtsService> {
  /// Text-to-speech for card terms. Tests override with a fake — the real plugin
  /// is platform-channel only.
  TtsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsServiceHash();

  @$internal
  @override
  $ProviderElement<TtsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TtsService create(Ref ref) {
    return ttsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TtsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TtsService>(value),
    );
  }
}

String _$ttsServiceHash() => r'412c4744d3e9761b45a3a7067329a218b8d23b9f';
