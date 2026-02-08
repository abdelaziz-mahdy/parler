import 'package:flutter_test/flutter_test.dart';
import 'package:french/models/progress.dart';

void main() {
  group('UserProgress', () {
    test('initial factory creates empty progress', () {
      final progress = UserProgress.initial();

      expect(progress.chapters, isEmpty);
      expect(progress.flashcards, isEmpty);
      expect(progress.totalXp, 0);
      expect(progress.currentStreak, 0);
      expect(progress.lastStudyDate, isNull);
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
        'flashcards': {
          'card1': {
            'cardId': 'card1',
            'easeFactor': 2.5,
            'interval': 3,
            'repetitions': 2,
            'nextReviewDate': '2026-02-10',
            'quality': 4,
          },
        },
        'totalXp': 150,
        'currentStreak': 5,
        'lastStudyDate': '2026-02-08',
      };

      final progress = UserProgress.fromJson(json);

      expect(progress.chapters.length, 1);
      expect(progress.chapters[1]!.chapterId, 1);
      expect(progress.chapters[1]!.completionPercent, 75.0);
      expect(progress.flashcards.length, 1);
      expect(progress.flashcards['card1']!.easeFactor, 2.5);
      expect(progress.totalXp, 150);
      expect(progress.currentStreak, 5);
      expect(progress.lastStudyDate, '2026-02-08');

      final restoredJson = progress.toJson();
      final restored = UserProgress.fromJson(restoredJson);

      expect(restored.chapters.length, progress.chapters.length);
      expect(restored.totalXp, progress.totalXp);
      expect(restored.currentStreak, progress.currentStreak);
    });

    test('copyWith creates modified copy', () {
      final original = UserProgress.initial();
      final modified = original.copyWith(totalXp: 100, currentStreak: 3);

      expect(modified.totalXp, 100);
      expect(modified.currentStreak, 3);
      expect(modified.chapters, isEmpty);
      expect(original.totalXp, 0); // original unchanged
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'chapters': <String, dynamic>{},
        'flashcards': <String, dynamic>{},
        'totalXp': 0,
        'currentStreak': 0,
      };

      final progress = UserProgress.fromJson(json);
      expect(progress.lastStudyDate, isNull);
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

  group('CardProgress', () {
    test('initial factory creates default SM-2 values', () {
      final card = CardProgress.initial('test-card');

      expect(card.cardId, 'test-card');
      expect(card.easeFactor, 2.5);
      expect(card.interval, 0);
      expect(card.repetitions, 0);
      expect(card.quality, 0);
    });

    test('fromJson/toJson roundtrip', () {
      final json = {
        'cardId': 'vocab-1',
        'easeFactor': 2.3,
        'interval': 6,
        'repetitions': 3,
        'nextReviewDate': '2026-02-14',
        'quality': 4,
      };

      final card = CardProgress.fromJson(json);

      expect(card.cardId, 'vocab-1');
      expect(card.easeFactor, 2.3);
      expect(card.interval, 6);
      expect(card.repetitions, 3);
      expect(card.nextReviewDate, '2026-02-14');
      expect(card.quality, 4);

      final restored = CardProgress.fromJson(card.toJson());
      expect(restored.cardId, card.cardId);
      expect(restored.easeFactor, card.easeFactor);
      expect(restored.interval, card.interval);
    });

    test('copyWith preserves cardId', () {
      final card = CardProgress.initial('card-x');
      final updated = card.copyWith(
        easeFactor: 2.1,
        interval: 10,
        repetitions: 5,
        quality: 3,
      );

      expect(updated.cardId, 'card-x');
      expect(updated.easeFactor, 2.1);
      expect(updated.interval, 10);
    });

    test('fromJson handles int easeFactor', () {
      final json = {
        'cardId': 'c1',
        'easeFactor': 3,
        'interval': 1,
        'repetitions': 1,
        'nextReviewDate': '2026-02-09',
        'quality': 5,
      };

      final card = CardProgress.fromJson(json);
      expect(card.easeFactor, 3.0);
    });
  });
}
