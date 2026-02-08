class UserProgress {
  final Map<int, ChapterProgress> chapters;
  final Map<String, CardProgress> flashcards;
  final int totalXp;
  final int currentStreak;
  final String? lastStudyDate;

  const UserProgress({
    required this.chapters,
    required this.flashcards,
    required this.totalXp,
    required this.currentStreak,
    this.lastStudyDate,
  });

  factory UserProgress.initial() => const UserProgress(
        chapters: {},
        flashcards: {},
        totalXp: 0,
        currentStreak: 0,
      );

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final chaptersMap = <int, ChapterProgress>{};
    if (json['chapters'] != null) {
      (json['chapters'] as Map<String, dynamic>).forEach((key, value) {
        chaptersMap[int.parse(key)] =
            ChapterProgress.fromJson(value as Map<String, dynamic>);
      });
    }
    final flashcardsMap = <String, CardProgress>{};
    if (json['flashcards'] != null) {
      (json['flashcards'] as Map<String, dynamic>).forEach((key, value) {
        flashcardsMap[key] =
            CardProgress.fromJson(value as Map<String, dynamic>);
      });
    }
    return UserProgress(
      chapters: chaptersMap,
      flashcards: flashcardsMap,
      totalXp: json['totalXp'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastStudyDate: json['lastStudyDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'chapters':
            chapters.map((k, v) => MapEntry(k.toString(), v.toJson())),
        'flashcards': flashcards.map((k, v) => MapEntry(k, v.toJson())),
        'totalXp': totalXp,
        'currentStreak': currentStreak,
        if (lastStudyDate != null) 'lastStudyDate': lastStudyDate,
      };

  UserProgress copyWith({
    Map<int, ChapterProgress>? chapters,
    Map<String, CardProgress>? flashcards,
    int? totalXp,
    int? currentStreak,
    String? lastStudyDate,
  }) {
    return UserProgress(
      chapters: chapters ?? this.chapters,
      flashcards: flashcards ?? this.flashcards,
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }
}

class ChapterProgress {
  final int chapterId;
  final double completionPercent;
  final int lessonsCompleted;
  final int quizBestScore;
  final int quizAttempts;

  const ChapterProgress({
    required this.chapterId,
    required this.completionPercent,
    required this.lessonsCompleted,
    required this.quizBestScore,
    required this.quizAttempts,
  });

  factory ChapterProgress.fromJson(Map<String, dynamic> json) =>
      ChapterProgress(
        chapterId: json['chapterId'] as int,
        completionPercent: (json['completionPercent'] as num).toDouble(),
        lessonsCompleted: json['lessonsCompleted'] as int? ?? 0,
        quizBestScore: json['quizBestScore'] as int? ?? 0,
        quizAttempts: json['quizAttempts'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'chapterId': chapterId,
        'completionPercent': completionPercent,
        'lessonsCompleted': lessonsCompleted,
        'quizBestScore': quizBestScore,
        'quizAttempts': quizAttempts,
      };

  ChapterProgress copyWith({
    double? completionPercent,
    int? lessonsCompleted,
    int? quizBestScore,
    int? quizAttempts,
  }) {
    return ChapterProgress(
      chapterId: chapterId,
      completionPercent: completionPercent ?? this.completionPercent,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      quizBestScore: quizBestScore ?? this.quizBestScore,
      quizAttempts: quizAttempts ?? this.quizAttempts,
    );
  }
}

class CardProgress {
  final String cardId;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final String nextReviewDate;
  final int quality;

  const CardProgress({
    required this.cardId,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.nextReviewDate,
    required this.quality,
  });

  factory CardProgress.initial(String cardId) {
    return CardProgress(
      cardId: cardId,
      easeFactor: 2.5,
      interval: 0,
      repetitions: 0,
      nextReviewDate: DateTime.now().toIso8601String().split('T').first,
      quality: 0,
    );
  }

  factory CardProgress.fromJson(Map<String, dynamic> json) => CardProgress(
        cardId: json['cardId'] as String,
        easeFactor: (json['easeFactor'] as num).toDouble(),
        interval: json['interval'] as int,
        repetitions: json['repetitions'] as int,
        nextReviewDate: json['nextReviewDate'] as String,
        quality: json['quality'] as int,
      );

  Map<String, dynamic> toJson() => {
        'cardId': cardId,
        'easeFactor': easeFactor,
        'interval': interval,
        'repetitions': repetitions,
        'nextReviewDate': nextReviewDate,
        'quality': quality,
      };

  CardProgress copyWith({
    double? easeFactor,
    int? interval,
    int? repetitions,
    String? nextReviewDate,
    int? quality,
  }) {
    return CardProgress(
      cardId: cardId,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      quality: quality ?? this.quality,
    );
  }
}
