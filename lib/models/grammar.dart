class QuestionWord {
  final String french;
  final String english;
  final String example;
  final String pronunciation;

  const QuestionWord({
    required this.french,
    required this.english,
    required this.example,
    required this.pronunciation,
  });

  factory QuestionWord.fromJson(Map<String, dynamic> json) => QuestionWord(
        french: json['french'] as String,
        english: json['english'] as String,
        example: json['example'] as String,
        pronunciation: json['pronunciation'] as String,
      );

  Map<String, dynamic> toJson() => {
        'french': french,
        'english': english,
        'example': example,
        'pronunciation': pronunciation,
      };
}

class Article {
  final String type; // 'definite', 'indefinite'
  final String masculine;
  final String feminine;
  final String plural;
  final String? beforeVowel;

  const Article({
    required this.type,
    required this.masculine,
    required this.feminine,
    required this.plural,
    this.beforeVowel,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        type: json['type'] as String,
        masculine: json['masculine'] as String,
        feminine: json['feminine'] as String,
        plural: json['plural'] as String,
        beforeVowel: json['beforeVowel'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'masculine': masculine,
        'feminine': feminine,
        'plural': plural,
        if (beforeVowel != null) 'beforeVowel': beforeVowel,
      };
}

class Contraction {
  final String combination;
  final String contraction;
  final String example;
  final String notes;

  const Contraction({
    required this.combination,
    required this.contraction,
    required this.example,
    required this.notes,
  });

  factory Contraction.fromJson(Map<String, dynamic> json) => Contraction(
        combination: json['combination'] as String,
        contraction: json['contraction'] as String,
        example: json['example'] as String,
        notes: json['notes'] as String,
      );

  Map<String, dynamic> toJson() => {
        'combination': combination,
        'contraction': contraction,
        'example': example,
        'notes': notes,
      };
}
