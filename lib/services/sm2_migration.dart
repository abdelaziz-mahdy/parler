import '../models/progress.dart';
import 'fsrs.dart';

/// Converts SM-2 CardProgress entries to FSRS FsrsCardState.
class Sm2Migration {
  /// Convert a single SM-2 card to FSRS initial state.
  ///
  /// Mapping logic:
  /// - easeFactor 2.5 (default) -> difficulty 5.0 (middle)
  /// - easeFactor < 2.0 -> harder -> higher difficulty
  /// - interval -> initial stability (days)
  /// - repetitions > 0 -> state = review, else newCard
  static FsrsCardState convert(CardProgress sm2Card) {
    // Map ease factor (1.3-2.5+) to difficulty (1-10, inverted)
    // EF 2.5 -> D 5.0, EF 1.3 -> D 9.0, EF 3.0+ -> D 3.0
    final difficulty =
        (10.0 - (sm2Card.easeFactor - 1.3) * (7.0 / 1.7)).clamp(1.0, 10.0);

    // Stability approximation from SM-2 interval
    // If interval is 0, card hasn't been successfully reviewed yet
    final stability =
        sm2Card.interval > 0 ? sm2Card.interval.toDouble() : 0.0;

    // Parse next review date
    DateTime? nextReview;
    DateTime? lastReview;
    if (sm2Card.nextReviewDate.isNotEmpty) {
      try {
        nextReview = DateTime.parse(sm2Card.nextReviewDate);
        // Approximate last review from interval
        if (sm2Card.interval > 0) {
          lastReview =
              nextReview.subtract(Duration(days: sm2Card.interval));
        }
      } catch (_) {
        // Invalid date, leave as null
      }
    }

    final state =
        sm2Card.repetitions > 0 ? FsrsState.review : FsrsState.newCard;

    return FsrsCardState(
      cardId: sm2Card.cardId,
      stability: stability,
      difficulty: difficulty,
      lastReview: lastReview,
      nextReview: nextReview,
      reps: sm2Card.repetitions,
      lapses: 0, // SM-2 doesn't track lapses separately
      state: state,
    );
  }

  /// Convert all SM-2 flashcard entries.
  static Map<String, FsrsCardState> convertAll(
      Map<String, CardProgress> sm2Cards) {
    return sm2Cards.map((id, card) => MapEntry(id, convert(card)));
  }
}
