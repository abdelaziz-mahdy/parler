import 'package:drift/drift.dart';
import 'tables.dart';
import 'daos/card_state_dao.dart';
import 'daos/review_log_dao.dart';
import 'daos/chapter_progress_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [CardStates, ReviewLogs, ChapterProgresses],
  daos: [CardStateDao, ReviewLogDao, ChapterProgressDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
