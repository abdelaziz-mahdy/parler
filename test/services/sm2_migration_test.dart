import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/progress.dart';
import 'package:french/services/fsrs.dart';
import 'package:french/services/sm2_migration.dart';

void main() {
  test('default SM-2 card converts to middle difficulty', () {
    final card = CardProgress.initial('test1');
    final fsrs = Sm2Migration.convert(card);
    expect(fsrs.difficulty, closeTo(5.0, 1.0));
    expect(fsrs.state, FsrsState.newCard);
    expect(fsrs.reps, 0);
  });

  test('hard SM-2 card (low ease factor) maps to high difficulty', () {
    final card = CardProgress(
      cardId: 'hard',
      easeFactor: 1.3,
      interval: 1,
      repetitions: 5,
      nextReviewDate: '2026-02-15',
      quality: 3,
    );
    final fsrs = Sm2Migration.convert(card);
    expect(fsrs.difficulty, greaterThan(7.0));
  });

  test('easy SM-2 card (high ease factor) maps to low difficulty', () {
    final card = CardProgress(
      cardId: 'easy',
      easeFactor: 3.0,
      interval: 30,
      repetitions: 10,
      nextReviewDate: '2026-03-15',
      quality: 5,
    );
    final fsrs = Sm2Migration.convert(card);
    expect(fsrs.difficulty, lessThan(4.0));
  });

  test('interval maps to stability', () {
    final card = CardProgress(
      cardId: 'stable',
      easeFactor: 2.5,
      interval: 15,
      repetitions: 3,
      nextReviewDate: '2026-03-01',
      quality: 4,
    );
    final fsrs = Sm2Migration.convert(card);
    expect(fsrs.stability, equals(15.0));
    expect(fsrs.state, FsrsState.review);
  });

  test('convertAll processes multiple cards', () {
    final cards = {
      'a': CardProgress.initial('a'),
      'b': CardProgress(
        cardId: 'b',
        easeFactor: 2.5,
        interval: 10,
        repetitions: 2,
        nextReviewDate: '2026-02-20',
        quality: 4,
      ),
    };
    final result = Sm2Migration.convertAll(cards);
    expect(result.length, 2);
    expect(result['a']!.state, FsrsState.newCard);
    expect(result['b']!.state, FsrsState.review);
  });
}
