class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final int totalSections;
  final int completedSections;
  final String category;
  final List<LessonSection> sections;

  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.totalSections,
    this.completedSections = 0,
    required this.category,
    this.sections = const [],
  });

  double get progress =>
      totalSections > 0 ? completedSections / totalSections : 0;
  bool get isCompleted => completedSections >= totalSections;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      icon: json['icon'] as String? ?? '📖',
      totalSections: json['totalSections'] as int? ?? 1,
      completedSections: json['completedSections'] as int? ?? 0,
      category: json['category'] as String? ?? 'general',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => LessonSection.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LessonSection {
  final String id;
  final String title;
  final String content;
  final String type; // 'text', 'tip', 'table', 'example'
  final List<LessonExample>? examples;

  const LessonSection({
    required this.id,
    required this.title,
    required this.content,
    this.type = 'text',
    this.examples,
  });

  factory LessonSection.fromJson(Map<String, dynamic> json) {
    return LessonSection(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      examples: (json['examples'] as List<dynamic>?)
          ?.map((e) => LessonExample.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LessonExample {
  final String french;
  final String english;
  final String? pronunciation;

  const LessonExample({
    required this.french,
    required this.english,
    this.pronunciation,
  });

  factory LessonExample.fromJson(Map<String, dynamic> json) {
    return LessonExample(
      french: json['french'] as String,
      english: json['english'] as String,
      pronunciation: json['pronunciation'] as String?,
    );
  }
}
