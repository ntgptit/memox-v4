import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/data/config/cloud_sync_config.dart';
import 'package:memox_v4/domain/services/cloud_sync_service.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/sync.dart';

/// [CloudSyncService] backed by Google Drive's hidden `appDataFolder`, using
/// google_sign_in for auth and the Drive REST API over HTTP for transport.
///
/// Every remote operation short-circuits to a clear failure when
/// [CloudSyncConfig.isConfigured] is false (no GCP client id) — see the config's
/// HUMAN GAP note. The auth + REST wiring below is real; only the credentials and
/// per-platform OAuth setup are external.
class GoogleDriveSyncService implements CloudSyncService {
  GoogleDriveSyncService({
    required CloudSyncConfig config,
    FlutterSecureStorage? storage,
    http.Client? client,
  }) : _config = config,
       _storage = storage ?? const FlutterSecureStorage(),
       _client = client ?? http.Client();

  static const String _scope = 'https://www.googleapis.com/auth/drive.appdata';
  static const String _fileName = 'memox_snapshot.json';
  static const String _fileIdKey = 'cloud_snapshot_file_id';
  static const String _filesUrl = 'https://www.googleapis.com/drive/v3/files';
  static const String _uploadUrl =
      'https://www.googleapis.com/upload/drive/v3/files';

  final CloudSyncConfig _config;
  final FlutterSecureStorage _storage;
  final http.Client _client;

  GoogleSignIn get _signIn => GoogleSignIn.instance;
  GoogleSignInAccount? _account;
  bool _initialized = false;

  @override
  Future<Result<bool>> isSignedIn() async {
    if (!_config.isConfigured) return const Ok<bool>(false);
    try {
      await _ensureInit();
      _account ??= await _signIn.attemptLightweightAuthentication();
      return Ok<bool>(_account != null);
    } catch (e) {
      return Err<bool>(NetworkFailure(message: 'isSignedIn', cause: e));
    }
  }

  @override
  Future<Result<void>> signIn() async {
    if (!_config.isConfigured) return _notConfigured<void>();
    try {
      await _ensureInit();
      _account = await _signIn.authenticate(scopeHint: const <String>[_scope]);
      return const Ok<void>(null);
    } catch (e) {
      return Err<void>(NetworkFailure(message: 'signIn', cause: e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    if (!_config.isConfigured) return const Ok<void>(null);
    try {
      await _ensureInit();
      await _signIn.signOut();
      _account = null;
      return const Ok<void>(null);
    } catch (e) {
      return Err<void>(NetworkFailure(message: 'signOut', cause: e));
    }
  }

  @override
  Future<Result<RemoteSnapshotMeta?>> remoteMeta() async {
    if (!_config.isConfigured) return _notConfigured<RemoteSnapshotMeta?>();
    try {
      final headers = await _authHeaders();
      if (headers == null) {
        return const Err<RemoteSnapshotMeta?>(
          NetworkFailure(message: 'not signed in'),
        );
      }
      final uri = Uri.parse(
        '$_filesUrl?spaces=appDataFolder&fields=files(id,modifiedTime)'
        '&q=${Uri.encodeQueryComponent("name='$_fileName'")}',
      );
      final resp = await _client.get(uri, headers: headers);
      if (resp.statusCode != 200) {
        return Err<RemoteSnapshotMeta?>(
          NetworkFailure(message: 'remoteMeta ${resp.statusCode}'),
        );
      }
      final files =
          (jsonDecode(resp.body) as Map<String, dynamic>)['files']
              as List<dynamic>? ??
          const <dynamic>[];
      if (files.isEmpty) return const Ok<RemoteSnapshotMeta?>(null);
      final file = files.first as Map<String, dynamic>;
      await _storage.write(key: _fileIdKey, value: file['id'] as String);
      return Ok<RemoteSnapshotMeta?>((
        modifiedAt: DateTime.parse(file['modifiedTime'] as String),
      ));
    } catch (e) {
      return Err<RemoteSnapshotMeta?>(
        NetworkFailure(message: 'remoteMeta', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> upload(String snapshotJson, DateTime modifiedAt) async {
    // Drive stamps its own modifiedTime on write, which remoteMeta reads back;
    // [modifiedAt] is part of the interface (used by in-memory fakes) and is not
    // sent here.
    if (!_config.isConfigured) return _notConfigured<void>();
    try {
      final headers = await _authHeaders();
      if (headers == null) {
        return const Err<void>(NetworkFailure(message: 'not signed in'));
      }
      var fileId = await _storage.read(key: _fileIdKey);
      if (fileId == null) {
        final created = await _client.post(
          Uri.parse('$_filesUrl?fields=id'),
          headers: <String, String>{
            ...headers,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'name': _fileName,
            'parents': <String>['appDataFolder'],
          }),
        );
        if (created.statusCode != 200) {
          return Err<void>(
            NetworkFailure(message: 'create ${created.statusCode}'),
          );
        }
        fileId =
            (jsonDecode(created.body) as Map<String, dynamic>)['id'] as String;
        await _storage.write(key: _fileIdKey, value: fileId);
      }
      final resp = await _client.patch(
        Uri.parse('$_uploadUrl/$fileId?uploadType=media'),
        headers: <String, String>{
          ...headers,
          'Content-Type': 'application/json',
        },
        body: snapshotJson,
      );
      if (resp.statusCode != 200) {
        return Err<void>(NetworkFailure(message: 'upload ${resp.statusCode}'));
      }
      return const Ok<void>(null);
    } catch (e) {
      return Err<void>(NetworkFailure(message: 'upload', cause: e));
    }
  }

  @override
  Future<Result<String>> download() async {
    if (!_config.isConfigured) return _notConfigured<String>();
    try {
      final headers = await _authHeaders();
      if (headers == null) {
        return const Err<String>(NetworkFailure(message: 'not signed in'));
      }
      var fileId = await _storage.read(key: _fileIdKey);
      if (fileId == null) {
        final meta = await remoteMeta();
        if (meta case Err(:final failure)) return Err<String>(failure);
        fileId = await _storage.read(key: _fileIdKey);
        if (fileId == null) {
          return const Err<String>(
            NetworkFailure(message: 'no remote snapshot'),
          );
        }
      }
      final resp = await _client.get(
        Uri.parse('$_filesUrl/$fileId?alt=media'),
        headers: headers,
      );
      if (resp.statusCode != 200) {
        return Err<String>(
          NetworkFailure(message: 'download ${resp.statusCode}'),
        );
      }
      return Ok<String>(resp.body);
    } catch (e) {
      return Err<String>(NetworkFailure(message: 'download', cause: e));
    }
  }

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _signIn.initialize(clientId: _config.clientId);
    _initialized = true;
  }

  Future<Map<String, String>?> _authHeaders() async {
    final account =
        _account ?? await _signIn.attemptLightweightAuthentication();
    _account = account;
    if (account == null) return null;
    return account.authorizationClient.authorizationHeaders(const <String>[
      _scope,
    ]);
  }

  Result<T> _notConfigured<T>() => Err<T>(
    const NetworkFailure(
      message:
          'Google Drive not configured (GCP client id / platform OAuth) — '
          'see CloudSyncConfig human gap',
    ),
  );
}
