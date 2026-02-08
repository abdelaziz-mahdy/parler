import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/chapter.dart';

void main() {
  group('Chapter', () {
    test('fromJson creates correct instance', () {
      final json = {
        'id': 1,
        'title': 'Introduction',
        'description': 'Learn the basics',
        'icon': 'book',
        'sections': [
          {
            'id': 's1',
            'title': 'Section 1',
            'content': 'Hello world',
            'blocks': [
              {
                'type': 'text',
                'body': 'Some text',
              }
            ],
          }
        ],
      };

      final chapter = Chapter.fromJson(json);

      expect(chapter.id, 1);
      expect(chapter.title, 'Introduction');
      expect(chapter.description, 'Learn the basics');
      expect(chapter.icon, 'book');
      expect(chapter.sections.length, 1);
      expect(chapter.sections.first.id, 's1');
    });

    test('toJson/fromJson roundtrip preserves data', () {
      const chapter = Chapter(
        id: 2,
        title: 'Pronunciation',
        description: 'Master French sounds',
        icon: 'mic',
        sections: [
          Section(
            id: 'sec1',
            title: 'Vowels',
            content: 'French vowels overview',
            blocks: [
              ContentBlock(type: 'text', body: 'Vowel sounds'),
              ContentBlock(
                type: 'table',
                title: 'Vowel Chart',
                tableHeaders: ['Letter', 'Sound'],
                tableRows: [
                  {'Letter': 'a', 'Sound': 'ah'},
                ],
              ),
            ],
          ),
        ],
      );

      final json = chapter.toJson();
      final restored = Chapter.fromJson(json);

      expect(restored.id, chapter.id);
      expect(restored.title, chapter.title);
      expect(restored.description, chapter.description);
      expect(restored.icon, chapter.icon);
      expect(restored.sections.length, chapter.sections.length);
      expect(restored.sections.first.blocks.length, 2);
    });
  });

  group('Section', () {
    test('fromJson creates correct instance', () {
      final json = {
        'id': 'test-section',
        'title': 'Test',
        'content': 'Content here',
        'blocks': <Map<String, dynamic>>[],
      };

      final section = Section.fromJson(json);

      expect(section.id, 'test-section');
      expect(section.title, 'Test');
      expect(section.content, 'Content here');
      expect(section.blocks, isEmpty);
    });
  });

  group('ContentBlock', () {
    test('fromJson with all fields', () {
      final json = {
        'type': 'table',
        'title': 'My Table',
        'body': 'Table description',
        'tableHeaders': ['Col1', 'Col2'],
        'tableRows': [
          {'Col1': 'A', 'Col2': 'B'},
        ],
        'bulletPoints': ['Point 1', 'Point 2'],
      };

      final block = ContentBlock.fromJson(json);

      expect(block.type, 'table');
      expect(block.title, 'My Table');
      expect(block.body, 'Table description');
      expect(block.tableHeaders, ['Col1', 'Col2']);
      expect(block.tableRows!.length, 1);
      expect(block.bulletPoints, ['Point 1', 'Point 2']);
    });

    test('fromJson with minimal fields', () {
      final json = {'type': 'text'};

      final block = ContentBlock.fromJson(json);

      expect(block.type, 'text');
      expect(block.title, isNull);
      expect(block.body, isNull);
      expect(block.tableRows, isNull);
      expect(block.tableHeaders, isNull);
      expect(block.bulletPoints, isNull);
    });

    test('toJson omits null fields', () {
      const block = ContentBlock(type: 'tip', title: 'A tip');
      final json = block.toJson();

      expect(json.containsKey('type'), true);
      expect(json.containsKey('title'), true);
      expect(json.containsKey('body'), false);
      expect(json.containsKey('tableRows'), false);
    });
  });
}
