/// Google Drive sync configuration.
///
/// 🔴 HUMAN GAP — real cloud sync requires external setup that cannot be done
/// from code:
///   1. A GCP project with the **Drive API enabled**.
///   2. An **OAuth client id** pasted into [clientId] (or injected via
///      `--dart-define=GOOGLE_OAUTH_CLIENT_ID=...` and read at composition root).
///   3. Per-platform OAuth config: Android SHA-1 + `google-services.json`; iOS
///      URL scheme + `Info.plist`; desktop OAuth client.
///
/// Until [clientId] is non-empty, [isConfigured] is false and the sync service
/// reports a clear "not configured" failure instead of calling Google.
class CloudSyncConfig {
  const CloudSyncConfig({this.clientId = ''});

  final String clientId;

  bool get isConfigured => clientId.isNotEmpty;
}
