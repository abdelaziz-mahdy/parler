import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/quiz.dart';

void main() {
  group('QuizQuestion', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'q1',
        'chapterId': 1,
        'type': 'multiple_choice',
        'question': 'What does "bonjour" mean?',
        'options': ['Hello', 'Goodbye', 'Thank you', 'Please'],
        'correctAnswer': 'Hello',
        'explanation': 'Bonjour is a greeting used during the day',
        'difficulty': 'easy',
      };

      final question = QuizQuestion.fromJson(json);

      expect(question.id, 'q1');
      expect(question.chapterId, 1);
      expect(question.type, 'multiple_choice');
      expect(question.question, 'What does "bonjour" mean?');
      expect(question.options, ['Hello', 'Goodbye', 'Thank you', 'Please']);
      expect(question.correctAnswer, 'Hello');
      expect(question.explanation,
          'Bonjour is a greeting used during the day');
      expect(question.difficulty, 'easy');
    });

    test('fromJson without explanation', () {
      final json = {
        'id': 'q2',
        'chapterId': 2,
        'type': 'true_false',
        'question': '"Chat" means cat',
        'options': ['True', 'False'],
        'correctAnswer': 'True',
        'difficulty': 'easy',
      };

      final question = QuizQuestion.fromJson(json);
      expect(question.explanation, isNull);
    });

    test('toJson omits null explanation', () {
      const question = QuizQuestion(
        id: 'q3',
        chapterId: 3,
        type: 'fill_blank',
        question: 'Je ___ francais',
        options: ['parle', 'parles', 'parlons'],
        correctAnswer: 'parle',
        difficulty: 'medium',
      );

      final json = question.toJson();
      expect(json.containsKey('explanation'), false);
    });

    test('toJson/fromJson roundtrip', () {
      const question = QuizQuestion(
        id: 'q4',
        chapterId: 1,
        type: 'multiple_choice',
        question: 'Choose the correct article',
        options: ['le', 'la', 'les'],
        correctAnswer: 'la',
        explanation: 'Maison is feminine',
        difficulty: 'hard',
      );

      final restored = QuizQuestion.fromJson(question.toJson());

      expect(restored.id, question.id);
      expect(restored.chapterId, question.chapterId);
      expect(restored.type, question.type);
      expect(restored.options, question.options);
      expect(restored.correctAnswer, question.correctAnswer);
      expect(restored.explanation, question.explanation);
      expect(restored.difficulty, question.difficulty);
    });
  });
}
