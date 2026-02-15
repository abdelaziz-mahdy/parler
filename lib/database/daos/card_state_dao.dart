import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'card_state_dao.g.dart';

@DriftAccessor(tables: [CardStates])
class CardStateDao extends DatabaseAccessor<AppDatabase>
    with _$CardStateDaoMixin {
  CardStateDao(super.db);

  Future<List<CardState>> allCards() => select(cardStates).get();

  Stream<List<CardState>> watchDueCards(DateTime now) {
    return (select(cardStates)
          ..where((t) =>
              t.nextReview.isSmallerOrEqualValue(now) |
              t.state.equals('new')))
        .watch();
  }

  Future<CardState?> getCard(String id) {
    return (select(cardStates)..where((t) => t.cardId.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertCard(CardStatesCompanion card) {
    return into(cardStates).insertOnConflictUpdate(card);
  }

  Future<void> upsertAll(List<CardStatesCompanion> cards) async {
    await batch((b) {
      for (final card in cards) {
        b.insert(cardStates, card, onConflict: DoUpdate((_) => card));
      }
    });
  }

  Stream<int> watchMasteredCount() {
    final query = selectOnly(cardStates)
      ..addColumns([cardStates.cardId.count()])
      ..where(cardStates.stability.isBiggerThanValue(30));
    return query
        .map((row) => row.read(cardStates.cardId.count()) ?? 0)
        .watchSingle();
  }

  Stream<int> watchTotalStudied() {
    final query = selectOnly(cardStates)
      ..addColumns([cardStates.cardId.count()])
      ..where(cardStates.state.isNotIn(['new']));
    return query
        .map((row) => row.read(cardStates.cardId.count()) ?? 0)
        .watchSingle();
  }
}
