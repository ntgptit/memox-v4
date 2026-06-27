/// The grade given when reviewing a card. **Stored** in `srs_state.last_result`
/// with a stable encoding (`docs/contracts/types-catalog.md`,
/// `docs/database/schema-contract.md`). A change to [storageValue] is a migration.
enum LastResult {
  correct('correct'),
  wrong('wrong');

  const LastResult(this.storageValue);

  /// The persisted text encoding.
  final String storageValue;

  /// Decodes the stored value, or null when unset/unknown.
  static LastResult? fromStorage(String? value) => switch (value) {
    'correct' => LastResult.correct,
    'wrong' => LastResult.wrong,
    _ => null,
  };
}
