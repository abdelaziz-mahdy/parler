import 'package:drift/drift.dart';

/// FSRS card state for each vocabulary word
class CardStates extends Table {
  TextColumn get cardId => text()();
  RealColumn get stability => real().withDefault(const Constant(0))();
  RealColumn get difficulty => real().withDefault(const Constant(5.0))();
  DateTimeColumn get lastReview => dateTime().nullable()();
  DateTimeColumn get nextReview => dateTime().nullable()();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  TextColumn get state => text().withDefault(const Constant('new'))();

  @override
  Set<Column> get primaryKey => {cardId};
}

/// Append-only review log for FSRS parameter optimization
class ReviewLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardId => text().references(CardStates, #cardId)();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get rating => integer()(); // 1 (Again) or 3 (Good)
  RealColumn get elapsedDays => real()();
  IntColumn get responseTimeMs => integer().nullable()();
  RealColumn get stability => real()();
  RealColumn get difficulty => real()();
}

/// Chapter progress tracking
class ChapterProgresses extends Table {
  TextColumn get chapterId => text()();
  TextColumn get sectionsCompleted =>
      text().withDefault(const Constant('[]'))();
  RealColumn get masteryPercent => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {chapterId};
}
