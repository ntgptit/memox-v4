import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/review_log.dart';
import 'package:memox_v4/domain/entities/streak.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/domain/entities/study_session.dart';

CardMeaning _meaning([String text = 'con mèo']) =>
    (CardMeaning.create(id: const CardMeaningId('m1'), language: 'vi', text: text)
            as Ok<CardMeaning>)
        .value;

void main() {
  group('LanguagePair', () {
    test('requires both languages', () {
      expect(
        LanguagePair.create(
          id: const LanguagePairId('lp'),
          learningLanguage: 'ko',
          nativeLanguage: 'vi',
        ),
        isA<Ok<LanguagePair>>(),
      );
      expect(
        LanguagePair.create(
          id: const LanguagePairId('lp'),
          learningLanguage: '  ',
          nativeLanguage: 'vi',
        ),
        isA<Err<LanguagePair>>(),
      );
    });
  });

  group('Deck', () {
    test('name is required (BR-1 / AC-2)', () {
      expect(
        Deck.create(id: const DeckId('d1'), name: 'Animals'),
        isA<Ok<Deck>>(),
      );
      expect(Deck.create(id: const DeckId('d1'), name: '   '), isA<Err<Deck>>());
    });

    test('isRoot reflects the parent link', () {
      final root = (Deck.create(id: const DeckId('d1'), name: 'Root') as Ok<Deck>).value;
      final child = (Deck.create(
        id: const DeckId('d2'),
        name: 'Child',
        parentId: const DeckId('d1'),
      ) as Ok<Deck>)
          .value;
      expect(root.isRoot, isTrue);
      expect(child.isRoot, isFalse);
    });
  });

  group('Card', () {
    Card build({String term = 'neko', List<CardMeaning>? meanings, bool hidden = false}) =>
        (Card.create(
          id: const CardId('c1'),
          deckId: const DeckId('d1'),
          term: term,
          meanings: meanings ?? [_meaning()],
          hidden: hidden,
        ) as Ok<Card>)
            .value;

    test('requires a term and at least one meaning (BR-2 / AC-3)', () {
      expect(Card.create(
        id: const CardId('c1'),
        deckId: const DeckId('d1'),
        term: '',
        meanings: [_meaning()],
      ), isA<Err<Card>>());
      expect(Card.create(
        id: const CardId('c1'),
        deckId: const DeckId('d1'),
        term: 'neko',
        meanings: const [],
      ), isA<Err<Card>>());
    });

    test('meanings are unmodifiable', () {
      expect(() => build().meanings.add(_meaning('extra')), throwsUnsupportedError);
    });

    test('hidden flag is carried (BR-4)', () {
      expect(build(hidden: true).isHidden, isTrue);
      expect(build().isHidden, isFalse);
    });
  });

  group('DailyGoal.isMetBy (BR-2 / D-021)', () {
    test('met by at least one target; unset target never counts', () {
      const goal = DailyGoal(minutesTarget: 15, wordsTarget: 20);
      expect(goal.isMetBy(minutes: 15, words: 0), isTrue); // by minutes
      expect(goal.isMetBy(minutes: 0, words: 20), isTrue); // by words
      expect(goal.isMetBy(minutes: 14, words: 19), isFalse); // neither

      const minutesOnly = DailyGoal(minutesTarget: 10);
      expect(minutesOnly.isMetBy(minutes: 0, words: 999), isFalse);
      expect(minutesOnly.isMetBy(minutes: 10, words: 0), isTrue);

      const unset = DailyGoal();
      expect(unset.isConfigured, isFalse);
      expect(unset.isMetBy(minutes: 999, words: 999), isFalse);
    });
  });

  group('Streak (BR-3 / D-021)', () {
    test('advance increments and tracks the longest run', () {
      var s = Streak.zero;
      s = s.advanced();
      s = s.advanced();
      expect(s.current, 2);
      expect(s.longest, 2);
    });

    test('reset zeroes the current run but keeps the record', () {
      const s = Streak(current: 5, longest: 7);
      final r = s.reset();
      expect(r.current, 0);
      expect(r.longest, 7);
    });

    test('advancing past a prior record raises longest', () {
      const s = Streak(current: 7, longest: 7);
      expect(s.advanced(), const Streak(current: 8, longest: 8));
    });
  });

  group('DeckStats (BR-5 / BR-6)', () {
    test('visible excludes hidden; progress is mastered over visible', () {
      const stats = DeckStats(totalCards: 10, hiddenCount: 2, dueCount: 3, masteredCount: 4);
      expect(stats.visibleCount, 8);
      expect(stats.progress, 4 / 8);
      expect(DeckStats.empty.progress, 0);
    });

    test('aggregates recursively via +', () {
      const parent = DeckStats(totalCards: 3, hiddenCount: 1, dueCount: 1, masteredCount: 0);
      const child = DeckStats(totalCards: 5, hiddenCount: 0, dueCount: 2, masteredCount: 3);
      final sum = parent + child;
      expect(sum, const DeckStats(totalCards: 8, hiddenCount: 1, dueCount: 3, masteredCount: 3));
    });
  });

  group('event entities', () {
    test('ReviewLog + StudySession equality is by value', () {
      final at = DateTime(2026);
      expect(
        ReviewLog(cardId: const CardId('c1'), grade: ReviewGrade.pass, reviewedAt: at),
        ReviewLog(cardId: const CardId('c1'), grade: ReviewGrade.pass, reviewedAt: at),
      );
      expect(
        StudySession(
          id: const StudySessionId('s1'),
          deckId: const DeckId('d1'),
          mode: StudyMode.newLearn,
          startedAt: at,
          durationMinutes: 5,
          wordsStudied: 20,
        ).mode,
        StudyMode.newLearn,
      );
    });
  });
}
