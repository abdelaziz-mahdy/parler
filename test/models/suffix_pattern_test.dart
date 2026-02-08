import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/suffix_pattern.dart';

void main() {
  group('SuffixPattern', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'englishEnding': '-tion',
        'frenchEnding': '-tion',
        'examples': ['nation -> nation', 'education -> education'],
        'notes': 'Same spelling, different pronunciation',
      };

      final pattern = SuffixPattern.fromJson(json);

      expect(pattern.englishEnding, '-tion');
      expect(pattern.frenchEnding, '-tion');
      expect(pattern.examples.length, 2);
      expect(pattern.notes, 'Same spelling, different pronunciation');

      final restored = SuffixPattern.fromJson(pattern.toJson());
      expect(restored.englishEnding, pattern.englishEnding);
      expect(restored.frenchEnding, pattern.frenchEnding);
      expect(restored.examples, pattern.examples);
      expect(restored.notes, pattern.notes);
    });
  });
}
