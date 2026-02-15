import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import '../app_database.dart';

AppDatabase constructDb() {
  final db = LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'parler',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
  return AppDatabase(db);
}
