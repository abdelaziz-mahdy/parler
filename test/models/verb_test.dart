import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/verb.dart';

void main() {
  group('Verb', () {
    test('fromJson with all fields', () {
      final json = {
        'infinitive': 'parler',
        'meaning': 'to speak',
        'group': 'er',
        'presentTense': {
          'je': 'parle',
          'tu': 'parles',
          'il': 'parle',
          'nous': 'parlons',
          'vous': 'parlez',
          'ils': 'parlent',
        },
        'pastParticiple': 'parle',
        'auxiliaryVerb': 'avoir',
      };

      final verb = Verb.fromJson(json);

      expect(verb.infinitive, 'parler');
      expect(verb.meaning, 'to speak');
      expect(verb.group, 'er');
      expect(verb.presentTense!['je'], 'parle');
      expect(verb.presentTense!['nous'], 'parlons');
      expect(verb.pastParticiple, 'parle');
      expect(verb.auxiliaryVerb, 'avoir');
    });

    test('fromJson with minimal fields', () {
      final json = {
        'infinitive': 'aller',
        'meaning': 'to go',
        'group': 'irregular',
      };

      final verb = Verb.fromJson(json);

      expect(verb.presentTense, isNull);
      expect(verb.pastParticiple, isNull);
      expect(verb.auxiliaryVerb, isNull);
    });

    test('toJson omits null fields', () {
      const verb = Verb(
        infinitive: 'manger',
        meaning: 'to eat',
        group: 'er',
      );

      final json = verb.toJson();

      expect(json.containsKey('presentTense'), false);
      expect(json.containsKey('pastParticiple'), false);
      expect(json.containsKey('auxiliaryVerb'), false);
    });

    test('toJson/fromJson roundtrip', () {
      const verb = Verb(
        infinitive: 'finir',
        meaning: 'to finish',
        group: 'ir',
        presentTense: {'je': 'finis', 'tu': 'finis'},
        pastParticiple: 'fini',
        auxiliaryVerb: 'avoir',
      );

      final restored = Verb.fromJson(verb.toJson());

      expect(restored.infinitive, verb.infinitive);
      expect(restored.presentTense, verb.presentTense);
      expect(restored.pastParticiple, verb.pastParticiple);
    });
  });

  group('VerbConjugationPattern', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'subject': 'je',
        'ending': '-e',
        'sound': 'silent',
      };

      final pattern = VerbConjugationPattern.fromJson(json);
      expect(pattern.subject, 'je');

      final restored = VerbConjugationPattern.fromJson(pattern.toJson());
      expect(restored.subject, pattern.subject);
      expect(restored.ending, pattern.ending);
      expect(restored.sound, pattern.sound);
    });
  });

  group('VandertrampVerb', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'verb': 'aller',
        'meaning': 'to go',
        'pastParticiple': 'alle',
      };

      final verb = VandertrampVerb.fromJson(json);
      expect(verb.verb, 'aller');

      final restored = VandertrampVerb.fromJson(verb.toJson());
      expect(restored.verb, verb.verb);
      expect(restored.meaning, verb.meaning);
      expect(restored.pastParticiple, verb.pastParticiple);
    });
  });
}
