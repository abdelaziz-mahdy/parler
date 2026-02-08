import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/gender_rule.dart';

void main() {
  group('GenderRule', () {
    test('fromJson with all fields', () {
      final json = {
        'ending': '-tion',
        'gender': 'feminine',
        'examples': ['nation', 'education'],
        'accuracy': '99%',
        'exceptions': 'bastion',
      };

      final rule = GenderRule.fromJson(json);

      expect(rule.ending, '-tion');
      expect(rule.gender, 'feminine');
      expect(rule.examples, ['nation', 'education']);
      expect(rule.accuracy, '99%');
      expect(rule.exceptions, 'bastion');
    });

    test('fromJson without exceptions', () {
      final json = {
        'ending': '-age',
        'gender': 'masculine',
        'examples': ['garage', 'voyage'],
        'accuracy': '95%',
      };

      final rule = GenderRule.fromJson(json);

      expect(rule.exceptions, isNull);
    });

    test('toJson omits null exceptions', () {
      const rule = GenderRule(
        ending: '-ment',
        gender: 'masculine',
        examples: ['moment'],
        accuracy: '90%',
      );

      final json = rule.toJson();

      expect(json.containsKey('exceptions'), false);
    });

    test('toJson/fromJson roundtrip', () {
      const rule = GenderRule(
        ending: '-eur',
        gender: 'masculine',
        examples: ['docteur', 'professeur'],
        accuracy: '85%',
        exceptions: 'fleur, couleur',
      );

      final restored = GenderRule.fromJson(rule.toJson());

      expect(restored.ending, rule.ending);
      expect(restored.gender, rule.gender);
      expect(restored.examples, rule.examples);
      expect(restored.accuracy, rule.accuracy);
      expect(restored.exceptions, rule.exceptions);
    });
  });
}
