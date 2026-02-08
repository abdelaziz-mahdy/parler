class GenderRule {
  final String ending;
  final String gender; // 'masculine' or 'feminine'
  final List<String> examples;
  final String accuracy;
  final String? exceptions;

  const GenderRule({
    required this.ending,
    required this.gender,
    required this.examples,
    required this.accuracy,
    this.exceptions,
  });

  factory GenderRule.fromJson(Map<String, dynamic> json) => GenderRule(
        ending: json['ending'] as String,
        gender: json['gender'] as String,
        examples: (json['examples'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        accuracy: json['accuracy'] as String,
        exceptions: json['exceptions'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'ending': ending,
        'gender': gender,
        'examples': examples,
        'accuracy': accuracy,
        if (exceptions != null) 'exceptions': exceptions,
      };
}
