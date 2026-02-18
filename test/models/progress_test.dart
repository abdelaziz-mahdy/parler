import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/progress.dart';

void main() {
  group('UserProgress', () {
    test('initial factory creates empty progress', () {
      final progress = UserProgress.initial();

      expect(progress.chapters, isEmpty);
      expect(progress.currentStreak, 0);
      expect(progress.lastStudyDate, isNull);
      expect(progress.streakFreezes, 0);
      expect(progress.lastStreakFreezeEarned, isNull);
    });

    test('fromJson/toJson roundtrip', () {
      final json = {
        'chapters': {
          '1': {
            'chapterId': 1,
            'completionPercent': 75.0,
            'lessonsCompleted': 3,
            'quizBestScore': 80,
            'quizAttempts': 2,
          },
        },
        'currentStreak': 5,
        'lastStudyDate': '2026-02-08',
        'streakFreezes': 1,
        'lastStreakFreezeEarned': '2026-02-07',
      };

      final progress = UserProgress.fromJson(json);

      expect(progress.chapters.length, 1);
      expect(progress.chapters[1]!.chapterId, 1);
      expect(progress.chapters[1]!.completionPercent, 75.0);
      expect(progress.currentStreak, 5);
      expect(progress.lastStudyDate, '2026-02-08');
      expect(progress.streakFreezes, 1);

      final restoredJson = progress.toJson();
      final restored = UserProgress.fromJson(restoredJson);

      expect(restored.chapters.length, progress.chapters.length);
      expect(restored.currentStreak, progress.currentStreak);
      expect(restored.streakFreezes, progress.streakFreezes);
    });

    test('copyWith creates modified copy', () {
      final original = UserProgress.initial();
      final modified = original.copyWith(
        currentStreak: 3,
        streakFreezes: 2,
      );

      expect(modified.currentStreak, 3);
      expect(modified.streakFreezes, 2);
      expect(modified.chapters, isEmpty);
      expect(original.currentStreak, 0); // original unchanged
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'chapters': <String, dynamic>{},
        'currentStreak': 0,
      };

      final progress = UserProgress.fromJson(json);
      expect(progress.lastStudyDate, isNull);
      expect(progress.streakFreezes, 0);
      expect(progress.lastStreakFreezeEarned, isNull);
    });
  });

  group('ChapterProgress', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'chapterId': 3,
        'completionPercent': 50.5,
        'lessonsCompleted': 2,
        'quizBestScore': 90,
        'quizAttempts': 1,
      };

      final progress = ChapterProgress.fromJson(json);

      expect(progress.chapterId, 3);
      expect(progress.completionPercent, 50.5);
      expect(progress.lessonsCompleted, 2);
      expect(progress.quizBestScore, 90);
      expect(progress.quizAttempts, 1);

      final restored = ChapterProgress.fromJson(progress.toJson());
      expect(restored.chapterId, progress.chapterId);
      expect(restored.completionPercent, progress.completionPercent);
    });

    test('copyWith preserves chapterId', () {
      const progress = ChapterProgress(
        chapterId: 1,
        completionPercent: 0,
        lessonsCompleted: 0,
        quizBestScore: 0,
        quizAttempts: 0,
      );

      final updated = progress.copyWith(
        completionPercent: 100,
        lessonsCompleted: 5,
      );

      expect(updated.chapterId, 1);
      expect(updated.completionPercent, 100);
      expect(updated.lessonsCompleted, 5);
      expect(updated.quizBestScore, 0);
    });

    test('fromJson handles int completionPercent', () {
      final json = {
        'chapterId': 1,
        'completionPercent': 100,
        'lessonsCompleted': 5,
        'quizBestScore': 95,
        'quizAttempts': 3,
      };

      final progress = ChapterProgress.fromJson(json);
      expect(progress.completionPercent, 100.0);
    });
  });
}
