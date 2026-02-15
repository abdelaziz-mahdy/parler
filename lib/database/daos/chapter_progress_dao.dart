import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'chapter_progress_dao.g.dart';

@DriftAccessor(tables: [ChapterProgresses])
class ChapterProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ChapterProgressDaoMixin {
  ChapterProgressDao(super.db);

  Stream<List<ChapterProgressesData>> watchAll() =>
      select(chapterProgresses).watch();

  Future<ChapterProgressesData?> getChapter(String id) {
    return (select(chapterProgresses)
          ..where((t) => t.chapterId.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsert(ChapterProgressesCompanion entry) {
    return into(chapterProgresses).insertOnConflictUpdate(entry);
  }
}
