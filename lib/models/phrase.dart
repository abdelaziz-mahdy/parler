class Phrase {
  final String french;
  final String english;
  final String category; // 'basics', 'communication', 'daily_life', 'tef_fillers', 'tef_opinions', 'tef_recovery'
  final String? usage;

  const Phrase({
    required this.french,
    required this.english,
    required this.category,
    this.usage,
  });

  factory Phrase.fromJson(Map<String, dynamic> json) => Phrase(
        french: json['french'] as String,
        english: json['english'] as String,
        category: json['category'] as String,
        usage: json['usage'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'french': french,
        'english': english,
        'category': category,
        if (usage != null) 'usage': usage,
      };
}
