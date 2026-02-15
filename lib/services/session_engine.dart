import 'dart:math';

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
    if (phase2NewWords.isNotEmpty) {
      parts.add('${phase2NewWords.length} new words');
    }
    if (phase3Mixed.isNotEmpty) parts.add('${phase3Mixed.length} practice');
    return parts.join(' + ');
  }
}

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
      final entry =
          dueCards.firstWhere((e) => e.key.cardId == cardState.cardId);
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
    final options = distractors.take(3).map((w) => w.english).toList()
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
