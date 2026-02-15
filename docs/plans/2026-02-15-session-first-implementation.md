# Session-First Redesign — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the Parler French learning app from a free-form browsing experience into a guided daily-session-first experience with FSRS spaced repetition, quiz-style reviews, and 3-tab navigation.

**Architecture:** Replace SM-2 with FSRS algorithm for vocabulary scheduling. Add Drift (SQLite) database with web support for card states and review logs. Restructure navigation from 4 tabs (Lessons/Words/TEF/Quiz) to 3 tabs (Today/Learn/Profile). Build a session engine that auto-generates personalized daily practice sessions with 3 phases (Review, New Content, Mixed Practice).

**Tech Stack:** Flutter, Riverpod v3, GoRouter, Drift (SQLite + WASM for web), flutter_tts, flutter_animate

---

## Team Structure

| Agent | Type | Responsibilities |
|-------|------|-----------------|
| **lead** | Coordinator | Task assignment, integration, dependency management |
| **algo-dev** | general-purpose | Tasks 1-3: FSRS algorithm, session engine, SM-2 migration |
| **data-dev** | general-purpose | Tasks 4-6: Drift DB setup, providers, TTS upgrades |
| **ui-dev** | general-purpose | Tasks 7-11: All screen/navigation work |
| **reviewer** | code-reviewer | Reviews each completed task for correctness and consistency |

## Dependency Graph

```
Task 1 (FSRS algorithm)     ──┐
Task 4 (Drift DB setup)     ──┤──→ Task 5 (Providers) ──→ Task 7 (Today tab)
Task 2 (Session engine)     ──┘                        ──→ Task 8 (Session screens)
Task 3 (SM-2 migration)     ← depends on Task 1, 4
Task 6 (TTS upgrades)       ← independent
Task 9 (Learn tab)          ← depends on Task 5
Task 10 (Profile tab)       ← depends on Task 5
Task 11 (Router rewrite)    ← depends on Tasks 7-10
Task 12 (Integration test)  ← depends on all above
```

**Parallel work streams:**
- Stream A (algo-dev): Task 1 → Task 2 → Task 3
- Stream B (data-dev): Task 4 → Task 5 → Task 6
- Stream C (ui-dev): waits for Task 5, then Task 7 → Task 8 → Task 9 → Task 10 → Task 11
- Reviewer checks after each task completion

---

### Task 1: FSRS Algorithm Service (algo-dev)

**Files:**
- Create: `lib/services/fsrs.dart`
- Create: `test/services/fsrs_test.dart`

**Context:** This replaces `lib/services/spaced_repetition.dart` (SM-2). The existing SM-2 uses `CardProgress` with `easeFactor`, `interval`, `repetitions`, `nextReviewDate`, `quality`. FSRS uses `stability`, `difficulty`, `retrievability` with a power-law forgetting curve.

**Step 1: Write FSRS model classes**

Create `lib/services/fsrs.dart` with these classes:

```dart
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
```

**Step 2: Implement FSRS core algorithm**

Add the `Fsrs` class to `lib/services/fsrs.dart`:

```dart
/// FSRS (Free Spaced Repetition Scheduler) implementation.
///
/// Based on the DSR model (Difficulty, Stability, Retrievability).
/// Reference: https://github.com/open-spaced-repetition/fsrs4anki
class Fsrs {
  /// Default FSRS v5 parameters (w[0]-w[18])
  static const defaultParams = [
    0.4072, 1.1829, 3.1262, 15.4722, // w0-w3: initial stability for Again/Hard/Good/Easy
    7.2102, 0.5316, 1.0651, 0.0589,  // w4-w7: difficulty
    1.5330, 0.1418, 1.0059, 1.9803,  // w8-w11: stability after success
    0.0832, 0.3280, 1.3329, 0.2227,  // w12-w15: stability after failure
    2.9466, 0.5140, 0.2553,          // w16-w18: additional
  ];

  final List<double> params;
  final double desiredRetention;

  const Fsrs({
    this.params = defaultParams,
    this.desiredRetention = 0.9,
  });

  /// Calculate retrievability (probability of recall) given elapsed days and stability.
  double retrievability(double elapsedDays, double stability) {
    if (stability <= 0) return 0;
    return pow(1 + elapsedDays / (9 * stability), -1).toDouble();
  }

  /// Calculate the interval (days) for a target retention rate.
  int nextInterval(double stability) {
    final interval = 9 * stability * (1 / desiredRetention - 1);
    return max(1, interval.round());
  }

  /// Initial difficulty for a new card based on first rating.
  double _initDifficulty(FsrsRating rating) {
    // D0 = w4 - exp(w5 * (rating - 1)) + 1
    return params[4] - exp(params[5] * (rating.value - 1)) + 1;
  }

  /// Initial stability for a new card based on first rating.
  double _initStability(FsrsRating rating) {
    // For binary (Again=1, Good=3), use w0 or w2
    return rating == FsrsRating.again ? params[0] : params[2];
  }

  /// Update difficulty after a review.
  double _nextDifficulty(double d, FsrsRating rating) {
    // Mean reversion: D' = w7 * D0(3) + (1 - w7) * (D - w6 * (rating - 3))
    final d0 = _initDifficulty(FsrsRating.good);
    final newD = params[7] * d0 + (1 - params[7]) * (d - params[6] * (rating.value - 3));
    return newD.clamp(1.0, 10.0);
  }

  /// Stability after successful recall.
  double _nextRecallStability(double d, double s, double r) {
    // S' = S * (exp(w8) * (11 - D) * S^(-w9) * (exp(w10 * (1 - R)) - 1) + 1)
    return s * (exp(params[8]) * (11 - d) * pow(s, -params[9]) *
        (exp(params[10] * (1 - r)) - 1) + 1);
  }

  /// Stability after forgetting (lapse).
  double _nextForgetStability(double d, double s, double r) {
    // S' = w11 * D^(-w12) * ((S+1)^w13 - 1) * exp(w14 * (1 - R))
    return params[11] * pow(d, -params[12]) *
        (pow(s + 1, params[13]) - 1) * exp(params[14] * (1 - r));
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
      newState = rating == FsrsRating.again ? FsrsState.learning : FsrsState.review;
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
        newStability = _nextRecallStability(card.difficulty, card.stability, r);
        newReps = card.reps + 1;
        newState = FsrsState.review;
      } else {
        newStability = _nextForgetStability(card.difficulty, card.stability, r);
        newLapses = card.lapses + 1;
        newReps = 0;
        newState = FsrsState.relearning;
      }
    }

    newDifficulty = newDifficulty.clamp(1.0, 10.0);
    newStability = max(0.1, newStability);

    final interval = rating == FsrsRating.again
        ? 0  // review again today for lapses
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
      final aElapsed = a.lastReview != null ? now!.difference(a.lastReview!).inHours / 24.0 : 0.0;
      final bElapsed = b.lastReview != null ? now!.difference(b.lastReview!).inHours / 24.0 : 0.0;
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
```

**Step 3: Write comprehensive tests**

Create `test/services/fsrs_test.dart`:

```dart
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
        FsrsCardState(cardId: 'a', stability: 30, lastReview: now.subtract(const Duration(days: 1)), state: FsrsState.review),
        FsrsCardState(cardId: 'b', stability: 5, lastReview: now.subtract(const Duration(days: 10)), state: FsrsState.review),
        FsrsCardState(cardId: 'c', stability: 20, lastReview: now.subtract(const Duration(days: 5)), state: FsrsState.review),
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
```

**Step 4: Run tests**

Run: `flutter test test/services/fsrs_test.dart`
Expected: All tests pass.

**Step 5: Commit**

```bash
git add lib/services/fsrs.dart test/services/fsrs_test.dart
git commit -m "feat: add FSRS spaced repetition algorithm replacing SM-2"
```

---

### Task 2: Session Engine (algo-dev)

**Files:**
- Create: `lib/services/session_engine.dart`
- Create: `test/services/session_engine_test.dart`

**Context:** The session engine builds personalized daily sessions with 3 phases. It depends on the FSRS service (Task 1) for card scheduling and vocabulary data. The engine reads due cards, picks new content from the current chapter, and generates mixed practice questions.

**Step 1: Define session models**

Create `lib/services/session_engine.dart`:

```dart
import '../models/vocabulary_word.dart';
import 'fsrs.dart';

/// Session intensity setting
enum SessionLength {
  casual(reviewCards: 5, newItems: 3, mixedQuestions: 3),
  regular(reviewCards: 10, newItems: 5, mixedQuestions: 5),
  intense(reviewCards: 15, newItems: 8, mixedQuestions: 8);

  final int reviewCards;
  final int newItems;
  final int mixedQuestions;
  const SessionLength({
    required this.reviewCards,
    required this.newItems,
    required this.mixedQuestions,
  });
}

/// A single review question (quiz-style, 4 options)
class ReviewQuestion {
  final VocabularyWord word;
  final List<String> options; // 4 English options, one correct
  final int correctIndex;
  final bool isNew; // true if this is a newly introduced word

  const ReviewQuestion({
    required this.word,
    required this.options,
    required this.correctIndex,
    this.isNew = false,
  });
}

/// The full daily session
class DailySession {
  final List<ReviewQuestion> phase1Review;
  final List<VocabularyWord> phase2NewWords;
  final List<ReviewQuestion> phase2MiniQuiz;
  final List<ReviewQuestion> phase3Mixed;
  final int currentChapterId;

  const DailySession({
    required this.phase1Review,
    required this.phase2NewWords,
    required this.phase2MiniQuiz,
    required this.phase3Mixed,
    required this.currentChapterId,
  });

  int get totalItems =>
      phase1Review.length +
      phase2NewWords.length +
      phase2MiniQuiz.length +
      phase3Mixed.length;

  bool get isEmpty => totalItems == 0;

  /// Session preview text for the Today tab
  String get previewText {
    final parts = <String>[];
    if (phase1Review.isNotEmpty) parts.add('${phase1Review.length} reviews');
    if (phase2NewWords.isNotEmpty) parts.add('${phase2NewWords.length} new words');
    if (phase3Mixed.isNotEmpty) parts.add('${phase3Mixed.length} practice');
    return parts.join(' + ');
  }
}
```

**Step 2: Implement session builder**

Add `SessionEngine` class to the same file:

```dart
import 'dart:math';

class SessionEngine {
  final Fsrs fsrs;
  final Random _random;

  SessionEngine({Fsrs? fsrs, Random? random})
      : fsrs = fsrs ?? const Fsrs(),
        _random = random ?? Random();

  /// Build a daily session from available data.
  ///
  /// [dueCards] — cards scheduled for review today (with their FsrsCardState)
  /// [newWords] — vocabulary words not yet studied
  /// [allWords] — all vocabulary for generating distractors
  /// [settings] — session length preference
  /// [currentChapterId] — the chapter the user is currently on
  DailySession build({
    required List<MapEntry<FsrsCardState, VocabularyWord>> dueCards,
    required List<VocabularyWord> newWords,
    required List<VocabularyWord> allWords,
    required SessionLength settings,
    required int currentChapterId,
  }) {
    // Phase 1: Review due cards (prioritized by lowest retrievability)
    final sortedDue = fsrs.prioritize(
      dueCards.map((e) => e.key).toList(),
    );
    final phase1Cards = sortedDue.take(settings.reviewCards).toList();
    final phase1 = phase1Cards.map((cardState) {
      final entry = dueCards.firstWhere((e) => e.key.cardId == cardState.cardId);
      return _makeQuestion(entry.value, allWords);
    }).toList();

    // Phase 2: New words from current chapter
    final chapterNewWords = newWords.take(settings.newItems).toList();
    final phase2MiniQuiz = chapterNewWords.map((w) {
      return _makeQuestion(w, allWords, isNew: true);
    }).toList();

    // Phase 3: Mixed practice (interleave new + old)
    final mixedPool = <ReviewQuestion>[];
    // Add some new words again
    for (final w in chapterNewWords.take(settings.mixedQuestions ~/ 2)) {
      mixedPool.add(_makeQuestion(w, allWords, isNew: true));
    }
    // Add some review cards
    final remainingSlots = settings.mixedQuestions - mixedPool.length;
    final reviewForMix = dueCards
        .where((e) => !phase1Cards.any((p) => p.cardId == e.key.cardId))
        .take(remainingSlots);
    for (final entry in reviewForMix) {
      mixedPool.add(_makeQuestion(entry.value, allWords));
    }
    // If not enough review cards, add more from phase1
    if (mixedPool.length < settings.mixedQuestions) {
      final needed = settings.mixedQuestions - mixedPool.length;
      for (final entry in dueCards.take(needed)) {
        mixedPool.add(_makeQuestion(entry.value, allWords));
      }
    }
    mixedPool.shuffle(_random);

    return DailySession(
      phase1Review: phase1,
      phase2NewWords: chapterNewWords,
      phase2MiniQuiz: phase2MiniQuiz,
      phase3Mixed: mixedPool.take(settings.mixedQuestions).toList(),
      currentChapterId: currentChapterId,
    );
  }

  /// Generate a multiple-choice question for a vocabulary word.
  ReviewQuestion _makeQuestion(
    VocabularyWord word,
    List<VocabularyWord> allWords, {
    bool isNew = false,
  }) {
    // Pick 3 random distractors (different English translations)
    final distractors = allWords
        .where((w) => w.english != word.english)
        .toList()
      ..shuffle(_random);
    final options = distractors
        .take(3)
        .map((w) => w.english)
        .toList()
      ..add(word.english);
    options.shuffle(_random);

    return ReviewQuestion(
      word: word,
      options: options,
      correctIndex: options.indexOf(word.english),
      isNew: isNew,
    );
  }
}
```

**Step 3: Write tests**

Create `test/services/session_engine_test.dart`:

```dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/vocabulary_word.dart';
import 'package:french/services/fsrs.dart';
import 'package:french/services/session_engine.dart';

VocabularyWord _word(String id, String french, String english) => VocabularyWord(
      id: id, french: french, english: english,
      partOfSpeech: 'noun', exampleFr: '', exampleEn: '',
      level: 'A1', category: 'test', phonetic: '',
    );

void main() {
  late SessionEngine engine;
  late List<VocabularyWord> allWords;

  setUp(() {
    engine = SessionEngine(random: Random(42));
    allWords = [
      _word('1', 'bonjour', 'hello'),
      _word('2', 'merci', 'thank you'),
      _word('3', 'pain', 'bread'),
      _word('4', 'eau', 'water'),
      _word('5', 'maison', 'house'),
      _word('6', 'chat', 'cat'),
      _word('7', 'chien', 'dog'),
      _word('8', 'livre', 'book'),
    ];
  });

  test('casual session respects card limits', () {
    final dueCards = allWords.take(5).map((w) => MapEntry(
      FsrsCardState(cardId: w.id, stability: 5, lastReview: DateTime.now().subtract(const Duration(days: 5)), nextReview: DateTime.now(), state: FsrsState.review),
      w,
    )).toList();
    final newWords = allWords.skip(5).toList();

    final session = engine.build(
      dueCards: dueCards, newWords: newWords, allWords: allWords,
      settings: SessionLength.casual, currentChapterId: 1,
    );
    expect(session.phase1Review.length, lessThanOrEqualTo(5));
    expect(session.phase2NewWords.length, lessThanOrEqualTo(3));
    expect(session.phase3Mixed.length, lessThanOrEqualTo(3));
  });

  test('each question has 4 options with exactly one correct', () {
    final dueCards = allWords.take(3).map((w) => MapEntry(
      FsrsCardState(cardId: w.id, stability: 5, lastReview: DateTime.now().subtract(const Duration(days: 5)), nextReview: DateTime.now(), state: FsrsState.review),
      w,
    )).toList();

    final session = engine.build(
      dueCards: dueCards, newWords: [], allWords: allWords,
      settings: SessionLength.casual, currentChapterId: 1,
    );
    for (final q in session.phase1Review) {
      expect(q.options.length, 4);
      expect(q.options[q.correctIndex], q.word.english);
    }
  });

  test('empty due cards skips phase 1', () {
    final session = engine.build(
      dueCards: [], newWords: allWords, allWords: allWords,
      settings: SessionLength.casual, currentChapterId: 1,
    );
    expect(session.phase1Review, isEmpty);
    expect(session.phase2NewWords, isNotEmpty);
  });

  test('preview text describes session content', () {
    final dueCards = allWords.take(2).map((w) => MapEntry(
      FsrsCardState(cardId: w.id, stability: 5, lastReview: DateTime.now().subtract(const Duration(days: 5)), nextReview: DateTime.now(), state: FsrsState.review),
      w,
    )).toList();

    final session = engine.build(
      dueCards: dueCards, newWords: allWords.skip(2).toList(), allWords: allWords,
      settings: SessionLength.casual, currentChapterId: 1,
    );
    expect(session.previewText, contains('reviews'));
    expect(session.previewText, contains('new words'));
  });
}
```

**Step 4: Run tests**

Run: `flutter test test/services/session_engine_test.dart`
Expected: All tests pass.

**Step 5: Commit**

```bash
git add lib/services/session_engine.dart test/services/session_engine_test.dart
git commit -m "feat: add session engine for auto-generated daily practice"
```

---

### Task 3: SM-2 to FSRS Migration Logic (algo-dev)

**Files:**
- Create: `lib/services/sm2_migration.dart`
- Create: `test/services/sm2_migration_test.dart`

**Context:** Existing users have `CardProgress` data with SM-2 fields (`easeFactor`, `interval`, `repetitions`). We need a one-time migration to convert these to `FsrsCardState`. The old `CardProgress` model is in `lib/models/progress.dart:187-249`.

**Step 1: Write migration logic**

Create `lib/services/sm2_migration.dart`:

```dart
import '../models/progress.dart';
import 'fsrs.dart';

/// Converts SM-2 CardProgress entries to FSRS FsrsCardState.
class Sm2Migration {
  /// Convert a single SM-2 card to FSRS initial state.
  ///
  /// Mapping logic:
  /// - easeFactor 2.5 (default) → difficulty 5.0 (middle)
  /// - easeFactor < 2.0 → harder → higher difficulty
  /// - interval → initial stability (days)
  /// - repetitions > 0 → state = review, else newCard
  static FsrsCardState convert(CardProgress sm2Card) {
    // Map ease factor (1.3-2.5+) to difficulty (1-10, inverted)
    // EF 2.5 → D 5.0, EF 1.3 → D 9.0, EF 3.0+ → D 3.0
    final difficulty = (10.0 - (sm2Card.easeFactor - 1.3) * (7.0 / 1.7)).clamp(1.0, 10.0);

    // Stability approximation from SM-2 interval
    // If interval is 0, card hasn't been successfully reviewed yet
    final stability = sm2Card.interval > 0 ? sm2Card.interval.toDouble() : 0.0;

    // Parse next review date
    DateTime? nextReview;
    DateTime? lastReview;
    if (sm2Card.nextReviewDate.isNotEmpty) {
      try {
        nextReview = DateTime.parse(sm2Card.nextReviewDate);
        // Approximate last review from interval
        if (sm2Card.interval > 0) {
          lastReview = nextReview.subtract(Duration(days: sm2Card.interval));
        }
      } catch (_) {
        // Invalid date, leave as null
      }
    }

    final state = sm2Card.repetitions > 0 ? FsrsState.review : FsrsState.newCard;

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
  static Map<String, FsrsCardState> convertAll(Map<String, CardProgress> sm2Cards) {
    return sm2Cards.map((id, card) => MapEntry(id, convert(card)));
  }
}
```

**Step 2: Write tests**

Create `test/services/sm2_migration_test.dart`:

```dart
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
      cardId: 'hard', easeFactor: 1.3, interval: 1,
      repetitions: 5, nextReviewDate: '2026-02-15', quality: 3,
    );
    final fsrs = Sm2Migration.convert(card);
    expect(fsrs.difficulty, greaterThan(7.0));
  });

  test('easy SM-2 card (high ease factor) maps to low difficulty', () {
    final card = CardProgress(
      cardId: 'easy', easeFactor: 3.0, interval: 30,
      repetitions: 10, nextReviewDate: '2026-03-15', quality: 5,
    );
    final fsrs = Sm2Migration.convert(card);
    expect(fsrs.difficulty, lessThan(4.0));
  });

  test('interval maps to stability', () {
    final card = CardProgress(
      cardId: 'stable', easeFactor: 2.5, interval: 15,
      repetitions: 3, nextReviewDate: '2026-03-01', quality: 4,
    );
    final fsrs = Sm2Migration.convert(card);
    expect(fsrs.stability, equals(15.0));
    expect(fsrs.state, FsrsState.review);
  });

  test('convertAll processes multiple cards', () {
    final cards = {
      'a': CardProgress.initial('a'),
      'b': CardProgress(
        cardId: 'b', easeFactor: 2.5, interval: 10,
        repetitions: 2, nextReviewDate: '2026-02-20', quality: 4,
      ),
    };
    final result = Sm2Migration.convertAll(cards);
    expect(result.length, 2);
    expect(result['a']!.state, FsrsState.newCard);
    expect(result['b']!.state, FsrsState.review);
  });
}
```

**Step 3: Run tests**

Run: `flutter test test/services/sm2_migration_test.dart`
Expected: All tests pass.

**Step 4: Commit**

```bash
git add lib/services/sm2_migration.dart test/services/sm2_migration_test.dart
git commit -m "feat: add SM-2 to FSRS migration logic"
```

---

### Task 4: Drift Database Setup (data-dev)

**Files:**
- Create: `lib/database/app_database.dart`
- Create: `lib/database/tables.dart`
- Create: `lib/database/daos/card_state_dao.dart`
- Create: `lib/database/daos/review_log_dao.dart`
- Create: `lib/database/daos/chapter_progress_dao.dart`
- Create: `lib/database/connection/native.dart`
- Create: `lib/database/connection/web.dart`
- Modify: `pubspec.yaml` (add drift dependencies)
- Modify: `lib/main.dart` (initialize database)

**Context:** Current app uses `SharedPreferences` for all persistence (`lib/providers/progress_provider.dart`). Drift provides type-safe SQLite with code generation. Web support requires `drift/web.dart` with `WasmDatabase` factory.

**Step 1: Add Drift dependencies to pubspec.yaml**

Add to `pubspec.yaml` dependencies:
```yaml
  drift: ^2.22.1
  sqlite3_flutter_libs: ^0.5.28   # native SQLite for mobile/desktop
  path_provider: ^2.1.5            # for database file location
  path: ^1.9.1
```

Add to dev_dependencies:
```yaml
  drift_dev: ^2.22.2
  build_runner: ^2.4.15
```

Run: `flutter pub get`

**Step 2: Create table definitions**

Create `lib/database/tables.dart`:

```dart
import 'package:drift/drift.dart';

/// FSRS card state for each vocabulary word
class CardStates extends Table {
  TextColumn get cardId => text()();
  RealColumn get stability => real().withDefault(const Constant(0))();
  RealColumn get difficulty => real().withDefault(const Constant(5.0))();
  DateTimeColumn get lastReview => dateTime().nullable()();
  DateTimeColumn get nextReview => dateTime().nullable()();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  TextColumn get state => text().withDefault(const Constant('new'))();

  @override
  Set<Column> get primaryKey => {cardId};
}

/// Append-only review log for FSRS parameter optimization
class ReviewLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardId => text().references(CardStates, #cardId)();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get rating => integer()(); // 1 (Again) or 3 (Good)
  RealColumn get elapsedDays => real()();
  IntColumn get responseTimeMs => integer().nullable()();
  RealColumn get stability => real()();
  RealColumn get difficulty => real()();
}

/// Chapter progress tracking
class ChapterProgresses extends Table {
  TextColumn get chapterId => text()();
  TextColumn get sectionsCompleted =>
      text().withDefault(const Constant('[]'))();
  RealColumn get masteryPercent => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {chapterId};
}
```

**Step 3: Create platform-conditional database connection**

Create `lib/database/connection/native.dart`:

```dart
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../app_database.dart';

AppDatabase constructDb() {
  final db = LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'parler.db'));
    return NativeDatabase.createInBackground(file);
  });
  return AppDatabase(db);
}
```

Create `lib/database/connection/web.dart`:

```dart
import 'package:drift/wasm.dart';
import '../app_database.dart';

AppDatabase constructDb() {
  final db = LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'parler',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
  return AppDatabase(db);
}
```

**Step 4: Create DAOs**

Create `lib/database/daos/card_state_dao.dart`:

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'card_state_dao.g.dart';

@DriftAccessor(tables: [CardStates])
class CardStateDao extends DatabaseAccessor<AppDatabase>
    with _$CardStateDaoMixin {
  CardStateDao(super.db);

  Future<List<CardState>> allCards() => select(cardStates).get();

  Stream<List<CardState>> watchDueCards(DateTime now) {
    return (select(cardStates)
          ..where((t) =>
              t.nextReview.isSmallerOrEqualValue(now) |
              t.state.equals('new')))
        .watch();
  }

  Future<CardState?> getCard(String id) {
    return (select(cardStates)..where((t) => t.cardId.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertCard(CardStatesCompanion card) {
    return into(cardStates).insertOnConflictUpdate(card);
  }

  Future<void> upsertAll(List<CardStatesCompanion> cards) async {
    await batch((b) {
      for (final card in cards) {
        b.insert(cardStates, card, onConflict: DoUpdate((_) => card));
      }
    });
  }

  Stream<int> watchMasteredCount() {
    final query = selectOnly(cardStates)
      ..addColumns([cardStates.cardId.count()])
      ..where(cardStates.stability.isBiggerThanValue(30));
    return query
        .map((row) => row.read(cardStates.cardId.count()) ?? 0)
        .watchSingle();
  }

  Stream<int> watchTotalStudied() {
    final query = selectOnly(cardStates)
      ..addColumns([cardStates.cardId.count()])
      ..where(cardStates.state.isNotIn(['new']));
    return query
        .map((row) => row.read(cardStates.cardId.count()) ?? 0)
        .watchSingle();
  }
}
```

Create `lib/database/daos/review_log_dao.dart`:

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'review_log_dao.g.dart';

@DriftAccessor(tables: [ReviewLogs])
class ReviewLogDao extends DatabaseAccessor<AppDatabase>
    with _$ReviewLogDaoMixin {
  ReviewLogDao(super.db);

  Future<void> insert(ReviewLogsCompanion log) {
    return into(reviewLogs).insert(log);
  }

  Future<List<ReviewLog>> allLogs() => select(reviewLogs).get();

  Future<int> totalReviewCount() async {
    final count = reviewLogs.id.count();
    final query = selectOnly(reviewLogs)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
```

Create `lib/database/daos/chapter_progress_dao.dart`:

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'chapter_progress_dao.g.dart';

@DriftAccessor(tables: [ChapterProgresses])
class ChapterProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ChapterProgressDaoMixin {
  ChapterProgressDao(super.db);

  Stream<List<ChapterProgress>> watchAll() =>
      select(chapterProgresses).watch();

  Future<ChapterProgress?> getChapter(String id) {
    return (select(chapterProgresses)
          ..where((t) => t.chapterId.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsert(ChapterProgressesCompanion entry) {
    return into(chapterProgresses).insertOnConflictUpdate(entry);
  }
}
```

**Step 5: Create the database class**

Create `lib/database/app_database.dart`:

```dart
import 'package:drift/drift.dart';
import 'tables.dart';
import 'daos/card_state_dao.dart';
import 'daos/review_log_dao.dart';
import 'daos/chapter_progress_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [CardStates, ReviewLogs, ChapterProgresses],
  daos: [CardStateDao, ReviewLogDao, ChapterProgressDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
```

**Step 6: Run code generation**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `.g.dart` files for database and DAOs.

**Step 7: Commit**

```bash
git add lib/database/ pubspec.yaml pubspec.lock
git commit -m "feat: add Drift database with FSRS tables and web support"
```

---

### Task 5: Riverpod Providers for Drift + FSRS (data-dev)

**Files:**
- Create: `lib/providers/database_provider.dart`
- Modify: `lib/providers/progress_provider.dart` — rewire to use Drift for card states + review logs
- Modify: `lib/main.dart` — initialize database before runApp

**Context:** Current progress provider (`lib/providers/progress_provider.dart:1-113`) reads/writes all state to SharedPreferences as one JSON blob. We need to split this: FSRS card data goes to Drift, streak/preferences stay in SharedPreferences. The `sharedPreferencesProvider` pattern (override in main) should be replicated for the database.

**Step 1: Create database providers**

Create `lib/providers/database_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/daos/card_state_dao.dart';
import '../database/daos/review_log_dao.dart';
import '../database/daos/chapter_progress_dao.dart';
import '../services/fsrs.dart';

/// Database singleton — must be overridden in main.dart
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

/// DAOs
final cardStateDaoProvider = Provider<CardStateDao>((ref) {
  return ref.watch(appDatabaseProvider).cardStateDao;
});

final reviewLogDaoProvider = Provider<ReviewLogDao>((ref) {
  return ref.watch(appDatabaseProvider).reviewLogDao;
});

final chapterProgressDaoProvider = Provider<ChapterProgressDao>((ref) {
  return ref.watch(appDatabaseProvider).chapterProgressDao;
});

/// FSRS algorithm instance
final fsrsProvider = Provider<Fsrs>((ref) => const Fsrs());

/// Stream: cards due for review right now
final dueCardsProvider = StreamProvider<List<CardState>>((ref) {
  return ref.watch(cardStateDaoProvider).watchDueCards(DateTime.now());
});

/// Stream: count of mastered words (stability > 30 days)
final masteredCountProvider = StreamProvider<int>((ref) {
  return ref.watch(cardStateDaoProvider).watchMasteredCount();
});

/// Stream: total studied cards
final totalStudiedProvider = StreamProvider<int>((ref) {
  return ref.watch(cardStateDaoProvider).watchTotalStudied();
});

/// Stream: chapter progress
final chapterProgressStreamProvider = StreamProvider<List<ChapterProgress>>((ref) {
  return ref.watch(chapterProgressDaoProvider).watchAll();
});
```

**Step 2: Update progress provider**

Modify `lib/providers/progress_provider.dart` — keep SharedPreferences for streak/prefs, remove flashcard/chapter state (moved to Drift). Remove XP. Add streak freeze fields.

The updated file keeps `ProgressNotifier` for streak management and user preferences, but delegates card progress and chapter progress to Drift DAOs.

**Step 3: Update main.dart**

Add database initialization to `main()`:
- Import platform-conditional `constructDb()`
- Create database instance before `runApp`
- Override `appDatabaseProvider` alongside `sharedPreferencesProvider`
- Run SM-2 migration on first launch (check `migration_v2_done` flag in SharedPreferences)

**Step 4: Run build_runner if needed, then run existing tests**

Run: `flutter test`
Expected: Existing tests still pass (may need minor adjustments for removed XP field).

**Step 5: Commit**

```bash
git add lib/providers/database_provider.dart lib/providers/progress_provider.dart lib/main.dart
git commit -m "feat: wire Drift database to Riverpod providers"
```

---

### Task 6: TTS Service Upgrades (data-dev)

**Files:**
- Modify: `lib/services/tts_service.dart`
- Modify: `lib/widgets/speaker_button.dart` (if needed)

**Context:** Current TTS (`lib/services/tts_service.dart:1-42`) has a single `speak()` method at fixed rate 0.45. We need: configurable speed (slow 0.35 / normal 0.50), an `speakAuto()` that auto-plays, and speed stored in SharedPreferences.

**Step 1: Add speed setting and auto-play**

Update `lib/services/tts_service.dart`:

```dart
import 'package:flutter_tts/flutter_tts.dart';

enum TtsSpeed {
  slow(0.35),
  normal(0.50);

  final double rate;
  const TtsSpeed(this.rate);
}

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  TtsSpeed _speed = TtsSpeed.normal;

  TtsSpeed get speed => _speed;

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(_speed.rate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );
    _initialized = true;
  }

  Future<void> setSpeed(TtsSpeed speed) async {
    _speed = speed;
    if (_initialized) {
      await _tts.setSpeechRate(speed.rate);
    }
  }

  /// Manual speak — triggered by user tap
  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Auto-play — used in sessions when card appears
  Future<void> speakAuto(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
```

**Step 2: Commit**

```bash
git add lib/services/tts_service.dart
git commit -m "feat: add configurable TTS speed and auto-play method"
```

---

### Task 7: Today Tab Screen (ui-dev)

**Files:**
- Create: `lib/screens/today/today_screen.dart`

**Context:** This is the new default landing tab. It shows streak, session preview, words mastered, and the "Start Session" CTA. It reads from `dueCardsProvider`, `masteredCountProvider`, and progress providers.

**Design reference:** See design doc Section 3 — Tab 1: "Today".

**Step 1: Build TodayScreen**

Key elements:
- Streak banner at top with flame icon, day count, streak freeze indicator
- Large "Start Session" button (primary CTA, French red color)
- Session preview text: "Today: X reviews + Y new words + Z practice"
- Words mastered counter with progress ring
- Chapter roadmap mini-view (horizontal scroll of chapter dots/nodes)

Use existing widgets where possible: `ProgressRing` (`lib/widgets/progress_ring.dart`), `StatBadge` (`lib/widgets/stat_badge.dart`).

Use `flutter_animate` for entrance animations (consistent with existing app style — fade + slideY).

Read providers: `dueCardsProvider`, `masteredCountProvider`, `progressProvider` (for streak), `chaptersProvider` (for roadmap).

Navigation: "Start Session" pushes to `/session` route (built in Task 8).

**Step 2: Commit**

```bash
git add lib/screens/today/today_screen.dart
git commit -m "feat: add Today tab with session preview and streak"
```

---

### Task 8: Session Play Screens (ui-dev)

**Files:**
- Create: `lib/screens/session/session_screen.dart`
- Create: `lib/screens/session/session_complete_screen.dart`
- Create: `lib/widgets/quiz_card.dart`

**Context:** This is the 3-phase session experience. The session screen receives a `DailySession` object (built by session engine) and steps through Phase 1 → Phase 2 → Phase 3.

**Step 1: Build QuizCard widget**

Reusable widget for quiz-style review:
- Shows French word (large, Playfair Display) + phonetic
- Auto-plays TTS via `ttsService.speakAuto(word.french)` when card appears
- 4 English option buttons below
- On tap: highlight correct (green) / wrong (red), brief delay, advance
- Response time tracked from card appearance to tap

**Step 2: Build SessionScreen**

State machine flow:
1. Build session from `SessionEngine`
2. Show progress bar (current item / total items)
3. Phase 1: Render `QuizCard` for each review question
4. Phase 2: First show new words (French + English + example + TTS), then mini-quiz
5. Phase 3: Render `QuizCard` for mixed practice
6. After each answer: record result via FSRS + write to Drift
7. On complete: navigate to SessionCompleteScreen

**Step 3: Build SessionCompleteScreen**

Shows:
- Checkmark/confetti animation (confetti on streak milestones)
- Stats: words reviewed, new items learned, streak count
- Words Mastered counter update
- "Done for today" button → pops back to Today tab
- Updates streak via `progressNotifier.updateStreak()`

**Step 4: Commit**

```bash
git add lib/screens/session/ lib/widgets/quiz_card.dart
git commit -m "feat: add session play screens with quiz-style reviews"
```

---

### Task 9: Learn Tab Screen (ui-dev)

**Files:**
- Create: `lib/screens/learn/learn_screen.dart`
- Reuse: existing `LessonDetailScreen`, `TefScreen`, `TefPlayScreen`

**Context:** The Learn tab consolidates the old Lessons, Words, TEF, and Quiz tabs into one browsable view. It shows chapters (with "Recommended" badge on current), word bank access, and TEF practice.

**Step 1: Build LearnScreen**

Sections:
- **Chapters section**: List of all 10 chapters. Current chapter gets "Recommended" badge. Completed chapters show checkmark + mastery %. Each chapter taps to `/lesson/:id` (reuse existing `LessonDetailScreen`).
- **Word Bank section**: "Browse Words" card → taps to `/words` (reuse existing `WordsScreen` but without the flashcard review flow — just browsing with manual TTS)
- **TEF Practice section**: "TEF Prep" card → taps to `/tef` (reuse existing `TefScreen`)

Use existing `chaptersProvider` and `chapterProgressStreamProvider` for data.

**Step 2: Commit**

```bash
git add lib/screens/learn/learn_screen.dart
git commit -m "feat: add Learn tab consolidating chapters, words, and TEF"
```

---

### Task 10: Profile Tab Screen (ui-dev)

**Files:**
- Create: `lib/screens/profile/new_profile_screen.dart`
- Modify or replace: `lib/screens/profile/profile_screen.dart`

**Context:** Current profile screen (`lib/screens/profile/profile_screen.dart`) shows XP, streak, chapters completed. Redesign to remove XP, add Words Mastered, add Settings section, add chapter mastery bars.

**Step 1: Build new ProfileScreen**

Sections:
- **Stats dashboard**: 2x2 grid — streak (flame icon), words mastered, chapters completed, total reviews
- **Chapter mastery bars**: List of all chapters with progress bars showing mastery % (FSRS retention-based). Read from `chapterProgressStreamProvider`.
- **Settings section**:
  - Session length picker (Casual/Regular/Intense) — stored in SharedPreferences
  - TTS speed toggle (Slow/Normal) — updates `TtsService`
  - Dark mode toggle — reuse existing `themeModeProvider`
  - Streak freeze count display

**Step 2: Commit**

```bash
git add lib/screens/profile/
git commit -m "feat: redesign Profile tab with mastery stats and settings"
```

---

### Task 11: Router Rewrite — 3-Tab Navigation (ui-dev)

**Files:**
- Modify: `lib/core/router/app_router.dart`

**Context:** Current router (`lib/core/router/app_router.dart:1-348`) has 4-tab `ShellRoute` (Lessons/Words/TEF/Quiz). Rewrite to 3 tabs (Today/Learn/Profile) and add session routes.

**Step 1: Rewrite AppShell and routes**

New shell routes:
```
ShellRoute:
  /today  → TodayScreen
  /learn  → LearnScreen
  /profile → ProfileScreen
```

New top-level routes (pushed on top of shell):
```
/session         → SessionScreen
/session/complete → SessionCompleteScreen
/lesson/:id      → LessonDetailScreen (keep existing)
/tef/:testId     → TefPlayScreen (keep existing)
/words           → WordsScreen (browsing only, moved here)
/words/:category → WordBankScreen (browsing, no flashcard flow)
```

Update `AppShell._destinations`:
```dart
static const _destinations = [
  _NavDest(icon: Icons.today_rounded, label: 'Today', path: '/today'),
  _NavDest(icon: Icons.menu_book_rounded, label: 'Learn', path: '/learn'),
  _NavDest(icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
];
```

Update `_currentIndex` to match new paths.

Change `initialLocation` from `/splash` to `/splash` (keep splash, it redirects to `/today`).

Update `SplashScreen` to navigate to `/today` instead of `/lessons`.

**Step 2: Remove old screens that are no longer used**

The following can be deleted or left (they may still be referenced from Learn tab):
- `lib/screens/words/flashcard_screen.dart` — replaced by session quiz-style
- `lib/screens/quiz/quiz_screen.dart` — quizzes now part of sessions
- `lib/screens/quiz/quiz_play_screen.dart` — replaced by session
- `lib/screens/lessons/lessons_screen.dart` — replaced by Learn tab
- `lib/screens/home/home_screen.dart` — if exists, replaced by Today tab

Don't delete yet if Learn tab still routes to them. Just remove from shell navigation.

**Step 3: Commit**

```bash
git add lib/core/router/app_router.dart lib/screens/splash/splash_screen.dart
git commit -m "feat: rewrite router to 3-tab navigation (Today/Learn/Profile)"
```

---

### Task 12: Integration Testing & Cleanup (all agents)

**Files:**
- Modify: existing tests to account for model changes
- Run: full test suite
- Run: `flutter analyze`

**Step 1: Run full test suite**

Run: `flutter test`
Fix any failures from removed XP, changed models, etc.

**Step 2: Run analyzer**

Run: `flutter analyze`
Fix any lint errors or warnings.

**Step 3: Run the app**

Run: `flutter run` on a device/emulator
Verify:
- App launches to Today tab
- "Start Session" works
- Quiz-style review cards appear with TTS auto-play
- Correct/wrong answers recorded
- Session completes with stats
- Learn tab shows chapters
- Profile shows streak + words mastered
- Settings work (session length, TTS speed, dark mode)

**Step 4: Commit**

```bash
git add -A
git commit -m "fix: integration fixes and test updates for session-first redesign"
```

---

## Reviewer Checkpoints

The **reviewer** agent should check after each task:

1. **After Task 1 (FSRS):** Verify algorithm math against FSRS spec. Check edge cases (zero stability, negative elapsed time).
2. **After Task 2 (Session Engine):** Verify session sizing limits are respected. Check distractor generation doesn't duplicate correct answer.
3. **After Task 3 (Migration):** Verify ease factor → difficulty mapping is reasonable. Check date parsing edge cases.
4. **After Task 4 (Drift):** Verify code generation works. Check web connection factory compiles. Verify foreign key constraints.
5. **After Task 5 (Providers):** Verify no circular dependencies. Check stream providers dispose correctly.
6. **After Tasks 7-11 (UI):** Verify touch targets >= 48dp. Check dark mode. Verify animations are subtle. Check accessibility labels.
7. **After Task 12 (Integration):** Full app walkthrough. Verify all user flows work end-to-end.
