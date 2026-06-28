import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/constants/settings_keys.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/domain/repositories/backup_repository.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';
import 'package:memox_v4/domain/services/cloud_sync_service.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/sync.dart';
import 'package:memox_v4/domain/usecases/sync/sync_now.dart';

class _FakeClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 6, 28, 12);
  @override
  DateTime nowUtc() => now().toUtc();
}

class _FakeCloud implements CloudSyncService {
  bool signedIn = true;
  RemoteSnapshotMeta? meta;
  String remoteContent = '{"r":1}';
  String? uploaded;
  bool downloaded = false;
  Failure? signedInError;
  Failure? metaError;
  Failure? downloadError;

  @override
  Future<Result<bool>> isSignedIn() async =>
      signedInError != null ? Err<bool>(signedInError!) : Ok<bool>(signedIn);
  @override
  Future<Result<void>> signIn() async {
    signedIn = true;
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> signOut() async {
    signedIn = false;
    return const Ok<void>(null);
  }

  @override
  Future<Result<RemoteSnapshotMeta?>> remoteMeta() async => metaError != null
      ? Err<RemoteSnapshotMeta?>(metaError!)
      : Ok<RemoteSnapshotMeta?>(meta);
  @override
  Future<Result<void>> upload(String snapshotJson, DateTime modifiedAt) async {
    uploaded = snapshotJson;
    return const Ok<void>(null);
  }

  @override
  Future<Result<String>> download() async {
    downloaded = true;
    return downloadError != null
        ? Err<String>(downloadError!)
        : Ok<String>(remoteContent);
  }
}

class _FakeBackup implements BackupRepository {
  String serialized = '{"local":1}';
  String? restored;
  Failure? serializeError;
  Failure? deserializeError;

  @override
  Future<Result<String>> serialize() async => serializeError != null
      ? Err<String>(serializeError!)
      : Ok<String>(serialized);
  @override
  Future<Result<void>> deserialize(String json) async {
    if (deserializeError != null) return Err<void>(deserializeError!);
    restored = json;
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> backup(String path) => throw UnimplementedError();
  @override
  Future<Result<void>> restore(String path) => throw UnimplementedError();
}

class _FakeSettings implements SettingsRepository {
  final Map<String, String> store = <String, String>{};

  @override
  Future<Result<int?>> readInt(String key) async =>
      Ok<int?>(int.tryParse(store[key] ?? ''));
  @override
  Future<Result<Map<String, String>>> readAll() async =>
      Ok<Map<String, String>>(store);
  @override
  Future<Result<void>> write(String key, String value) async {
    store[key] = value;
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> remove(String key) async {
    store.remove(key);
    return const Ok<void>(null);
  }
}

void main() {
  late _FakeCloud cloud;
  late _FakeBackup backup;
  late _FakeSettings settings;
  late SyncNowUseCase useCase;

  setUp(() {
    cloud = _FakeCloud();
    backup = _FakeBackup();
    settings = _FakeSettings();
    useCase = SyncNowUseCase(backup, cloud, settings, _FakeClock());
  });

  test('signed out → signInRequired, no transfer', () async {
    cloud.signedIn = false;
    final result = await useCase.call();
    expect(result.valueOrNull, SyncOutcome.signInRequired);
    expect(cloud.uploaded, isNull);
    expect(cloud.downloaded, isFalse);
  });

  test('no remote snapshot → push (upload local, stamp lastSync)', () async {
    cloud.meta = null;
    final result = await useCase.call();
    expect(result.valueOrNull, SyncOutcome.pushed);
    expect(cloud.uploaded, backup.serialized);
    expect(
      settings.store[SettingsKeys.cloudLastSyncAt],
      '${DateTime(2026, 6, 28, 12).millisecondsSinceEpoch}',
    );
  });

  test('remote newer than last sync → pull + restore', () async {
    settings.store[SettingsKeys.cloudLastSyncAt] = '1000';
    cloud.meta = (modifiedAt: DateTime.fromMillisecondsSinceEpoch(5000));
    final result = await useCase.call();
    expect(result.valueOrNull, SyncOutcome.pulled);
    expect(backup.restored, cloud.remoteContent);
    expect(cloud.uploaded, isNull);
    expect(settings.store[SettingsKeys.cloudLastSyncAt], '5000');
  });

  test('remote older than last sync → push (local is latest writer)', () async {
    settings.store[SettingsKeys.cloudLastSyncAt] = '9000';
    cloud.meta = (modifiedAt: DateTime.fromMillisecondsSinceEpoch(5000));
    final result = await useCase.call();
    expect(result.valueOrNull, SyncOutcome.pushed);
    expect(cloud.uploaded, backup.serialized);
    expect(backup.restored, isNull);
  });

  test('equal timestamp resolves to push (strict >)', () async {
    settings.store[SettingsKeys.cloudLastSyncAt] = '5000';
    cloud.meta = (modifiedAt: DateTime.fromMillisecondsSinceEpoch(5000));
    final result = await useCase.call();
    expect(result.valueOrNull, SyncOutcome.pushed);
    expect(backup.restored, isNull);
  });

  test('isSignedIn error propagates, nothing transferred', () async {
    cloud.signedInError = const NetworkFailure(message: 'x');
    final result = await useCase.call();
    expect(result, isA<Err<SyncOutcome>>());
    expect(cloud.uploaded, isNull);
    expect(cloud.downloaded, isFalse);
  });

  test('remoteMeta error propagates', () async {
    cloud.metaError = const NetworkFailure(message: 'x');
    final result = await useCase.call();
    expect(result, isA<Err<SyncOutcome>>());
    expect(cloud.uploaded, isNull);
  });

  test('serialize error during push propagates, no upload', () async {
    cloud.meta = null;
    backup.serializeError = const PersistenceFailure(message: 'x');
    final result = await useCase.call();
    expect(result, isA<Err<SyncOutcome>>());
    expect(cloud.uploaded, isNull);
  });

  test('download error during pull propagates, no restore', () async {
    settings.store[SettingsKeys.cloudLastSyncAt] = '1000';
    cloud.meta = (modifiedAt: DateTime.fromMillisecondsSinceEpoch(5000));
    cloud.downloadError = const NetworkFailure(message: 'x');
    final result = await useCase.call();
    expect(result, isA<Err<SyncOutcome>>());
    expect(backup.restored, isNull);
  });

  test(
    'deserialize error during pull propagates, lastSync unchanged',
    () async {
      settings.store[SettingsKeys.cloudLastSyncAt] = '1000';
      cloud.meta = (modifiedAt: DateTime.fromMillisecondsSinceEpoch(5000));
      backup.deserializeError = const PersistenceFailure(message: 'x');
      final result = await useCase.call();
      expect(result, isA<Err<SyncOutcome>>());
      expect(settings.store[SettingsKeys.cloudLastSyncAt], '1000');
    },
  );
}
