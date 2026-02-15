import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/vocabulary_word.dart';
import 'package:french/services/fsrs.dart';
import 'package:french/services/session_engine.dart';

VocabularyWord _word(
  String id,
  String french,
  String english, {
  String category = 'test',
  String partOfSpeech = 'noun',
  String? gender,
  String exampleFr = '',
}) =>
    VocabularyWord(
      id: id,
      french: french,
      english: english,
      partOfSpeech: partOfSpeech,
      gender: gender,
      exampleFr: exampleFr,
      exampleEn: '',
      level: 'A1',
      category: category,
      phonetic: '',
    );

List<MapEntry<FsrsCardState, VocabularyWord>> _makeDueCards(
    List<VocabularyWord> words) {
  return words
      .map((w) => MapEntry(
            FsrsCardState(
              cardId: w.id,
              stability: 5,
              lastReview: DateTime.now().subtract(const Duration(days: 5)),
              nextReview: DateTime.now(),
              state: FsrsState.review,
            ),
            w,
          ))
      .toList();
}

void main() {
  late SessionEngine engine;
  late List<VocabularyWord> allWords;

  setUp(() {
    engine = SessionEngine(random: Random(42));
    allWords = [
      _word('1', 'bonjour', 'hello'),
      _word('2', 'merci', 'thank you'),
      _word('3', 'pain', 'bread', category: 'food', gender: 'm'),
      _word('4', 'eau', 'water', category: 'food', gender: 'f'),
      _word('5', 'maison', 'house', gender: 'f'),
      _word('6', 'chat', 'cat', gender: 'm'),
      _word('7', 'chien', 'dog', gender: 'm'),
      _word('8', 'livre', 'book', gender: 'm'),
    ];
  });

  test('casual session respects card limits', () {
    final dueCards = _makeDueCards(allWords.take(5).toList());
    final newWords = allWords.skip(5).toList();

    final session = engine.build(
      dueCards: dueCards,
      newWords: newWords,
      allWords: allWords,
      settings: SessionLength.casual,
      currentChapterId: 1,
    );
    expect(session.phase1Review.length, lessThanOrEqualTo(5));
    expect(session.phase2NewWords.length, lessThanOrEqualTo(3));
    expect(session.phase3Mixed.length, lessThanOrEqualTo(3));
  });

  test('each question has 4 options with exactly one correct', () {
    final dueCards = _makeDueCards(allWords.take(3).toList());

    final session = engine.build(
      dueCards: dueCards,
      newWords: [],
      allWords: allWords,
      settings: SessionLength.casual,
      currentChapterId: 1,
    );
    for (final q in session.phase1Review) {
      expect(q.options.length, 4);
      // Correct answer depends on mode
      switch (q.mode) {
        case QuestionMode.frenchToEnglish:
          expect(q.options[q.correctIndex], q.word.english);
        case QuestionMode.englishToFrench:
          expect(q.options[q.correctIndex], q.word.frenchWithArticle);
        case QuestionMode.cloze:
          expect(q.options[q.correctIndex], q.word.french);
          expect(q.clozeSentence, isNotNull);
      }
    }
  });

  test('empty due cards skips phase 1', () {
    final session = engine.build(
      dueCards: [],
      newWords: allWords,
      allWords: allWords,
      settings: SessionLength.casual,
      currentChapterId: 1,
    );
    expect(session.phase1Review, isEmpty);
    expect(session.phase2NewWords, isNotEmpty);
  });

  test('preview text describes session content', () {
    final dueCards = _makeDueCards(allWords.take(2).toList());

    final session = engine.build(
      dueCards: dueCards,
      newWords: allWords.skip(2).toList(),
      allWords: allWords,
      settings: SessionLength.casual,
      currentChapterId: 1,
    );
    expect(session.previewText, contains('reviews'));
    expect(session.previewText, contains('new words'));
  });

  test('phase2 mini-quiz always uses frenchToEnglish mode', () {
    final session = engine.build(
      dueCards: [],
      newWords: allWords,
      allWords: allWords,
      settings: SessionLength.regular,
      currentChapterId: 1,
    );
    for (final q in session.phase2MiniQuiz) {
      expect(q.mode, QuestionMode.frenchToEnglish);
      expect(q.isNew, isTrue);
      expect(q.options[q.correctIndex], q.word.english);
    }
  });

  test('all questions have memoryHint populated', () {
    final dueCards = _makeDueCards(allWords.take(3).toList());
    final session = engine.build(
      dueCards: dueCards,
      newWords: allWords.skip(3).toList(),
      allWords: allWords,
      settings: SessionLength.regular,
      currentChapterId: 1,
    );
    for (final q in [
      ...session.phase1Review,
      ...session.phase2MiniQuiz,
      ...session.phase3Mixed,
    ]) {
      expect(q.memoryHint, isNotNull);
      expect(q.memoryHint, isNotEmpty);
    }
  });

  group('englishToFrench', () {
    test('produces French options with articles for nouns', () {
      // Use a fixed seed that produces englishToFrench for predictability
      // We test directly by building a session and checking for the mode
      final wordsWithGender = [
        _word('10', 'pain', 'bread',
            category: 'food', gender: 'm', partOfSpeech: 'noun'),
        _word('11', 'eau', 'water',
            category: 'food', gender: 'f', partOfSpeech: 'noun'),
        _word('12', 'lait', 'milk',
            category: 'food', gender: 'm', partOfSpeech: 'noun'),
        _word('13', 'fromage', 'cheese',
            category: 'food', gender: 'm', partOfSpeech: 'noun'),
        _word('14', 'viande', 'meat',
            category: 'food', gender: 'f', partOfSpeech: 'noun'),
      ];

      // Build many sessions with different seeds to find englishToFrench questions
      ReviewQuestion? found;
      for (var seed = 0; seed < 100 && found == null; seed++) {
        final eng = SessionEngine(random: Random(seed));
        final dueCards = _makeDueCards(wordsWithGender);
        final session = eng.build(
          dueCards: dueCards,
          newWords: [],
          allWords: wordsWithGender,
          settings: SessionLength.intense,
          currentChapterId: 1,
        );
        final matches = [
          ...session.phase1Review,
          ...session.phase3Mixed,
        ].where((q) => q.mode == QuestionMode.englishToFrench);
        if (matches.isNotEmpty) found = matches.first;
      }

      expect(found, isNotNull, reason: 'Should find englishToFrench question');
      // The correct option should be the frenchWithArticle of the word
      expect(found!.options[found.correctIndex], found.word.frenchWithArticle);
      // All options should look like French words (contain article or be plain)
      for (final opt in found.options) {
        expect(opt, isNotEmpty);
      }
    });
  });

  group('cloze questions', () {
    test('have blanked sentences when word appears in example', () {
      final wordsWithExamples = [
        _word('20', 'pain', 'bread',
            category: 'food',
            gender: 'm',
            exampleFr: "J'achète du pain."),
        _word('21', 'eau', 'water',
            category: 'food',
            gender: 'f',
            exampleFr: "Je bois de l'eau."),
        _word('22', 'lait', 'milk',
            category: 'food',
            gender: 'm',
            exampleFr: 'Le lait est frais.'),
        _word('23', 'fromage', 'cheese',
            category: 'food',
            gender: 'm',
            exampleFr: 'Le fromage est bon.'),
        _word('24', 'viande', 'meat',
            category: 'food',
            gender: 'f',
            exampleFr: 'La viande est cuite.'),
      ];

      ReviewQuestion? found;
      for (var seed = 0; seed < 200 && found == null; seed++) {
        final eng = SessionEngine(random: Random(seed));
        final dueCards = _makeDueCards(wordsWithExamples);
        final session = eng.build(
          dueCards: dueCards,
          newWords: [],
          allWords: wordsWithExamples,
          settings: SessionLength.intense,
          currentChapterId: 1,
        );
        final matches = [
          ...session.phase1Review,
          ...session.phase3Mixed,
        ].where((q) => q.mode == QuestionMode.cloze);
        if (matches.isNotEmpty) found = matches.first;
      }

      expect(found, isNotNull, reason: 'Should find cloze question');
      expect(found!.clozeSentence, contains('___'));
      expect(found.clozeSentence, isNot(contains(found.word.french)));
      expect(found.options[found.correctIndex], found.word.french);
    });

    test('falls back to frenchToEnglish when word not in example', () {
      final wordsNoMatch = [
        _word('30', 'pain', 'bread',
            category: 'food',
            gender: 'm',
            exampleFr: 'Bonjour le monde.'), // "pain" not in sentence
        _word('31', 'eau', 'water',
            category: 'food',
            gender: 'f',
            exampleFr: 'Salut tout le monde.'),
        _word('32', 'lait', 'milk',
            category: 'food', gender: 'm', exampleFr: 'Merci beaucoup.'),
        _word('33', 'fromage', 'cheese',
            category: 'food', gender: 'm', exampleFr: 'Au revoir.'),
        _word('34', 'viande', 'meat',
            category: 'food', gender: 'f', exampleFr: 'Bonsoir.'),
      ];

      // With these words, cloze should always fail and fall back
      for (var seed = 0; seed < 50; seed++) {
        final eng = SessionEngine(random: Random(seed));
        final dueCards = _makeDueCards(wordsNoMatch);
        final session = eng.build(
          dueCards: dueCards,
          newWords: [],
          allWords: wordsNoMatch,
          settings: SessionLength.intense,
          currentChapterId: 1,
        );
        final allQuestions = [
          ...session.phase1Review,
          ...session.phase3Mixed,
        ];
        // No cloze questions should appear
        expect(
          allQuestions.where((q) => q.mode == QuestionMode.cloze),
          isEmpty,
          reason: 'Seed $seed should not produce cloze questions',
        );
      }
    });
  });

  group('memory hints', () {
    test('include gender for nouns', () {
      final nouns = [
        _word('40', 'pain', 'bread',
            category: 'food', gender: 'm', partOfSpeech: 'noun'),
        _word('41', 'eau', 'water',
            category: 'food', gender: 'f', partOfSpeech: 'noun'),
        _word('42', 'lait', 'milk',
            category: 'food', gender: 'm', partOfSpeech: 'noun'),
        _word('43', 'sel', 'salt',
            category: 'food', gender: 'm', partOfSpeech: 'noun'),
      ];
      final dueCards = _makeDueCards(nouns);
      final session = engine.build(
        dueCards: dueCards,
        newWords: [],
        allWords: nouns,
        settings: SessionLength.casual,
        currentChapterId: 1,
      );

      for (final q in session.phase1Review) {
        expect(q.memoryHint, contains('Category: food'));
        expect(q.memoryHint, contains('Gender:'));
        if (q.word.gender == 'm') {
          expect(q.memoryHint, contains('Gender: le'));
        } else {
          expect(q.memoryHint, contains('Gender: la'));
        }
      }
    });

    test('include "Verb" label for verbs', () {
      final verbs = [
        _word('50', 'manger', 'to eat',
            category: 'action', partOfSpeech: 'verb'),
        _word('51', 'boire', 'to drink',
            category: 'action', partOfSpeech: 'verb'),
        _word('52', 'dormir', 'to sleep',
            category: 'action', partOfSpeech: 'verb'),
        _word('53', 'courir', 'to run',
            category: 'action', partOfSpeech: 'verb'),
      ];
      final dueCards = _makeDueCards(verbs);
      final session = engine.build(
        dueCards: dueCards,
        newWords: [],
        allWords: verbs,
        settings: SessionLength.casual,
        currentChapterId: 1,
      );

      for (final q in session.phase1Review) {
        expect(q.memoryHint, contains('Category: action'));
        expect(q.memoryHint, contains('Verb'));
      }
    });

    test('include related words from same category', () {
      final words = [
        _word('60', 'pain', 'bread',
            category: 'food', gender: 'm', partOfSpeech: 'noun'),
        _word('61', 'eau', 'water',
            category: 'food', gender: 'f', partOfSpeech: 'noun'),
        _word('62', 'lait', 'milk',
            category: 'food', gender: 'm', partOfSpeech: 'noun'),
        _word('63', 'sel', 'salt',
            category: 'food', gender: 'm', partOfSpeech: 'noun'),
      ];
      final dueCards = _makeDueCards([words.first]);
      final session = engine.build(
        dueCards: dueCards,
        newWords: [],
        allWords: words,
        settings: SessionLength.casual,
        currentChapterId: 1,
      );

      final q = session.phase1Review.first;
      expect(q.memoryHint, contains('Related:'));
    });
  });

  group('random question mode distribution', () {
    test('produces multiple question modes across many sessions', () {
      final words = [
        _word('70', 'pain', 'bread',
            category: 'food',
            gender: 'm',
            partOfSpeech: 'noun',
            exampleFr: 'Le pain est chaud.'),
        _word('71', 'eau', 'water',
            category: 'food',
            gender: 'f',
            partOfSpeech: 'noun',
            exampleFr: "L'eau est fraîche."),
        _word('72', 'lait', 'milk',
            category: 'food',
            gender: 'm',
            partOfSpeech: 'noun',
            exampleFr: 'Le lait est frais.'),
        _word('73', 'fromage', 'cheese',
            category: 'food',
            gender: 'm',
            partOfSpeech: 'noun',
            exampleFr: 'Le fromage est bon.'),
        _word('74', 'viande', 'meat',
            category: 'food',
            gender: 'f',
            partOfSpeech: 'noun',
            exampleFr: 'La viande est cuite.'),
      ];

      final modes = <QuestionMode>{};
      for (var seed = 0; seed < 100; seed++) {
        final eng = SessionEngine(random: Random(seed));
        final dueCards = _makeDueCards(words);
        final session = eng.build(
          dueCards: dueCards,
          newWords: [],
          allWords: words,
          settings: SessionLength.intense,
          currentChapterId: 1,
        );
        for (final q in [
          ...session.phase1Review,
          ...session.phase3Mixed,
        ]) {
          modes.add(q.mode);
        }
        if (modes.length == 3) break;
      }

      expect(modes, contains(QuestionMode.frenchToEnglish));
      expect(modes, contains(QuestionMode.englishToFrench));
      expect(modes, contains(QuestionMode.cloze));
    });
  });
}
