class SuffixPattern {
  final String englishEnding;
  final String frenchEnding;
  final List<String> examples;
  final String notes;

  const SuffixPattern({
    required this.englishEnding,
    required this.frenchEnding,
    required this.examples,
    required this.notes,
  });

  factory SuffixPattern.fromJson(Map<String, dynamic> json) => SuffixPattern(
        englishEnding: json['englishEnding'] as String,
        frenchEnding: json['frenchEnding'] as String,
        examples: (json['examples'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        notes: json['notes'] as String,
      );

  Map<String, dynamic> toJson() => {
        'englishEnding': englishEnding,
        'frenchEnding': frenchEnding,
        'examples': examples,
        'notes': notes,
      };
}
