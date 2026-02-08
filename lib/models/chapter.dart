class Chapter {
  final int id;
  final String title;
  final String description;
  final String icon;
  final List<Section> sections;

  const Chapter({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.sections,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        sections: (json['sections'] as List<dynamic>)
            .map((e) => Section.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'sections': sections.map((e) => e.toJson()).toList(),
      };
}

class Section {
  final String id;
  final String title;
  final String content;
  final List<ContentBlock> blocks;
  final String? dataSource; // e.g. "pronunciation.json:vowelSounds"

  const Section({
    required this.id,
    required this.title,
    required this.content,
    required this.blocks,
    this.dataSource,
  });

  factory Section.fromJson(Map<String, dynamic> json) => Section(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        blocks: (json['blocks'] as List<dynamic>)
            .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
            .toList(),
        dataSource: json['dataSource'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'blocks': blocks.map((e) => e.toJson()).toList(),
        if (dataSource != null) 'dataSource': dataSource,
      };
}

class ContentBlock {
  final String type; // 'text', 'table', 'tip', 'example', 'rule'
  final String? title;
  final String? body;
  final List<Map<String, String>>? tableRows;
  final List<String>? tableHeaders;
  final List<String>? bulletPoints;

  const ContentBlock({
    required this.type,
    this.title,
    this.body,
    this.tableRows,
    this.tableHeaders,
    this.bulletPoints,
  });

  factory ContentBlock.fromJson(Map<String, dynamic> json) => ContentBlock(
        type: json['type'] as String,
        title: json['title'] as String?,
        body: json['body'] as String?,
        tableRows: (json['tableRows'] as List<dynamic>?)
            ?.map((e) => Map<String, String>.from(e as Map))
            .toList(),
        tableHeaders: (json['tableHeaders'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        bulletPoints: (json['bulletPoints'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        if (tableRows != null) 'tableRows': tableRows,
        if (tableHeaders != null) 'tableHeaders': tableHeaders,
        if (bulletPoints != null) 'bulletPoints': bulletPoints,
      };
}
