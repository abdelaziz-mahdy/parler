class TefTest {
  final String id;
  final String title;
  final String description;
  final String section; // 'comprehension_ecrite', 'comprehension_orale', 'expression_ecrite', 'expression_orale'
  final String difficulty; // 'A1', 'A2', 'B1', 'B2'
  final int timeMinutes;
  final List<TefPassage> passages;

  const TefTest({
    required this.id,
    required this.title,
    required this.description,
    required this.section,
    required this.difficulty,
    required this.timeMinutes,
    required this.passages,
  });

  int get totalQuestions =>
      passages.fold(0, (sum, p) => sum + p.questions.length);

  factory TefTest.fromJson(Map<String, dynamic> json) => TefTest(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        section: json['section'] as String,
        difficulty: json['difficulty'] as String,
        timeMinutes: json['timeMinutes'] as int,
        passages: (json['passages'] as List)
            .map((e) => TefPassage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'section': section,
        'difficulty': difficulty,
        'timeMinutes': timeMinutes,
        'passages': passages.map((p) => p.toJson()).toList(),
      };
}

class TefPassage {
  final String id;
  final String type; // 'text', 'email', 'advertisement', 'article', 'notice', 'letter', 'form'
  final String title;
  final String content;
  final String? contentEnglish;
  final String? source;
  final List<TefQuestion> questions;

  const TefPassage({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.contentEnglish,
    this.source,
    required this.questions,
  });

  factory TefPassage.fromJson(Map<String, dynamic> json) => TefPassage(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        contentEnglish: json['contentEnglish'] as String?,
        source: json['source'] as String?,
        questions: (json['questions'] as List)
            .map((e) => TefQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'content': content,
        if (contentEnglish != null) 'contentEnglish': contentEnglish,
        if (source != null) 'source': source,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}

class TefQuestion {
  final String id;
  final String question;
  final String? questionEnglish;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const TefQuestion({
    required this.id,
    required this.question,
    this.questionEnglish,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory TefQuestion.fromJson(Map<String, dynamic> json) => TefQuestion(
        id: json['id'] as String,
        question: json['question'] as String,
        questionEnglish: json['questionEnglish'] as String?,
        options: (json['options'] as List).map((e) => e as String).toList(),
        correctIndex: json['correctIndex'] as int,
        explanation: json['explanation'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        if (questionEnglish != null) 'questionEnglish': questionEnglish,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}
