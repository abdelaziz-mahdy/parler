import 'dart:math';

import '../models/false_friend.dart';
import '../models/phrase.dart';
import '../models/verb.dart';
import '../models/vocabulary_word.dart';
import 'fsrs.dart';

// ---------------------------------------------------------------------------
// Content → VocabularyWord converters
// ---------------------------------------------------------------------------

/// Convert a Phrase to a VocabularyWord so it can flow through the quiz engine.
VocabularyWord phraseToVocab(Phrase p) => VocabularyWord(
      id: 'phrase_${p.french.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), '_')}',
      french: p.french,
      english: p.english,
      partOfSpeech: 'expression',
      exampleFr: p.usage ?? '',
      exampleEn: '',
      level: 'A1',
      category: 'phrases',
      phonetic: '',
    );

/// Convert a Verb to a VocabularyWord.
VocabularyWord verbToVocab(Verb v) => VocabularyWord(
      id: 'verb_${v.infinitive.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), '_')}',
      french: v.infinitive,
      english: v.meaning,
      partOfSpeech: 'verb',
      exampleFr: '',
      exampleEn: '',
      level: 'A1',
      category: 'verbs',
      phonetic: '',
    );

/// Convert a FalseFriend to a VocabularyWord.
/// The english field is the *actual* meaning, so the quiz naturally tests
/// whether the user knows the real meaning vs the deceptive cognate.
/// The phonetic field stores the trap word (what it "looks like" in English)
/// so the quiz engine can include it as a deliberate distractor.
VocabularyWord falseFriendToVocab(FalseFriend f) => VocabularyWord(
      id: 'ff_${f.frenchWord.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), '_')}',
      french: f.frenchWord,
      english: f.actualMeaning,
      partOfSpeech: 'expression',
      exampleFr: '',
      exampleEn: 'Looks like "${f.looksLike}" but means "${f.actualMeaning}"',
      level: 'B1',
      category: 'false_friends',
      phonetic: f.looksLike, // trap word stored here for quiz distractor
    );

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

/// The type of quiz question
enum QuestionMode {
  /// Show French word, pick English translation
  frenchToEnglish,

  /// Show English word, pick French translation
  englishToFrench,

  /// Show sentence with blank, pick the missing French word
  cloze,
}

/// A single review question (quiz-style, 4 options)
class ReviewQuestion {
  final VocabularyWord word;
  final List<String> options; // 4 options (English or French depending on mode)
  final int correctIndex;
  final bool isNew; // true if this is a newly introduced word
  final QuestionMode mode;
  final String? clozeSentence; // For cloze mode: "J'ai mal au ___"
  final String? memoryHint; // Post-answer memory hook

  const ReviewQuestion({
    required this.word,
    required this.options,
    required this.correctIndex,
    this.isNew = false,
    this.mode = QuestionMode.frenchToEnglish,
    this.clozeSentence,
    this.memoryHint,
  });
}

/// A matching challenge: 4 word pairs to connect French ↔ English
class MatchingChallenge {
  final List<VocabularyWord> words;
  final List<String> shuffledFrench;
  final List<String> shuffledEnglish;

  const MatchingChallenge({
    required this.words,
    required this.shuffledFrench,
    required this.shuffledEnglish,
  });
}

/// The full daily session
class DailySession {
  final List<ReviewQuestion> phase1Review;
  final List<VocabularyWord> phase2NewWords;
  final List<ReviewQuestion> phase2MiniQuiz;
  final List<ReviewQuestion> phase3Mixed;
  final MatchingChallenge? matchingChallenge;
  final int currentChapterId;

  const DailySession({
    required this.phase1Review,
    required this.phase2NewWords,
    required this.phase2MiniQuiz,
    required this.phase3Mixed,
    this.matchingChallenge,
    required this.currentChapterId,
  });

  int get totalItems =>
      phase1Review.length +
      phase2NewWords.length +
      phase2MiniQuiz.length +
      phase3Mixed.length +
      (matchingChallenge != null ? 1 : 0);

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
  /// [bonusContent] — extra VocabularyWord items (phrases, verbs, false friends)
  ///   mixed into Phase 3 for variety
  DailySession build({
    required List<MapEntry<FsrsCardState, VocabularyWord>> dueCards,
    required List<VocabularyWord> newWords,
    required List<VocabularyWord> allWords,
    required SessionLength settings,
    required int currentChapterId,
    List<VocabularyWord> bonusContent = const [],
  }) {
    // Phase 1: Review due cards (prioritized by lowest retrievability)
    final sortedDue = fsrs.prioritize(
      dueCards.map((e) => e.key).toList(),
    );
    final phase1Cards = sortedDue.take(settings.reviewCards).toList();
    final phase1 = phase1Cards.map((cardState) {
      final entry =
          dueCards.firstWhere((e) => e.key.cardId == cardState.cardId);
      return _makeRandomQuestion(entry.value, allWords);
    }).toList();

    // Phase 2: New words from current chapter
    final chapterNewWords = newWords.take(settings.newItems).toList();
    final phase2MiniQuiz = chapterNewWords.map((w) {
      return _makeFrenchToEnglish(w, allWords, isNew: true);
    }).toList();

    // Phase 3: Mixed practice (interleave new + old + bonus content)
    // Combine allWords with bonus content for the distractor pool
    final distractorPool = [...allWords, ...bonusContent];

    final mixedPool = <ReviewQuestion>[];
    // Add some new words again
    for (final w in chapterNewWords.take(settings.mixedQuestions ~/ 2)) {
      mixedPool.add(_makeRandomQuestion(w, distractorPool, isNew: true));
    }
    // Add some review cards
    final remainingSlots = settings.mixedQuestions - mixedPool.length;
    final reviewForMix = dueCards
        .where((e) => !phase1Cards.any((p) => p.cardId == e.key.cardId))
        .take(remainingSlots);
    for (final entry in reviewForMix) {
      mixedPool.add(_makeRandomQuestion(entry.value, distractorPool));
    }
    // If not enough review cards, add more from phase1
    if (mixedPool.length < settings.mixedQuestions) {
      final needed = settings.mixedQuestions - mixedPool.length;
      for (final entry in dueCards.take(needed)) {
        mixedPool.add(_makeRandomQuestion(entry.value, distractorPool));
      }
    }
    // Inject bonus content questions (phrases, verbs, false friends)
    if (bonusContent.isNotEmpty) {
      final shuffledBonus = List<VocabularyWord>.from(bonusContent)
        ..shuffle(_random);
      // Add 2-3 bonus questions depending on session length
      final bonusCount = switch (settings) {
        SessionLength.casual => 1,
        SessionLength.regular => 2,
        SessionLength.intense => 3,
      };
      for (final bonus in shuffledBonus.take(bonusCount)) {
        if (bonus.category == 'false_friends' && bonus.phonetic.isNotEmpty) {
          // False friends get a trap question with the misleading word as option
          mixedPool.add(_makeFalseFriendQuestion(bonus, distractorPool));
        } else {
          mixedPool.add(_makeFrenchToEnglish(bonus, distractorPool));
        }
      }
    }
    mixedPool.shuffle(_random);

    // Build a matching challenge from words seen in this session
    final matchingPool = <VocabularyWord>[
      ...chapterNewWords,
      ...dueCards.map((e) => e.value),
    ];
    final matching = _buildMatchingChallenge(matchingPool);

    return DailySession(
      phase1Review: phase1,
      phase2NewWords: chapterNewWords,
      phase2MiniQuiz: phase2MiniQuiz,
      phase3Mixed: mixedPool.take(settings.mixedQuestions).toList(),
      matchingChallenge: matching,
      currentChapterId: currentChapterId,
    );
  }

  /// Collect 3 distractor words, preferring same-category.
  List<VocabularyWord> _pickDistractors(
    VocabularyWord word,
    List<VocabularyWord> allWords,
  ) {
    final sameCategory = allWords
        .where((w) => w.id != word.id && w.category == word.category)
        .toList()
      ..shuffle(_random);

    final otherCategory = allWords
        .where((w) => w.id != word.id && w.category != word.category)
        .toList()
      ..shuffle(_random);

    final distractors = <VocabularyWord>[];
    distractors.addAll(sameCategory.take(3));
    if (distractors.length < 3) {
      distractors.addAll(otherCategory.take(3 - distractors.length));
    }
    return distractors;
  }

  /// Show French word, pick from 4 English options.
  /// Prefers distractors from the same category so choices aren't trivially
  /// distinguishable. Falls back to other categories if not enough same-category
  /// words exist.
  ReviewQuestion _makeFrenchToEnglish(
    VocabularyWord word,
    List<VocabularyWord> allWords, {
    bool isNew = false,
  }) {
    final distractors = _pickDistractors(word, allWords);

    final options = distractors.map((w) => w.english).toList()
      ..add(word.english);
    options.shuffle(_random);

    return ReviewQuestion(
      word: word,
      options: options,
      correctIndex: options.indexOf(word.english),
      isNew: isNew,
      mode: QuestionMode.frenchToEnglish,
      memoryHint: _generateMemoryHint(word, allWords),
    );
  }

  /// Show English word, pick from 4 French options (using frenchWithArticle).
  ReviewQuestion _makeEnglishToFrench(
    VocabularyWord word,
    List<VocabularyWord> allWords, {
    bool isNew = false,
  }) {
    final distractors = _pickDistractors(word, allWords);

    final options =
        distractors.map((w) => w.frenchWithArticle).toList()
          ..add(word.frenchWithArticle);
    options.shuffle(_random);

    return ReviewQuestion(
      word: word,
      options: options,
      correctIndex: options.indexOf(word.frenchWithArticle),
      isNew: isNew,
      mode: QuestionMode.englishToFrench,
      memoryHint: _generateMemoryHint(word, allWords),
    );
  }

  /// Show sentence with blank, pick the missing French word.
  /// Returns null if the word doesn't appear in its own example sentence,
  /// so callers can fall back to another mode.
  ReviewQuestion? _makeClozeQuestion(
    VocabularyWord word,
    List<VocabularyWord> allWords, {
    bool isNew = false,
  }) {
    final sentence = word.exampleFr;
    if (sentence.isEmpty || !sentence.contains(word.french)) {
      return null;
    }

    final blanked = sentence.replaceFirst(word.french, '___');
    final distractors = _pickDistractors(word, allWords);

    final options = distractors.map((w) => w.french).toList()
      ..add(word.french);
    options.shuffle(_random);

    return ReviewQuestion(
      word: word,
      options: options,
      correctIndex: options.indexOf(word.french),
      isNew: isNew,
      mode: QuestionMode.cloze,
      clozeSentence: blanked,
      memoryHint: _generateMemoryHint(word, allWords),
    );
  }

  /// Show French false friend word, pick the ACTUAL meaning from 4 options.
  /// One distractor is always the trap word (what it "looks like" in English).
  ReviewQuestion _makeFalseFriendQuestion(
    VocabularyWord word,
    List<VocabularyWord> allWords,
  ) {
    final trapWord = word.phonetic; // stored by falseFriendToVocab
    final distractors = _pickDistractors(word, allWords);

    // Build options: correct answer + trap + 2 random distractors
    final options = <String>[word.english];
    // Always include the trap word if it's different from the correct answer
    if (trapWord.isNotEmpty && trapWord != word.english) {
      options.add(trapWord);
    }
    // Fill remaining slots with distractor meanings
    for (final d in distractors) {
      if (options.length >= 4) break;
      if (!options.contains(d.english)) {
        options.add(d.english);
      }
    }
    // Ensure we have exactly 4 options
    while (options.length < 4) {
      options.add('(unknown)');
    }
    options.shuffle(_random);

    return ReviewQuestion(
      word: word,
      options: options,
      correctIndex: options.indexOf(word.english),
      mode: QuestionMode.frenchToEnglish,
      memoryHint: '⚠️ False friend! "${word.french}" looks like "$trapWord" '
          'but actually means "${word.english}"',
    );
  }

  /// Generate a memory hint string for post-answer display.
  String _generateMemoryHint(VocabularyWord word, List<VocabularyWord> allWords) {
    final buf = StringBuffer();

    if (word.partOfSpeech == 'verb') {
      buf.write('Category: ${word.category} | Verb');
    } else if (word.partOfSpeech == 'noun') {
      final genderArticle =
          word.gender == 'f' ? 'la' : 'le';
      buf.write('Category: ${word.category} | Gender: $genderArticle');
    } else {
      buf.write('Category: ${word.category}');
    }

    // Find related words in the same category
    final related = allWords
        .where((w) => w.id != word.id && w.category == word.category)
        .take(3)
        .map((w) => w.french)
        .toList();
    if (related.isNotEmpty) {
      buf.write(' | Related: ${related.join(', ')}');
    }

    return buf.toString();
  }

  /// Randomly pick a question mode and build the question.
  /// Distribution: 40% frenchToEnglish, 30% englishToFrench, 30% cloze.
  /// Falls back to frenchToEnglish if cloze cannot be generated.
  ReviewQuestion _makeRandomQuestion(
    VocabularyWord word,
    List<VocabularyWord> allWords, {
    bool isNew = false,
  }) {
    final roll = _random.nextDouble();
    if (roll < 0.4) {
      return _makeFrenchToEnglish(word, allWords, isNew: isNew);
    } else if (roll < 0.7) {
      return _makeEnglishToFrench(word, allWords, isNew: isNew);
    } else {
      // Try cloze, fall back to frenchToEnglish
      return _makeClozeQuestion(word, allWords, isNew: isNew) ??
          _makeFrenchToEnglish(word, allWords, isNew: isNew);
    }
  }

  /// Build a matching challenge from 4 words (French ↔ English pairs).
  /// Returns null if fewer than 4 unique words are available.
  MatchingChallenge? _buildMatchingChallenge(List<VocabularyWord> pool) {
    // Deduplicate by id
    final unique = <String, VocabularyWord>{};
    for (final w in pool) {
      unique[w.id] = w;
    }
    final candidates = unique.values.toList()..shuffle(_random);
    if (candidates.length < 4) return null;

    final words = candidates.take(4).toList();
    final french = words.map((w) => w.frenchWithArticle).toList()
      ..shuffle(_random);
    final english = words.map((w) => w.english).toList()..shuffle(_random);

    return MatchingChallenge(
      words: words,
      shuffledFrench: french,
      shuffledEnglish: english,
    );
  }
}
