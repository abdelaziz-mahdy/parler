import '../models/progress.dart';

/// SM-2 spaced repetition algorithm implementation.
///
/// Quality ratings:
/// 0 - Complete blackout
/// 1 - Incorrect, but upon seeing the answer, remembered
/// 2 - Incorrect, but the answer seemed easy to recall
/// 3 - Correct with serious difficulty
/// 4 - Correct with some hesitation
/// 5 - Perfect response
class SpacedRepetition {
  SpacedRepetition._();

  /// Calculate the next review state for a card based on the quality of recall.
  ///
  /// Returns a new [CardProgress] with updated SM-2 parameters.
  static CardProgress review(CardProgress card, int quality) {
    assert(quality >= 0 && quality <= 5, 'Quality must be between 0 and 5');

    double newEaseFactor = card.easeFactor;
    int newInterval;
    int newRepetitions;

    if (quality >= 3) {
      // Correct response
      if (card.repetitions == 0) {
        newInterval = 1;
      } else if (card.repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (card.interval * card.easeFactor).round();
      }
      newRepetitions = card.repetitions + 1;
    } else {
      // Incorrect response - reset
      newInterval = 1;
      newRepetitions = 0;
    }

    // Update ease factor using SM-2 formula
    newEaseFactor = card.easeFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

    // Ease factor must not go below 1.3
    if (newEaseFactor < 1.3) {
      newEaseFactor = 1.3;
    }

    final nextReview = DateTime.now()
        .add(Duration(days: newInterval))
        .toIso8601String()
        .split('T')
        .first;

    return card.copyWith(
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitions: newRepetitions,
      nextReviewDate: nextReview,
      quality: quality,
    );
  }

  /// Check if a card is due for review based on its next review date.
  static bool isDue(CardProgress card) {
    final today = DateTime.now().toIso8601String().split('T').first;
    return card.nextReviewDate.compareTo(today) <= 0;
  }

  /// Sort cards by priority: due cards first, then by ease factor (harder first).
  static List<CardProgress> prioritize(List<CardProgress> cards) {
    final sorted = List<CardProgress>.from(cards);
    sorted.sort((a, b) {
      final aDue = isDue(a);
      final bDue = isDue(b);

      if (aDue && !bDue) return -1;
      if (!aDue && bDue) return 1;

      // Both due or both not due: sort by ease factor (lower = harder = higher priority)
      return a.easeFactor.compareTo(b.easeFactor);
    });
    return sorted;
  }
}
