import 'package:drift/drift.dart';

class AddonsTable extends Table {
  @override
  String get tableName => 'addons';

  IntColumn get id        => integer().autoIncrement()();
  TextColumn get name     => text()();
  RealColumn get price    => real().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt=> text()();
}