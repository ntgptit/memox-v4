// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_export_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for import/export (W8).

@ProviderFor(tableCodec)
final tableCodecProvider = TableCodecProvider._();

/// Composition root for import/export (W8).

final class TableCodecProvider
    extends $FunctionalProvider<TableCodec, TableCodec, TableCodec>
    with $Provider<TableCodec> {
  /// Composition root for import/export (W8).
  TableCodecProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tableCodecProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tableCodecHash();

  @$internal
  @override
  $ProviderElement<TableCodec> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TableCodec create(Ref ref) {
    return tableCodec(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TableCodec value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TableCodec>(value),
    );
  }
}

String _$tableCodecHash() => r'63a9d1fed4b15af55085356ceba10c7e0b578932';

@ProviderFor(fileSaveService)
final fileSaveServiceProvider = FileSaveServiceProvider._();

final class FileSaveServiceProvider
    extends
        $FunctionalProvider<FileSaveService, FileSaveService, FileSaveService>
    with $Provider<FileSaveService> {
  FileSaveServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fileSaveServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fileSaveServiceHash();

  @$internal
  @override
  $ProviderElement<FileSaveService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FileSaveService create(Ref ref) {
    return fileSaveService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileSaveService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileSaveService>(value),
    );
  }
}

String _$fileSaveServiceHash() => r'cfed80dab44ed73f1f1579de8a830cc4687a2ce1';

@ProviderFor(importCards)
final importCardsProvider = ImportCardsProvider._();

final class ImportCardsProvider
    extends
        $FunctionalProvider<
          ImportCardsUseCase,
          ImportCardsUseCase,
          ImportCardsUseCase
        >
    with $Provider<ImportCardsUseCase> {
  ImportCardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importCardsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importCardsHash();

  @$internal
  @override
  $ProviderElement<ImportCardsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImportCardsUseCase create(Ref ref) {
    return importCards(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportCardsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportCardsUseCase>(value),
    );
  }
}

String _$importCardsHash() => r'1ed8f0f6ef144f118e4c3d7a9bce9d4bce6d160f';

@ProviderFor(exportCards)
final exportCardsProvider = ExportCardsProvider._();

final class ExportCardsProvider
    extends
        $FunctionalProvider<
          ExportCardsUseCase,
          ExportCardsUseCase,
          ExportCardsUseCase
        >
    with $Provider<ExportCardsUseCase> {
  ExportCardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportCardsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportCardsHash();

  @$internal
  @override
  $ProviderElement<ExportCardsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExportCardsUseCase create(Ref ref) {
    return exportCards(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportCardsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportCardsUseCase>(value),
    );
  }
}

String _$exportCardsHash() => r'efe0724c8cce91201baa3045c5fbd17dc0920481';
