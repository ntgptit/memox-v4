import 'package:drift/drift.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/models/mappers/time_mapper.dart';
import 'package:memox_v4/data/repositories/drift_card_repository.dart';
import 'package:memox_v4/data/repositories/drift_deck_repository.dart';
import 'package:memox_v4/data/repositories/drift_review_repository.dart';
import 'package:memox_v4/data/repositories/drift_settings_repository.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';

/// The default active language pair for a fresh install — Korean → Vietnamese
/// (the reference domain). A first run has exactly this pair and nothing more
/// (a clean empty state); decks/cards arrive only via [seedSampleData] (dev).
const String _defaultPairId = 'lang-ko-vi';
const String _defaultLearning = 'ko';
const String _defaultNative = 'vi';

/// First-run default preferences.
const int _defaultGoalMinutes = 15;
const int _defaultGoalWords = 20;
const int _defaultNewPerDay = 20;

/// Sample dev data (idempotent — only seeded into an empty deck tree).
const String _rootDeckId = 'seed-korean-basics';
const String _foodDeckId = 'seed-food';

/// Seeds the local database (DT.6). [ensureFirstRun] establishes the clean
/// first-run state every launch needs — the single active language pair (which
/// the deck FK requires) plus default preferences — and is idempotent.
/// [seedSampleData] adds a realistic dev deck tree with cards + a mix of SRS
/// positions. Both reuse the DT.4 repositories, so seeded data is validated the
/// same way user data is.
class DatabaseSeeder {
  DatabaseSeeder(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// Ensures the clean first-run state: an active language pair + default
  /// preferences. A no-op once a pair already exists.
  Future<void> ensureFirstRun() async {
    final existing = await _db.select(_db.languagePairs).get();
    if (existing.isNotEmpty) return;

    await _db
        .into(_db.languagePairs)
        .insert(
          LanguagePairsCompanion.insert(
            id: _defaultPairId,
            learningLanguage: _defaultLearning,
            nativeLanguage: _defaultNative,
            createdAt: dateTimeToMicros(_clock.now())!,
            isActive: const Value(true),
          ),
        );

    final settings = DriftSettingsRepository(_db);
    _throwIfErr(await settings.saveNewCardsPerDay(_defaultNewPerDay));
    _throwIfErr(
      await settings.saveDailyGoal(
        const DailyGoal(
          minutesTarget: _defaultGoalMinutes,
          wordsTarget: _defaultGoalWords,
        ),
      ),
    );
  }

  /// Seeds a realistic dev deck tree (Korean Basics → Food) with three cards and
  /// a mix of SRS positions (one due, one scheduled ahead, one new). Idempotent —
  /// a no-op once any deck exists.
  Future<void> seedSampleData() async {
    await ensureFirstRun();
    final decks = await _db.select(_db.decks).get();
    if (decks.isNotEmpty) return;

    final deckRepo = DriftDeckRepository(_db, _clock);
    final cardRepo = DriftCardRepository(_db, _clock);
    final reviewRepo = DriftReviewRepository(_db, _clock);
    final now = _clock.now();

    _throwIfErr(await deckRepo.save(_deck(_rootDeckId, 'Korean Basics')));
    _throwIfErr(
      await deckRepo.save(_deck(_foodDeckId, 'Food', parent: _rootDeckId)),
    );

    _throwIfErr(await cardRepo.save(_card('seed-card-1', '사과', 'quả táo')));
    _throwIfErr(await cardRepo.save(_card('seed-card-2', '고양이', 'con mèo')));
    _throwIfErr(await cardRepo.save(_card('seed-card-3', '개', 'con chó')));

    // card-1 is due (an hour ago); card-2 is scheduled ahead; card-3 stays new.
    _throwIfErr(
      await reviewRepo.saveSchedule(
        cardId: const CardId('seed-card-1'),
        box: BoxLevel.firstBox,
        dueAt: now.subtract(const Duration(hours: 1)),
      ),
    );
    _throwIfErr(
      await reviewRepo.saveSchedule(
        cardId: const CardId('seed-card-2'),
        box: (BoxLevel.of(3) as Ok<BoxLevel>).value,
        dueAt: now.add(const Duration(days: 5)),
      ),
    );
  }

  Deck _deck(String id, String name, {String? parent}) =>
      (Deck.create(
                id: DeckId(id),
                name: name,
                parentId: parent == null ? null : DeckId(parent),
              )
              as Ok<Deck>)
          .value;

  Card _card(String id, String term, String meaning) =>
      (Card.create(
                id: CardId(id),
                deckId: const DeckId(_foodDeckId),
                term: term,
                meanings: [
                  (CardMeaning.create(
                            id: CardMeaningId('m-$id'),
                            language: _defaultNative,
                            text: meaning,
                          )
                          as Ok<CardMeaning>)
                      .value,
                ],
              )
              as Ok<Card>)
          .value;

  void _throwIfErr<T>(Result<T> result) {
    if (result case Err(:final failure)) {
      // ignore: only_throw_errors -- reason: Failure is MemoX's domain error type; rethrown here to abort the seed and surface via the seeder's Result/AsyncValue boundary
      throw failure;
    }
  }
}
