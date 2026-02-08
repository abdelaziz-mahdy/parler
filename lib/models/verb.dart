class Verb {
  final String infinitive;
  final String meaning;
  final String group; // 'er', 'ir', 're', 'irregular'
  final Map<String, String>? presentTense; // subject -> conjugated form
  final String? pastParticiple;
  final String? auxiliaryVerb; // 'avoir' or 'etre'

  const Verb({
    required this.infinitive,
    required this.meaning,
    required this.group,
    this.presentTense,
    this.pastParticiple,
    this.auxiliaryVerb,
  });

  factory Verb.fromJson(Map<String, dynamic> json) => Verb(
        infinitive: json['infinitive'] as String,
        meaning: json['meaning'] as String,
        group: json['group'] as String,
        presentTense: (json['presentTense'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v as String)),
        pastParticiple: json['pastParticiple'] as String?,
        auxiliaryVerb: json['auxiliaryVerb'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'infinitive': infinitive,
        'meaning': meaning,
        'group': group,
        if (presentTense != null) 'presentTense': presentTense,
        if (pastParticiple != null) 'pastParticiple': pastParticiple,
        if (auxiliaryVerb != null) 'auxiliaryVerb': auxiliaryVerb,
      };
}

class VerbConjugationPattern {
  final String subject;
  final String ending;
  final String sound;

  const VerbConjugationPattern({
    required this.subject,
    required this.ending,
    required this.sound,
  });

  factory VerbConjugationPattern.fromJson(Map<String, dynamic> json) =>
      VerbConjugationPattern(
        subject: json['subject'] as String,
        ending: json['ending'] as String,
        sound: json['sound'] as String,
      );

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'ending': ending,
        'sound': sound,
      };
}

class VandertrampVerb {
  final String verb;
  final String meaning;
  final String pastParticiple;

  const VandertrampVerb({
    required this.verb,
    required this.meaning,
    required this.pastParticiple,
  });

  factory VandertrampVerb.fromJson(Map<String, dynamic> json) =>
      VandertrampVerb(
        verb: json['verb'] as String,
        meaning: json['meaning'] as String,
        pastParticiple: json['pastParticiple'] as String,
      );

  Map<String, dynamic> toJson() => {
        'verb': verb,
        'meaning': meaning,
        'pastParticiple': pastParticiple,
      };
}
