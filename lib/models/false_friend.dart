class FalseFriend {
  final String frenchWord;
  final String looksLike;
  final String actualMeaning;
  final String dangerLevel; // 'LOW', 'MEDIUM', 'HIGH', 'VERY HIGH', 'FUNNY'
  final String correctEnglish;

  const FalseFriend({
    required this.frenchWord,
    required this.looksLike,
    required this.actualMeaning,
    required this.dangerLevel,
    required this.correctEnglish,
  });

  factory FalseFriend.fromJson(Map<String, dynamic> json) => FalseFriend(
        frenchWord: json['frenchWord'] as String,
        looksLike: json['looksLike'] as String,
        actualMeaning: json['actualMeaning'] as String,
        dangerLevel: json['dangerLevel'] as String,
        correctEnglish: json['correctEnglish'] as String,
      );

  Map<String, dynamic> toJson() => {
        'frenchWord': frenchWord,
        'looksLike': looksLike,
        'actualMeaning': actualMeaning,
        'dangerLevel': dangerLevel,
        'correctEnglish': correctEnglish,
      };
}
