import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/pronunciation_rule.dart';

void main() {
  group('VowelSound', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'letters': 'ou',
        'sound': 'oo',
        'examples': ['vous', 'tout'],
        'hint': 'Like "oo" in "food"',
      };

      final vowel = VowelSound.fromJson(json);
      expect(vowel.letters, 'ou');
      expect(vowel.sound, 'oo');
      expect(vowel.examples, ['vous', 'tout']);
      expect(vowel.hint, 'Like "oo" in "food"');

      final restored = VowelSound.fromJson(vowel.toJson());
      expect(restored.letters, vowel.letters);
      expect(restored.sound, vowel.sound);
      expect(restored.examples, vowel.examples);
      expect(restored.hint, vowel.hint);
    });
  });

  group('NasalVowel', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'spelling': 'an/am/en/em',
        'sound': 'nasal ah',
        'examples': ['dans', 'temps'],
        'howToSay': 'Say "ah" through your nose',
      };

      final nasal = NasalVowel.fromJson(json);
      expect(nasal.spelling, 'an/am/en/em');
      expect(nasal.howToSay, 'Say "ah" through your nose');

      final restored = NasalVowel.fromJson(nasal.toJson());
      expect(restored.spelling, nasal.spelling);
      expect(restored.examples, nasal.examples);
    });
  });

  group('ConsonantRule', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'letter': 'r',
        'rule': 'French R is guttural',
        'examples': ['rouge', 'rue'],
        'notes': 'Produced in the back of the throat',
      };

      final rule = ConsonantRule.fromJson(json);
      expect(rule.letter, 'r');
      expect(rule.rule, 'French R is guttural');

      final restored = ConsonantRule.fromJson(rule.toJson());
      expect(restored.letter, rule.letter);
      expect(restored.notes, rule.notes);
    });
  });

  group('CarefulRule', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'letter': 'h',
        'examples': ['heure', 'homme'],
      };

      final rule = CarefulRule.fromJson(json);
      expect(rule.letter, 'h');
      expect(rule.examples, ['heure', 'homme']);

      final restored = CarefulRule.fromJson(rule.toJson());
      expect(restored.letter, rule.letter);
      expect(restored.examples, rule.examples);
    });
  });
}
