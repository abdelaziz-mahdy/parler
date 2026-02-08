class VowelSound {
  final String letters;
  final String sound;
  final List<String> examples;
  final String hint;

  const VowelSound({
    required this.letters,
    required this.sound,
    required this.examples,
    required this.hint,
  });

  factory VowelSound.fromJson(Map<String, dynamic> json) => VowelSound(
        letters: json['letters'] as String,
        sound: json['sound'] as String,
        examples: (json['examples'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        hint: json['hint'] as String,
      );

  Map<String, dynamic> toJson() => {
        'letters': letters,
        'sound': sound,
        'examples': examples,
        'hint': hint,
      };
}

class NasalVowel {
  final String spelling;
  final String sound;
  final List<String> examples;
  final String howToSay;

  const NasalVowel({
    required this.spelling,
    required this.sound,
    required this.examples,
    required this.howToSay,
  });

  factory NasalVowel.fromJson(Map<String, dynamic> json) => NasalVowel(
        spelling: json['spelling'] as String,
        sound: json['sound'] as String,
        examples: (json['examples'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        howToSay: json['howToSay'] as String,
      );

  Map<String, dynamic> toJson() => {
        'spelling': spelling,
        'sound': sound,
        'examples': examples,
        'howToSay': howToSay,
      };
}

class ConsonantRule {
  final String letter;
  final String rule;
  final List<String> examples;
  final String notes;

  const ConsonantRule({
    required this.letter,
    required this.rule,
    required this.examples,
    required this.notes,
  });

  factory ConsonantRule.fromJson(Map<String, dynamic> json) => ConsonantRule(
        letter: json['letter'] as String,
        rule: json['rule'] as String,
        examples: (json['examples'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        notes: json['notes'] as String,
      );

  Map<String, dynamic> toJson() => {
        'letter': letter,
        'rule': rule,
        'examples': examples,
        'notes': notes,
      };
}

class CarefulRule {
  final String letter;
  final List<String> examples;

  const CarefulRule({
    required this.letter,
    required this.examples,
  });

  factory CarefulRule.fromJson(Map<String, dynamic> json) => CarefulRule(
        letter: json['letter'] as String,
        examples: (json['examples'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'letter': letter,
        'examples': examples,
      };
}
