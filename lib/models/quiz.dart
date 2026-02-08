class QuizQuestion {
  final String id;
  final int chapterId;
  final String type; // 'multiple_choice', 'true_false', 'fill_blank', 'match'
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final String difficulty; // 'easy', 'medium', 'hard'

  const QuizQuestion({
    required this.id,
    required this.chapterId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.difficulty,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        chapterId: json['chapterId'] as int,
        type: json['type'] as String,
        question: json['question'] as String,
        options:
            (json['options'] as List<dynamic>).map((e) => e as String).toList(),
        correctAnswer: json['correctAnswer'] as String,
        explanation: json['explanation'] as String?,
        difficulty: json['difficulty'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapterId': chapterId,
        'type': type,
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        if (explanation != null) 'explanation': explanation,
        'difficulty': difficulty,
      };
}
