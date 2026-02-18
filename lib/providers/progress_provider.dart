import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final progressProvider = NotifierProvider<ProgressNotifier, UserProgress>(
  ProgressNotifier.new,
);

class ProgressNotifier extends Notifier<UserProgress> {
  static const _key = 'user_progress';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  UserProgress build() {
    final json = _prefs.getString(_key);
    if (json != null) {
      return UserProgress.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
    return UserProgress.initial();
  }

  Future<void> _save() async {
    await _prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> completeLesson(int chapterId) async {
    final existing = state.chapters[chapterId];
    final updated =
        (existing ??
                ChapterProgress(
                  chapterId: chapterId,
                  completionPercent: 0,
                  lessonsCompleted: 0,
                  quizBestScore: 0,
                  quizAttempts: 0,
                ))
            .copyWith(
              lessonsCompleted: (existing?.lessonsCompleted ?? 0) + 1,
              completionPercent: 100,
            );

    state = state.copyWith(
      chapters: {...state.chapters, chapterId: updated},
    );
    await _save();
  }

  Future<void> recordQuizScore(int chapterId, int score) async {
    final existing = state.chapters[chapterId];
    final updated =
        (existing ??
                ChapterProgress(
                  chapterId: chapterId,
                  completionPercent: 0,
                  lessonsCompleted: 0,
                  quizBestScore: 0,
                  quizAttempts: 0,
                ))
            .copyWith(
              quizBestScore: score > (existing?.quizBestScore ?? 0)
                  ? score
                  : existing?.quizBestScore ?? 0,
              quizAttempts: (existing?.quizAttempts ?? 0) + 1,
            );

    state = state.copyWith(
      chapters: {...state.chapters, chapterId: updated},
    );
    await _save();
  }

  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T').first;
    if (state.lastStudyDate == today) return;

    final yesterday =
        now.subtract(const Duration(days: 1)).toIso8601String().split('T').first;

    int newStreak;
    int newFreezes = state.streakFreezes;

    if (state.lastStudyDate == yesterday) {
      // Consecutive day
      newStreak = state.currentStreak + 1;
    } else if (state.lastStudyDate != null && newFreezes > 0) {
      // Missed a day but have a streak freeze — check 24h grace period
      final lastDate = DateTime.parse(state.lastStudyDate!);
      final hoursSince = now.difference(lastDate).inHours;
      if (hoursSince <= 48) {
        // Use a freeze to preserve streak
        newStreak = state.currentStreak;
        newFreezes -= 1;
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    // Earn a streak freeze every 7 consecutive days (max 2)
    String? newFreezeEarned = state.lastStreakFreezeEarned;
    if (newStreak > 0 && newStreak % 7 == 0 && newFreezes < 2) {
      final lastEarned = state.lastStreakFreezeEarned;
      if (lastEarned == null || lastEarned != today) {
        newFreezes += 1;
        newFreezeEarned = today;
      }
    }

    state = state.copyWith(
      currentStreak: newStreak,
      lastStudyDate: today,
      streakFreezes: newFreezes,
      lastStreakFreezeEarned: newFreezeEarned,
    );
    await _save();
  }

  Future<void> recordTefResult(TefTestResult result) async {
    state = state.copyWith(
      tefResults: [...state.tefResults, result],
    );
    await _save();
  }
}
