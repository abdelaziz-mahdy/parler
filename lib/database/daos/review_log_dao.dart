import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'review_log_dao.g.dart';

@DriftAccessor(tables: [ReviewLogs])
class ReviewLogDao extends DatabaseAccessor<AppDatabase>
    with _$ReviewLogDaoMixin {
  ReviewLogDao(super.db);

  Future<void> insert(ReviewLogsCompanion log) {
    return into(reviewLogs).insert(log);
  }

  Future<List<ReviewLog>> allLogs() => select(reviewLogs).get();

  Future<int> totalReviewCount() async {
    final count = reviewLogs.id.count();
    final query = selectOnly(reviewLogs)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
