class VocabularyWord {
  final String id;
  final String french;
  final String english;
  final String partOfSpeech; // 'noun', 'verb', 'adjective', 'adverb', 'preposition', 'conjunction', 'pronoun', 'expression'
  final String? gender; // 'm', 'f', or null (for non-nouns)
  final String exampleFr;
  final String exampleEn;
  final String level; // 'A1', 'A2', 'B1', 'B2'
  final String category;
  final String phonetic;

  const VocabularyWord({
    required this.id,
    required this.french,
    required this.english,
    required this.partOfSpeech,
    this.gender,
    required this.exampleFr,
    required this.exampleEn,
    required this.level,
    required this.category,
    required this.phonetic,
  });

  /// Display-friendly article prefix for nouns based on gender.
  String get article {
    if (partOfSpeech != 'noun' || gender == null) return '';
    // Check if word starts with vowel or silent h for elision
    final lower = french.toLowerCase();
    final needsElision = lower.startsWith('a') ||
        lower.startsWith('e') ||
        lower.startsWith('i') ||
        lower.startsWith('o') ||
        lower.startsWith('u') ||
        lower.startsWith('h');
    if (needsElision) return "l'";
    return gender == 'm' ? 'le ' : 'la ';
  }

  /// French word with article prefix for nouns (e.g., "le pain", "l'eau").
  String get frenchWithArticle {
    final art = article;
    if (art.isEmpty) return french;
    return '$art$french';
  }

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    // Generate id from french word if not present in data
    final french = json['french'] as String;
    final id = json['id'] as String? ??
        'vocab_${french.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), '_')}';
    return VocabularyWord(
      id: id,
      french: french,
      english: json['english'] as String,
      partOfSpeech: json['partOfSpeech'] as String,
      gender: json['gender'] as String?,
      exampleFr: json['exampleFr'] as String,
      exampleEn: json['exampleEn'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      phonetic: json['phonetic'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'french': french,
        'english': english,
        'partOfSpeech': partOfSpeech,
        if (gender != null) 'gender': gender,
        'exampleFr': exampleFr,
        'exampleEn': exampleEn,
        'level': level,
        'category': category,
        'phonetic': phonetic,
      };
}
