class LiaisonRule {
  final String type; // 'mandatory', 'sound_change', 'elision'
  final String description;
  final List<LiaisonExample> examples;

  const LiaisonRule({
    required this.type,
    required this.description,
    required this.examples,
  });

  factory LiaisonRule.fromJson(Map<String, dynamic> json) => LiaisonRule(
        type: json['type'] as String,
        description: json['description'] as String,
        examples: (json['examples'] as List<dynamic>)
            .map((e) => LiaisonExample.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'description': description,
        'examples': examples.map((e) => e.toJson()).toList(),
      };
}

class LiaisonExample {
  final String written;
  final String pronunciation;
  final String? rule;

  const LiaisonExample({
    required this.written,
    required this.pronunciation,
    this.rule,
  });

  factory LiaisonExample.fromJson(Map<String, dynamic> json) =>
      LiaisonExample(
        written: json['written'] as String,
        pronunciation: json['pronunciation'] as String,
        rule: json['rule'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'written': written,
        'pronunciation': pronunciation,
        if (rule != null) 'rule': rule,
      };
}
