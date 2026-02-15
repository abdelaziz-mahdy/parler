import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/vocabulary_word.dart';
import 'package:french/services/fsrs.dart';
import 'package:french/services/session_engine.dart';

VocabularyWord _word(String id, String french, String english) =>
    VocabularyWord(
      id: id,
      french: french,
      english: english,
      partOfSpeech: 'noun',
      exampleFr: '',
      exampleEn: '',
      level: 'A1',
      category: 'test',
      phonetic: '',
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
    final dueCards = allWords
        .take(5)
        .map((w) => MapEntry(
              FsrsCardState(
                cardId: w.id,
                stability: 5,
                lastReview:
                    DateTime.now().subtract(const Duration(days: 5)),
                nextReview: DateTime.now(),
                state: FsrsState.review,
              ),
              w,
            ))
        .toList();
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
    final dueCards = allWords
        .take(3)
        .map((w) => MapEntry(
              FsrsCardState(
                cardId: w.id,
                stability: 5,
                lastReview:
                    DateTime.now().subtract(const Duration(days: 5)),
                nextReview: DateTime.now(),
                state: FsrsState.review,
              ),
              w,
            ))
        .toList();

    final session = engine.build(
      dueCards: dueCards,
      newWords: [],
      allWords: allWords,
      settings: SessionLength.casual,
      currentChapterId: 1,
    );
    for (final q in session.phase1Review) {
      expect(q.options.length, 4);
      expect(q.options[q.correctIndex], q.word.english);
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
    final dueCards = allWords
        .take(2)
        .map((w) => MapEntry(
              FsrsCardState(
                cardId: w.id,
                stability: 5,
                lastReview:
                    DateTime.now().subtract(const Duration(days: 5)),
                nextReview: DateTime.now(),
                state: FsrsState.review,
              ),
              w,
            ))
        .toList();

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
}
