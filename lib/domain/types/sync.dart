/// Metadata of the snapshot currently stored in the cloud (null elsewhere means
/// no remote snapshot exists yet).
typedef RemoteSnapshotMeta = ({DateTime modifiedAt});

/// What a sync run did. Snapshot-level last-writer-wins (see
/// `docs/business/account-sync/account-sync.md`).
enum SyncOutcome {
  /// Local snapshot was uploaded (first push, or local is the latest writer).
  pushed,

  /// Remote snapshot was downloaded and restored (remote is the latest writer).
  pulled,

  /// Not signed in to Google — the caller should prompt sign-in.
  signInRequired,
}
