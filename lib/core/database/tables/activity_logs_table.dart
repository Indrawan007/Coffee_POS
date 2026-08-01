import 'package:drift/drift.dart';

class ActivityLogsTable extends Table {
  @override
  String get tableName => 'activity_logs';

  IntColumn  get id        => integer().autoIncrement()();
  TextColumn get action    => text()();
  TextColumn get detail    => text().nullable()();
  IntColumn  get userId    => integer().nullable()();
  TextColumn get userName  => text().nullable()();
  TextColumn get createdAt => text()();
}