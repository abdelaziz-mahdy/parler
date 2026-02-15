import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/daos/card_state_dao.dart';
import '../database/daos/review_log_dao.dart';
import '../database/daos/chapter_progress_dao.dart';
import '../services/fsrs.dart';

/// Database singleton — must be overridden in main.dart
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

/// DAOs
final cardStateDaoProvider = Provider<CardStateDao>((ref) {
  return ref.watch(appDatabaseProvider).cardStateDao;
});

final reviewLogDaoProvider = Provider<ReviewLogDao>((ref) {
  return ref.watch(appDatabaseProvider).reviewLogDao;
});

final chapterProgressDaoProvider = Provider<ChapterProgressDao>((ref) {
  return ref.watch(appDatabaseProvider).chapterProgressDao;
});

/// FSRS algorithm instance
final fsrsProvider = Provider<Fsrs>((ref) => const Fsrs());

/// Stream: cards due for review right now
final dueCardsProvider = StreamProvider<List<CardState>>((ref) {
  return ref.watch(cardStateDaoProvider).watchDueCards(DateTime.now());
});

/// Stream: count of mastered words (stability > 30 days)
final masteredCountProvider = StreamProvider<int>((ref) {
  return ref.watch(cardStateDaoProvider).watchMasteredCount();
});

/// Stream: total studied cards
final totalStudiedProvider = StreamProvider<int>((ref) {
  return ref.watch(cardStateDaoProvider).watchTotalStudied();
});

/// Stream: chapter progress
final chapterProgressStreamProvider =
    StreamProvider<List<ChapterProgressesData>>((ref) {
  return ref.watch(chapterProgressDaoProvider).watchAll();
});
