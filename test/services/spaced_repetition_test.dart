import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/progress.dart';
import 'package:french/services/spaced_repetition.dart';

void main() {
  group('SpacedRepetition.review', () {
    late CardProgress freshCard;

    setUp(() {
      freshCard = const CardProgress(
        cardId: 'test-card',
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        nextReviewDate: '2026-01-01',
        quality: 0,
      );
    });

    test('first correct answer sets interval to 1 day', () {
      final result = SpacedRepetition.review(freshCard, 4);

      expect(result.interval, 1);
      expect(result.repetitions, 1);
      expect(result.quality, 4);
    });

    test('second correct answer sets interval to 6 days', () {
      final afterFirst = freshCard.copyWith(
        interval: 1,
        repetitions: 1,
      );

      final result = SpacedRepetition.review(afterFirst, 4);

      expect(result.interval, 6);
      expect(result.repetitions, 2);
    });

    test('third correct answer uses ease factor for interval', () {
      final afterSecond = freshCard.copyWith(
        interval: 6,
        repetitions: 2,
        easeFactor: 2.5,
      );

      final result = SpacedRepetition.review(afterSecond, 4);

      // 6 * 2.5 = 15
      expect(result.interval, 15);
      expect(result.repetitions, 3);
    });

    test('incorrect answer resets interval and repetitions', () {
      final experienced = freshCard.copyWith(
        interval: 15,
        repetitions: 3,
        easeFactor: 2.5,
      );

      final result = SpacedRepetition.review(experienced, 2);

      expect(result.interval, 1);
      expect(result.repetitions, 0);
    });

    test('quality 0 resets the card', () {
      final card = freshCard.copyWith(
        interval: 10,
        repetitions: 5,
      );

      final result = SpacedRepetition.review(card, 0);

      expect(result.interval, 1);
      expect(result.repetitions, 0);
    });

    test('quality 3 is treated as correct', () {
      final result = SpacedRepetition.review(freshCard, 3);

      expect(result.interval, 1);
      expect(result.repetitions, 1);
    });

    test('perfect responses increase ease factor', () {
      final result = SpacedRepetition.review(freshCard, 5);

      // EF' = 2.5 + (0.1 - (5-5) * (0.08 + (5-5) * 0.02)) = 2.5 + 0.1 = 2.6
      expect(result.easeFactor, closeTo(2.6, 0.001));
    });

    test('poor correct responses decrease ease factor', () {
      final result = SpacedRepetition.review(freshCard, 3);

      // EF' = 2.5 + (0.1 - (5-3) * (0.08 + (5-3) * 0.02))
      //     = 2.5 + (0.1 - 2 * (0.08 + 2 * 0.02))
      //     = 2.5 + (0.1 - 2 * 0.12)
      //     = 2.5 + (0.1 - 0.24)
      //     = 2.5 + (-0.14)
      //     = 2.36
      expect(result.easeFactor, closeTo(2.36, 0.001));
    });

    test('ease factor never drops below 1.3', () {
      final hardCard = freshCard.copyWith(easeFactor: 1.3);

      // Quality 0 gives maximum EF decrease
      // EF' = 1.3 + (0.1 - 5 * (0.08 + 5 * 0.02))
      //     = 1.3 + (0.1 - 5 * 0.18)
      //     = 1.3 + (0.1 - 0.9)
      //     = 1.3 + (-0.8)
      //     = 0.5 -> clamped to 1.3
      final result = SpacedRepetition.review(hardCard, 0);

      expect(result.easeFactor, 1.3);
    });

    test('quality 4 slightly decreases ease factor', () {
      final result = SpacedRepetition.review(freshCard, 4);

      // EF' = 2.5 + (0.1 - 1 * (0.08 + 1 * 0.02))
      //     = 2.5 + (0.1 - 0.1)
      //     = 2.5
      expect(result.easeFactor, closeTo(2.5, 0.001));
    });

    test('cardId is preserved through review', () {
      final result = SpacedRepetition.review(freshCard, 5);
      expect(result.cardId, 'test-card');
    });

    test('nextReviewDate is set to future date', () {
      final result = SpacedRepetition.review(freshCard, 5);
      final today = DateTime.now().toIso8601String().split('T').first;

      expect(result.nextReviewDate.compareTo(today), greaterThan(0));
    });

    test('repeated perfect reviews grow interval exponentially', () {
      var card = freshCard;
      final intervals = <int>[];

      for (var i = 0; i < 5; i++) {
        card = SpacedRepetition.review(card, 5);
        intervals.add(card.interval);
      }

      // Intervals should grow: 1, 6, 16, 42, 110 (approx)
      expect(intervals[0], 1);
      expect(intervals[1], 6);
      expect(intervals[2], greaterThan(10));
      expect(intervals[3], greaterThan(intervals[2]));
      expect(intervals[4], greaterThan(intervals[3]));
    });
  });

  group('SpacedRepetition.isDue', () {
    test('card with past review date is due', () {
      const card = CardProgress(
        cardId: 'c1',
        easeFactor: 2.5,
        interval: 1,
        repetitions: 1,
        nextReviewDate: '2020-01-01',
        quality: 4,
      );

      expect(SpacedRepetition.isDue(card), true);
    });

    test('card with today review date is due', () {
      final today = DateTime.now().toIso8601String().split('T').first;
      final card = CardProgress(
        cardId: 'c2',
        easeFactor: 2.5,
        interval: 1,
        repetitions: 1,
        nextReviewDate: today,
        quality: 4,
      );

      expect(SpacedRepetition.isDue(card), true);
    });

    test('card with future review date is not due', () {
      final future = DateTime.now()
          .add(const Duration(days: 30))
          .toIso8601String()
          .split('T')
          .first;
      final card = CardProgress(
        cardId: 'c3',
        easeFactor: 2.5,
        interval: 30,
        repetitions: 3,
        nextReviewDate: future,
        quality: 5,
      );

      expect(SpacedRepetition.isDue(card), false);
    });
  });

  group('SpacedRepetition.prioritize', () {
    test('due cards come before non-due cards', () {
      final future = DateTime.now()
          .add(const Duration(days: 30))
          .toIso8601String()
          .split('T')
          .first;

      final dueCard = const CardProgress(
        cardId: 'due',
        easeFactor: 2.5,
        interval: 1,
        repetitions: 1,
        nextReviewDate: '2020-01-01',
        quality: 4,
      );

      final notDueCard = CardProgress(
        cardId: 'not-due',
        easeFactor: 2.5,
        interval: 30,
        repetitions: 3,
        nextReviewDate: future,
        quality: 5,
      );

      final result = SpacedRepetition.prioritize([notDueCard, dueCard]);

      expect(result.first.cardId, 'due');
      expect(result.last.cardId, 'not-due');
    });

    test('harder cards (lower ease factor) have higher priority', () {
      const hardCard = CardProgress(
        cardId: 'hard',
        easeFactor: 1.3,
        interval: 1,
        repetitions: 1,
        nextReviewDate: '2020-01-01',
        quality: 3,
      );

      const easyCard = CardProgress(
        cardId: 'easy',
        easeFactor: 2.8,
        interval: 1,
        repetitions: 1,
        nextReviewDate: '2020-01-01',
        quality: 5,
      );

      final result = SpacedRepetition.prioritize([easyCard, hardCard]);

      expect(result.first.cardId, 'hard');
      expect(result.last.cardId, 'easy');
    });

    test('empty list returns empty list', () {
      expect(SpacedRepetition.prioritize([]), isEmpty);
    });
  });
}
