class UserProgress {
  final Map<int, ChapterProgress> chapters;
  final List<TefTestResult> tefResults;
  final int currentStreak;
  final String? lastStudyDate;
  final int streakFreezes;
  final String? lastStreakFreezeEarned;

  const UserProgress({
    required this.chapters,
    required this.tefResults,
    required this.currentStreak,
    this.lastStudyDate,
    this.streakFreezes = 0,
    this.lastStreakFreezeEarned,
  });

  factory UserProgress.initial() => const UserProgress(
    chapters: {},
    tefResults: [],
    currentStreak: 0,
  );

  /// Best result for a given test, or null if never taken.
  TefTestResult? bestTefResult(String testId) {
    final results = tefResults.where((r) => r.testId == testId);
    if (results.isEmpty) return null;
    return results.reduce((a, b) => a.percentage >= b.percentage ? a : b);
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final chaptersMap = <int, ChapterProgress>{};
    if (json['chapters'] != null) {
      (json['chapters'] as Map<String, dynamic>).forEach((key, value) {
        chaptersMap[int.parse(key)] = ChapterProgress.fromJson(
          value as Map<String, dynamic>,
        );
      });
    }
    final tefList = <TefTestResult>[];
    if (json['tefResults'] != null) {
      for (final item in json['tefResults'] as List) {
        tefList.add(TefTestResult.fromJson(item as Map<String, dynamic>));
      }
    }
    return UserProgress(
      chapters: chaptersMap,
      tefResults: tefList,
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastStudyDate: json['lastStudyDate'] as String?,
      streakFreezes: json['streakFreezes'] as int? ?? 0,
      lastStreakFreezeEarned: json['lastStreakFreezeEarned'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'chapters': chapters.map((k, v) => MapEntry(k.toString(), v.toJson())),
    'tefResults': tefResults.map((r) => r.toJson()).toList(),
    'currentStreak': currentStreak,
    if (lastStudyDate != null) 'lastStudyDate': lastStudyDate,
    'streakFreezes': streakFreezes,
    if (lastStreakFreezeEarned != null)
      'lastStreakFreezeEarned': lastStreakFreezeEarned,
  };

  UserProgress copyWith({
    Map<int, ChapterProgress>? chapters,
    List<TefTestResult>? tefResults,
    int? currentStreak,
    String? lastStudyDate,
    int? streakFreezes,
    String? lastStreakFreezeEarned,
  }) {
    return UserProgress(
      chapters: chapters ?? this.chapters,
      tefResults: tefResults ?? this.tefResults,
      currentStreak: currentStreak ?? this.currentStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      lastStreakFreezeEarned:
          lastStreakFreezeEarned ?? this.lastStreakFreezeEarned,
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

class TefTestResult {
  final String testId;
  final int score;
  final int totalQuestions;
  final int timeTakenSeconds;
  final String nclcLevel;
  final String completedAt;
  final Map<String, int> answers; // questionId -> selectedIndex

  const TefTestResult({
    required this.testId,
    required this.score,
    required this.totalQuestions,
    required this.timeTakenSeconds,
    required this.nclcLevel,
    required this.completedAt,
    required this.answers,
  });

  int get percentage =>
      totalQuestions > 0 ? ((score / totalQuestions) * 100).round() : 0;

  factory TefTestResult.fromJson(Map<String, dynamic> json) => TefTestResult(
    testId: json['testId'] as String,
    score: json['score'] as int,
    totalQuestions: json['totalQuestions'] as int,
    timeTakenSeconds: json['timeTakenSeconds'] as int,
    nclcLevel: json['nclcLevel'] as String,
    completedAt: json['completedAt'] as String,
    answers: (json['answers'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, v as int),
    ),
  );

  Map<String, dynamic> toJson() => {
    'testId': testId,
    'score': score,
    'totalQuestions': totalQuestions,
    'timeTakenSeconds': timeTakenSeconds,
    'nclcLevel': nclcLevel,
    'completedAt': completedAt,
    'answers': answers,
  };
}
