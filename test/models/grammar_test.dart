import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/grammar.dart';

void main() {
  group('QuestionWord', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'french': 'Pourquoi',
        'english': 'Why',
        'example': 'Pourquoi pas?',
        'pronunciation': 'poor-kwah',
      };

      final word = QuestionWord.fromJson(json);
      expect(word.french, 'Pourquoi');

      final restored = QuestionWord.fromJson(word.toJson());
      expect(restored.french, word.french);
      expect(restored.english, word.english);
      expect(restored.example, word.example);
      expect(restored.pronunciation, word.pronunciation);
    });
  });

  group('Article', () {
    test('fromJson with all fields', () {
      final json = {
        'type': 'definite',
        'masculine': 'le',
        'feminine': 'la',
        'plural': 'les',
        'beforeVowel': "l'",
      };

      final article = Article.fromJson(json);

      expect(article.type, 'definite');
      expect(article.masculine, 'le');
      expect(article.feminine, 'la');
      expect(article.plural, 'les');
      expect(article.beforeVowel, "l'");
    });

    test('fromJson without beforeVowel', () {
      final json = {
        'type': 'indefinite',
        'masculine': 'un',
        'feminine': 'une',
        'plural': 'des',
      };

      final article = Article.fromJson(json);
      expect(article.beforeVowel, isNull);
    });

    test('toJson omits null beforeVowel', () {
      const article = Article(
        type: 'indefinite',
        masculine: 'un',
        feminine: 'une',
        plural: 'des',
      );

      expect(article.toJson().containsKey('beforeVowel'), false);
    });
  });

  group('Contraction', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'combination': 'a + le',
        'contraction': 'au',
        'example': 'Je vais au marche',
        'notes': 'Required contraction',
      };

      final contraction = Contraction.fromJson(json);
      expect(contraction.combination, 'a + le');
      expect(contraction.contraction, 'au');

      final restored = Contraction.fromJson(contraction.toJson());
      expect(restored.combination, contraction.combination);
      expect(restored.contraction, contraction.contraction);
    });
  });
}
