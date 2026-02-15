import 'dart:math';

/// FSRS card states
enum FsrsState { newCard, learning, review, relearning }

/// FSRS rating — binary: Again (forgot) or Good (remembered)
enum FsrsRating {
  again(1),
  good(3);

  final int value;
  const FsrsRating(this.value);
}

/// Scheduling output for a single card
class FsrsSchedule {
  final double stability;
  final double difficulty;
  final FsrsState state;
  final int reps;
  final int lapses;
  final DateTime nextReview;

  const FsrsSchedule({
    required this.stability,
    required this.difficulty,
    required this.state,
    required this.reps,
    required this.lapses,
    required this.nextReview,
  });
}

/// FSRS card state used in database
class FsrsCardState {
  final String cardId;
  final double stability;
  final double difficulty;
  final DateTime? lastReview;
  final DateTime? nextReview;
  final int reps;
  final int lapses;
  final FsrsState state;

  const FsrsCardState({
    required this.cardId,
    this.stability = 0,
    this.difficulty = 5.0,
    this.lastReview,
    this.nextReview,
    this.reps = 0,
    this.lapses = 0,
    this.state = FsrsState.newCard,
  });

  FsrsCardState copyWith({
    double? stability,
    double? difficulty,
    DateTime? lastReview,
    DateTime? nextReview,
    int? reps,
    int? lapses,
    FsrsState? state,
  }) {
    return FsrsCardState(
      cardId: cardId,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      lastReview: lastReview ?? this.lastReview,
      nextReview: nextReview ?? this.nextReview,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
    );
  }
}

/// FSRS (Free Spaced Repetition Scheduler) implementation.
///
/// Based on the DSR model (Difficulty, Stability, Retrievability).
/// Reference: https://github.com/open-spaced-repetition/fsrs4anki
class Fsrs {
  /// Default FSRS v5 parameters (w[0]-w[18])
  static const defaultParams = [
    0.4072, 1.1829, 3.1262, 15.4722, // w0-w3: initial stability for Again/Hard/Good/Easy
    7.2102, 0.5316, 1.0651, 0.0589, // w4-w7: difficulty
    1.5330, 0.1418, 1.0059, 1.9803, // w8-w11: stability after success
    0.0832, 0.3280, 1.3329, 0.2227, // w12-w15: stability after failure
    2.9466, 0.5140, 0.2553, // w16-w18: additional
  ];

  final List<double> params;
  final double desiredRetention;

  const Fsrs({
    this.params = defaultParams,
    this.desiredRetention = 0.9,
  });

  /// Calculate retrievability (probability of recall) given elapsed days and stability.
  ///
  /// Formula: R = (1 + t/(9*S))^(-1)
  double retrievability(double elapsedDays, double stability) {
    if (stability <= 0) return 0;
    return pow(1 + elapsedDays / (9 * stability), -1).toDouble();
  }

  /// Calculate the interval (days) for a target retention rate.
  ///
  /// Formula: interval = 9 * S * (1/R - 1)
  int nextInterval(double stability) {
    final interval = 9 * stability * (1 / desiredRetention - 1);
    return max(1, interval.round());
  }

  /// Initial difficulty for a new card based on first rating.
  ///
  /// Formula: D0 = w4 - exp(w5 * (rating - 1)) + 1
  double _initDifficulty(FsrsRating rating) {
    return params[4] - exp(params[5] * (rating.value - 1)) + 1;
  }

  /// Initial stability for a new card based on first rating.
  ///
  /// For binary (Again=1, Good=3), use w0 or w2.
  double _initStability(FsrsRating rating) {
    return rating == FsrsRating.again ? params[0] : params[2];
  }

  /// Update difficulty after a review.
  ///
  /// Mean reversion formula: D' = w7 * D0(3) + (1 - w7) * (D - w6 * (rating - 3))
  double _nextDifficulty(double d, FsrsRating rating) {
    final d0 = _initDifficulty(FsrsRating.good);
    final newD =
        params[7] * d0 + (1 - params[7]) * (d - params[6] * (rating.value - 3));
    return newD.clamp(1.0, 10.0);
  }

  /// Stability after successful recall.
  ///
  /// Formula: S' = S * (exp(w8) * (11 - D) * S^(-w9) * (exp(w10 * (1 - R)) - 1) + 1)
  double _nextRecallStability(double d, double s, double r) {
    return s *
        (exp(params[8]) * (11 - d) * pow(s, -params[9]) *
                (exp(params[10] * (1 - r)) - 1) +
            1);
  }

  /// Stability after forgetting (lapse).
  ///
  /// Formula: S' = w11 * D^(-w12) * ((S+1)^w13 - 1) * exp(w14 * (1 - R))
  double _nextForgetStability(double d, double s, double r) {
    return params[11] *
        pow(d, -params[12]) *
        (pow(s + 1, params[13]) - 1) *
        exp(params[14] * (1 - r));
  }

  /// Schedule the next review for a card.
  FsrsSchedule review(FsrsCardState card, FsrsRating rating, {DateTime? now}) {
    now ??= DateTime.now();

    double newStability;
    double newDifficulty;
    FsrsState newState;
    int newReps = card.reps;
    int newLapses = card.lapses;

    if (card.state == FsrsState.newCard) {
      // First review of a new card
      newDifficulty = _initDifficulty(rating);
      newStability = _initStability(rating);
      newState =
          rating == FsrsRating.again ? FsrsState.learning : FsrsState.review;
      newReps = rating == FsrsRating.again ? 0 : 1;
      newLapses = rating == FsrsRating.again ? 1 : 0;
    } else {
      // Subsequent review
      final elapsed = card.lastReview != null
          ? now.difference(card.lastReview!).inHours / 24.0
          : 0.0;
      final r = retrievability(elapsed, card.stability);
      newDifficulty = _nextDifficulty(card.difficulty, rating);

      if (rating == FsrsRating.good) {
        newStability =
            _nextRecallStability(card.difficulty, card.stability, r);
        newReps = card.reps + 1;
        newState = FsrsState.review;
      } else {
        newStability =
            _nextForgetStability(card.difficulty, card.stability, r);
        newLapses = card.lapses + 1;
        newReps = 0;
        newState = FsrsState.relearning;
      }
    }

    newDifficulty = newDifficulty.clamp(1.0, 10.0);
    newStability = max(0.1, newStability);

    final interval = rating == FsrsRating.again
        ? 0 // review again today for lapses
        : nextInterval(newStability);
    final nextReviewDate = now.add(Duration(days: interval));

    return FsrsSchedule(
      stability: newStability,
      difficulty: newDifficulty,
      state: newState,
      reps: newReps,
      lapses: newLapses,
      nextReview: nextReviewDate,
    );
  }

  /// Sort cards by priority: lowest retrievability first (most at risk).
  List<FsrsCardState> prioritize(List<FsrsCardState> cards, {DateTime? now}) {
    now ??= DateTime.now();
    final sorted = List<FsrsCardState>.from(cards);
    sorted.sort((a, b) {
      final aElapsed = a.lastReview != null
          ? now!.difference(a.lastReview!).inHours / 24.0
          : 0.0;
      final bElapsed = b.lastReview != null
          ? now!.difference(b.lastReview!).inHours / 24.0
          : 0.0;
      final aR = retrievability(aElapsed, a.stability);
      final bR = retrievability(bElapsed, b.stability);
      return aR.compareTo(bR); // lowest retrievability first
    });
    return sorted;
  }

  /// Check if a card is due for review.
  bool isDue(FsrsCardState card, {DateTime? now}) {
    now ??= DateTime.now();
    if (card.nextReview == null) return true;
    return !now.isBefore(card.nextReview!);
  }

  /// Count of "mastered" cards (stability > 30 days).
  int countMastered(List<FsrsCardState> cards) {
    return cards.where((c) => c.stability > 30).length;
  }
}
