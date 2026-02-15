// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_log_dao.dart';

// ignore_for_file: type=lint
mixin _$ReviewLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardStatesTable get cardStates => attachedDatabase.cardStates;
  $ReviewLogsTable get reviewLogs => attachedDatabase.reviewLogs;
  ReviewLogDaoManager get managers => ReviewLogDaoManager(this);
}

class ReviewLogDaoManager {
  final _$ReviewLogDaoMixin _db;
  ReviewLogDaoManager(this._db);
  $$CardStatesTableTableManager get cardStates =>
      $$CardStatesTableTableManager(_db.attachedDatabase, _db.cardStates);
  $$ReviewLogsTableTableManager get reviewLogs =>
      $$ReviewLogsTableTableManager(_db.attachedDatabase, _db.reviewLogs);
}
