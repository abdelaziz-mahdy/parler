// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_progress_dao.dart';

// ignore_for_file: type=lint
mixin _$ChapterProgressDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChapterProgressesTable get chapterProgresses =>
      attachedDatabase.chapterProgresses;
  ChapterProgressDaoManager get managers => ChapterProgressDaoManager(this);
}

class ChapterProgressDaoManager {
  final _$ChapterProgressDaoMixin _db;
  ChapterProgressDaoManager(this._db);
  $$ChapterProgressesTableTableManager get chapterProgresses =>
      $$ChapterProgressesTableTableManager(
        _db.attachedDatabase,
        _db.chapterProgresses,
      );
}
