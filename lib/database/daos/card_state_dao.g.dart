// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_state_dao.dart';

// ignore_for_file: type=lint
mixin _$CardStateDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardStatesTable get cardStates => attachedDatabase.cardStates;
  CardStateDaoManager get managers => CardStateDaoManager(this);
}

class CardStateDaoManager {
  final _$CardStateDaoMixin _db;
  CardStateDaoManager(this._db);
  $$CardStatesTableTableManager get cardStates =>
      $$CardStatesTableTableManager(_db.attachedDatabase, _db.cardStates);
}
