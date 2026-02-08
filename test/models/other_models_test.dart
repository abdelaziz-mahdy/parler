import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/false_friend.dart';
import 'package:french/models/liaison_rule.dart';
import 'package:french/models/number_item.dart';
import 'package:french/models/phrase.dart';
import 'package:french/models/lesson.dart';

void main() {
  group('FalseFriend', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'frenchWord': 'bras',
        'looksLike': 'bra',
        'actualMeaning': 'arm',
        'dangerLevel': 'FUNNY',
        'correctEnglish': 'arm',
      };

      final ff = FalseFriend.fromJson(json);
      expect(ff.frenchWord, 'bras');
      expect(ff.dangerLevel, 'FUNNY');

      final restored = FalseFriend.fromJson(ff.toJson());
      expect(restored.frenchWord, ff.frenchWord);
      expect(restored.looksLike, ff.looksLike);
      expect(restored.actualMeaning, ff.actualMeaning);
      expect(restored.correctEnglish, ff.correctEnglish);
    });
  });

  group('LiaisonRule', () {
    test('fromJson with nested examples', () {
      final json = {
        'type': 'mandatory',
        'description': 'Article + noun',
        'examples': [
          {
            'written': 'les amis',
            'pronunciation': 'lez-ah-mee',
            'rule': 's sounds like z',
          },
          {
            'written': 'un ami',
            'pronunciation': 'uhn-ah-mee',
          },
        ],
      };

      final rule = LiaisonRule.fromJson(json);

      expect(rule.type, 'mandatory');
      expect(rule.examples.length, 2);
      expect(rule.examples[0].rule, 's sounds like z');
      expect(rule.examples[1].rule, isNull);
    });

    test('toJson/fromJson roundtrip', () {
      const rule = LiaisonRule(
        type: 'elision',
        description: "Replace vowel with apostrophe",
        examples: [
          LiaisonExample(
            written: "l'homme",
            pronunciation: 'lom',
          ),
        ],
      );

      final restored = LiaisonRule.fromJson(rule.toJson());
      expect(restored.type, rule.type);
      expect(restored.examples.length, 1);
      expect(restored.examples[0].written, "l'homme");
    });
  });

  group('NumberItem', () {
    test('fromJson with formula', () {
      final json = {
        'value': 70,
        'french': 'soixante-dix',
        'formula': '60 + 10',
      };

      final item = NumberItem.fromJson(json);
      expect(item.value, 70);
      expect(item.french, 'soixante-dix');
      expect(item.formula, '60 + 10');
    });

    test('fromJson without formula', () {
      final json = {
        'value': 5,
        'french': 'cinq',
      };

      final item = NumberItem.fromJson(json);
      expect(item.formula, isNull);
    });

    test('toJson omits null formula', () {
      const item = NumberItem(value: 1, french: 'un');
      expect(item.toJson().containsKey('formula'), false);
    });
  });

  group('Phrase', () {
    test('fromJson with usage', () {
      final json = {
        'french': 'Bonjour',
        'english': 'Hello',
        'category': 'basics',
        'usage': 'Formal greeting during daytime',
      };

      final phrase = Phrase.fromJson(json);
      expect(phrase.french, 'Bonjour');
      expect(phrase.usage, 'Formal greeting during daytime');
    });

    test('fromJson without usage', () {
      final json = {
        'french': 'Merci',
        'english': 'Thank you',
        'category': 'basics',
      };

      final phrase = Phrase.fromJson(json);
      expect(phrase.usage, isNull);
    });

    test('toJson/fromJson roundtrip', () {
      const phrase = Phrase(
        french: "S'il vous plait",
        english: 'Please',
        category: 'basics',
        usage: 'Formal',
      );

      final restored = Phrase.fromJson(phrase.toJson());
      expect(restored.french, phrase.french);
      expect(restored.english, phrase.english);
      expect(restored.category, phrase.category);
      expect(restored.usage, phrase.usage);
    });
  });

  group('Lesson', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'lesson-1',
        'title': 'Greetings',
        'subtitle': 'Learn to say hello',
        'icon': 'wave',
        'totalSections': 3,
        'completedSections': 1,
        'category': 'basics',
        'sections': [
          {
            'id': 'sec1',
            'title': 'Formal greetings',
            'content': 'In French...',
            'type': 'text',
            'examples': [
              {
                'french': 'Bonjour',
                'english': 'Hello',
                'pronunciation': 'bohn-zhoor',
              }
            ],
          }
        ],
      };

      final lesson = Lesson.fromJson(json);

      expect(lesson.id, 'lesson-1');
      expect(lesson.title, 'Greetings');
      expect(lesson.totalSections, 3);
      expect(lesson.completedSections, 1);
      expect(lesson.sections.length, 1);
      expect(lesson.sections.first.examples!.length, 1);
      expect(lesson.sections.first.examples!.first.french, 'Bonjour');
    });

    test('progress calculation', () {
      final lesson = Lesson.fromJson({
        'id': 'l1',
        'title': 'Test',
        'subtitle': '',
        'icon': '',
        'totalSections': 4,
        'completedSections': 2,
        'category': 'test',
      });

      expect(lesson.progress, 0.5);
      expect(lesson.isCompleted, false);
    });

    test('progress is 0 when totalSections is 0', () {
      final lesson = Lesson.fromJson({
        'id': 'l2',
        'title': 'Empty',
        'subtitle': '',
        'icon': '',
        'totalSections': 0,
        'category': 'test',
      });

      expect(lesson.progress, 0);
    });

    test('isCompleted when all sections done', () {
      final lesson = Lesson.fromJson({
        'id': 'l3',
        'title': 'Done',
        'subtitle': '',
        'icon': '',
        'totalSections': 3,
        'completedSections': 3,
        'category': 'test',
      });

      expect(lesson.isCompleted, true);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'l4',
        'title': 'Minimal',
      };

      final lesson = Lesson.fromJson(json);

      expect(lesson.subtitle, '');
      expect(lesson.totalSections, 1);
      expect(lesson.completedSections, 0);
      expect(lesson.sections, isEmpty);
    });
  });
}
