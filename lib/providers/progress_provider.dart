import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final progressProvider =
    NotifierProvider<ProgressNotifier, UserProgress>(ProgressNotifier.new);

class ProgressNotifier extends Notifier<UserProgress> {
  static const _key = 'user_progress';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  UserProgress build() {
    final json = _prefs.getString(_key);
    if (json != null) {
      return UserProgress.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    }
    return UserProgress.initial();
  }

  Future<void> _save() async {
    await _prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> completeLesson(int chapterId) async {
    final existing = state.chapters[chapterId];
    final updated = (existing ??
            ChapterProgress(
              chapterId: chapterId,
              completionPercent: 0,
              lessonsCompleted: 0,
              quizBestScore: 0,
              quizAttempts: 0,
            ))
        .copyWith(
      lessonsCompleted: (existing?.lessonsCompleted ?? 0) + 1,
    );

    state = state.copyWith(
      chapters: {...state.chapters, chapterId: updated},
      totalXp: state.totalXp + 10,
    );
    await _save();
  }

  Future<void> recordQuizScore(int chapterId, int score) async {
    final existing = state.chapters[chapterId];
    final updated = (existing ??
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
      totalXp: state.totalXp + score,
    );
    await _save();
  }

  Future<void> updateStreak() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    if (state.lastStudyDate == today) return;

    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')
        .first;

    final newStreak =
        state.lastStudyDate == yesterday ? state.currentStreak + 1 : 1;

    state = state.copyWith(
      currentStreak: newStreak,
      lastStudyDate: today,
    );
    await _save();
  }

  Future<void> updateCardProgress(CardProgress card) async {
    state = state.copyWith(
      flashcards: {...state.flashcards, card.cardId: card},
    );
    await _save();
  }
}
