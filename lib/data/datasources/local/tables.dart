import 'package:drift/drift.dart';

/// Drift table definitions for the local store (DT.1), implementing every table
/// in `docs/database/schema-contract.md`. Row models are the generated data
/// classes — kept separate from the domain entities; mapping happens at the
/// repository boundary (DT.4). Timestamps are stored as UTC epoch microseconds
/// (`IntColumn`); enums as their stable string name; booleans as `BoolColumn`.
///
/// Every foreign key is `onDelete: cascade` so deleting a deck drops its whole
/// subtree (child decks + cards + meanings + srs) — the cascade only fires with
/// `PRAGMA foreign_keys = ON`, set in `AppDatabase.beforeOpen` (D-024).

/// The learning↔native language pair (`D-030`). One row is active in v1.
@DataClassName('LanguagePairRow')
class LanguagePairs extends Table {
  TextColumn get id => text()();
  TextColumn get learningLanguage => text()();
  TextColumn get nativeLanguage => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The self-nesting deck tree (`D-009` recursive subtree; `D-024` cascade).
@TableIndex(name: 'idx_decks_parent', columns: {#parentId})
@DataClassName('DeckRow')
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId =>
      text().nullable().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get languagePairId =>
      text().references(LanguagePairs, #id, onDelete: KeyAction.cascade)();
  IntColumn get createdAt => integer()();
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A study card (BR-1); a soft-duplicate term is allowed (no unique on
/// `(deckId, term)`, `D-020`). `hidden` excludes it from queues/counts (`D-006`).
@TableIndex(name: 'idx_cards_deck', columns: {#deckId})
@TableIndex(name: 'idx_cards_term', columns: {#term})
@DataClassName('CardRow')
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId =>
      text().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get term => text()();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  TextColumn get audioRef => text().nullable()();
  TextColumn get grammaticalGender => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A meaning block of a card (BR-3); search matches `content` (`D-019`).
@TableIndex(name: 'idx_meanings_card', columns: {#cardId})
@TableIndex(name: 'idx_meanings_content', columns: {#content})
@DataClassName('CardMeaningRow')
class CardMeanings extends Table {
  TextColumn get id => text()();
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();
  TextColumn get language => text()();
  TextColumn get content => text()();
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// The Leitner position of a card — one row per card, single-direction (`D-011`).
/// `box` 0..8 (`CHECK`); `dueAt` null for new (box 0) + mastered (box 8, BR-5).
@TableIndex(name: 'idx_srs_due', columns: {#dueAt})
@DataClassName('SrsStateRow')
class SrsStates extends Table {
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();
  // drift_dev reads this getter's AST to build the CHECK; the self-reference is
  // the documented way to constrain the column (box 0..8).
  // ignore: recursive_getters
  IntColumn get box => integer().check(box.isBetweenValues(0, 8))();
  IntColumn get dueAt => integer().nullable()();
  IntColumn get lastReviewedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {cardId};
}

/// Append-only graded-review history (`review_outcome` = `pass`/`fail`).
@TableIndex(name: 'idx_review_logs_card', columns: {#cardId})
@TableIndex(name: 'idx_review_logs_at', columns: {#reviewedAt})
@DataClassName('ReviewLogRow')
class ReviewLogs extends Table {
  TextColumn get id => text()();
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();
  TextColumn get grade => text()();
  IntColumn get reviewedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A finished counting session — only DueReview/NewLearn (`D-010`).
@TableIndex(name: 'idx_sessions_started', columns: {#startedAt})
@DataClassName('StudySessionRow')
class StudySessions extends Table {
  TextColumn get id => text()();
  TextColumn get deckId =>
      text().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get mode => text()();
  IntColumn get startedAt => integer()();
  IntColumn get durationMinutes => integer()();
  IntColumn get wordsStudied => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-day study roll-up (`D-010`/`D-021`). `day` = midnight of the local day.
@DataClassName('DailyActivityRow')
class DailyActivity extends Table {
  IntColumn get day => integer()();
  IntColumn get minutes => integer().withDefault(const Constant(0))();
  IntColumn get words => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day};
}

/// Key–value app preferences (theme, goal, new/day, game/round, reminder…).
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Local backup/restore bookkeeping (`D-027` snapshot level — no cloud in v1).
@DataClassName('BackupMetadataRow')
class BackupMetadata extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get lastRestoredAt => integer().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
