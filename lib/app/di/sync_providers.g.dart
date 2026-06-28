// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for Google Drive sync (W10).
///
/// [cloudSyncConfig] carries the OAuth client id; it ships empty (the HUMAN GAP)
/// so the service stays inert until configured — override this provider (e.g.
/// from `--dart-define`) to enable real sync.

@ProviderFor(cloudSyncConfig)
final cloudSyncConfigProvider = CloudSyncConfigProvider._();

/// Composition root for Google Drive sync (W10).
///
/// [cloudSyncConfig] carries the OAuth client id; it ships empty (the HUMAN GAP)
/// so the service stays inert until configured — override this provider (e.g.
/// from `--dart-define`) to enable real sync.

final class CloudSyncConfigProvider
    extends
        $FunctionalProvider<CloudSyncConfig, CloudSyncConfig, CloudSyncConfig>
    with $Provider<CloudSyncConfig> {
  /// Composition root for Google Drive sync (W10).
  ///
  /// [cloudSyncConfig] carries the OAuth client id; it ships empty (the HUMAN GAP)
  /// so the service stays inert until configured — override this provider (e.g.
  /// from `--dart-define`) to enable real sync.
  CloudSyncConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudSyncConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudSyncConfigHash();

  @$internal
  @override
  $ProviderElement<CloudSyncConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CloudSyncConfig create(Ref ref) {
    return cloudSyncConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudSyncConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudSyncConfig>(value),
    );
  }
}

String _$cloudSyncConfigHash() => r'bd40b72063b672c875e4241ae20dc891b2794010';

@ProviderFor(cloudSyncService)
final cloudSyncServiceProvider = CloudSyncServiceProvider._();

final class CloudSyncServiceProvider
    extends
        $FunctionalProvider<
          CloudSyncService,
          CloudSyncService,
          CloudSyncService
        >
    with $Provider<CloudSyncService> {
  CloudSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudSyncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudSyncServiceHash();

  @$internal
  @override
  $ProviderElement<CloudSyncService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CloudSyncService create(Ref ref) {
    return cloudSyncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudSyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudSyncService>(value),
    );
  }
}

String _$cloudSyncServiceHash() => r'9aaefa6893bb62f63480f913c71d12ad74b05f7c';

@ProviderFor(syncNow)
final syncNowProvider = SyncNowProvider._();

final class SyncNowProvider
    extends $FunctionalProvider<SyncNowUseCase, SyncNowUseCase, SyncNowUseCase>
    with $Provider<SyncNowUseCase> {
  SyncNowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncNowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncNowHash();

  @$internal
  @override
  $ProviderElement<SyncNowUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncNowUseCase create(Ref ref) {
    return syncNow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncNowUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncNowUseCase>(value),
    );
  }
}

String _$syncNowHash() => r'd90a6512f04141e1b243d63165f16336e8f54082';
