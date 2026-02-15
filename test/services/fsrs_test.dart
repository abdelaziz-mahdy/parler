import 'package:flutter_test/flutter_test.dart';
import 'package:french/services/fsrs.dart';

void main() {
  late Fsrs fsrs;

  setUp(() {
    fsrs = const Fsrs();
  });

  group('Retrievability', () {
    test('returns 1.0 at elapsed time 0', () {
      expect(fsrs.retrievability(0, 10), closeTo(1.0, 0.01));
    });

    test('returns ~0.9 at stability days', () {
      // At t = S, R should be (1 + 1/9)^-1 = 0.9
      expect(fsrs.retrievability(10, 10), closeTo(0.9, 0.01));
    });

    test('decreases over time', () {
      final r1 = fsrs.retrievability(1, 10);
      final r2 = fsrs.retrievability(5, 10);
      final r3 = fsrs.retrievability(20, 10);
      expect(r1, greaterThan(r2));
      expect(r2, greaterThan(r3));
    });

    test('returns 0 for zero stability', () {
      expect(fsrs.retrievability(5, 0), equals(0));
    });
  });

  group('Next interval', () {
    test('produces longer intervals for higher stability', () {
      final i1 = fsrs.nextInterval(5);
      final i2 = fsrs.nextInterval(20);
      expect(i2, greaterThan(i1));
    });

    test('minimum interval is 1 day', () {
      expect(fsrs.nextInterval(0.01), equals(1));
    });
  });

  group('New card review', () {
    test('Good rating sets review state and positive stability', () {
      final card = FsrsCardState(cardId: 'test1');
      final result = fsrs.review(card, FsrsRating.good);
      expect(result.state, FsrsState.review);
      expect(result.stability, greaterThan(0));
      expect(result.reps, 1);
      expect(result.lapses, 0);
    });

    test('Again rating sets learning state', () {
      final card = FsrsCardState(cardId: 'test2');
      final result = fsrs.review(card, FsrsRating.again);
      expect(result.state, FsrsState.learning);
      expect(result.lapses, 1);
      expect(result.reps, 0);
    });
  });

  group('Subsequent reviews', () {
    test('successful reviews increase stability', () {
      final now = DateTime(2026, 1, 1);
      final card = FsrsCardState(
        cardId: 'test3',
        stability: 5.0,
        difficulty: 5.0,
        lastReview: now.subtract(const Duration(days: 5)),
        nextReview: now,
        reps: 1,
        state: FsrsState.review,
      );
      final result = fsrs.review(card, FsrsRating.good, now: now);
      expect(result.stability, greaterThan(card.stability));
    });

    test('lapse resets to relearning and increases lapses', () {
      final now = DateTime(2026, 1, 1);
      final card = FsrsCardState(
        cardId: 'test4',
        stability: 10.0,
        difficulty: 5.0,
        lastReview: now.subtract(const Duration(days: 10)),
        nextReview: now,
        reps: 3,
        lapses: 0,
        state: FsrsState.review,
      );
      final result = fsrs.review(card, FsrsRating.again, now: now);
      expect(result.state, FsrsState.relearning);
      expect(result.lapses, 1);
      expect(result.stability, lessThan(card.stability));
    });
  });

  group('Prioritize', () {
    test('sorts cards by retrievability ascending', () {
      final now = DateTime(2026, 1, 15);
      final cards = [
        FsrsCardState(
          cardId: 'a',
          stability: 30,
          lastReview: now.subtract(const Duration(days: 1)),
          state: FsrsState.review,
        ),
        FsrsCardState(
          cardId: 'b',
          stability: 5,
          lastReview: now.subtract(const Duration(days: 10)),
          state: FsrsState.review,
        ),
        FsrsCardState(
          cardId: 'c',
          stability: 20,
          lastReview: now.subtract(const Duration(days: 5)),
          state: FsrsState.review,
        ),
      ];
      final sorted = fsrs.prioritize(cards, now: now);
      expect(sorted.first.cardId, 'b'); // lowest retrievability
    });
  });

  group('isDue', () {
    test('new card with no nextReview is due', () {
      final card = FsrsCardState(cardId: 'new');
      expect(fsrs.isDue(card), isTrue);
    });

    test('card due today is due', () {
      final card = FsrsCardState(cardId: 'due', nextReview: DateTime.now());
      expect(fsrs.isDue(card), isTrue);
    });

    test('card due tomorrow is not due', () {
      final card = FsrsCardState(
        cardId: 'future',
        nextReview: DateTime.now().add(const Duration(days: 1)),
      );
      expect(fsrs.isDue(card), isFalse);
    });
  });

  group('countMastered', () {
    test('counts cards with stability > 30', () {
      final cards = [
        FsrsCardState(cardId: 'a', stability: 31),
        FsrsCardState(cardId: 'b', stability: 5),
        FsrsCardState(cardId: 'c', stability: 60),
        FsrsCardState(cardId: 'd', stability: 29),
      ];
      expect(fsrs.countMastered(cards), 2);
    });
  });
}
