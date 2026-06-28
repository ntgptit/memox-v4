import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:memox_v4/data/config/cloud_sync_config.dart';
import 'package:memox_v4/data/services/google_drive_sync_service.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/sync.dart';

void main() {
  test(
    'unconfigured service short-circuits without any network call',
    () async {
      final client = MockClient(
        (req) async => fail('no network when CloudSyncConfig is empty'),
      );
      final service = GoogleDriveSyncService(
        config: const CloudSyncConfig(),
        client: client,
      );

      // Sign-in state is simply "no", not an error.
      expect((await service.isSignedIn()).valueOrNull, isFalse);
      // Every remote op fails clearly instead of touching Google.
      expect(await service.signIn(), isA<Err<void>>());
      expect(await service.remoteMeta(), isA<Err<RemoteSnapshotMeta?>>());
      expect(await service.upload('{}', DateTime(2026)), isA<Err<void>>());
      expect(await service.download(), isA<Err<String>>());
    },
  );
}
