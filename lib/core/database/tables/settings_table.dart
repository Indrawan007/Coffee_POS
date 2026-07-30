import 'package:drift/drift.dart';

class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  IntColumn get id             => integer().autoIncrement()();
  TextColumn get storeName     => text().withDefault(
    const Constant('Coffee Shop'),
  )();
  TextColumn get storeAddress  => text().nullable()();
  TextColumn get storePhone    => text().nullable()();
  TextColumn get storeFooter   => text().withDefault(
    const Constant('Terima kasih atas kunjungan Anda'),
  )();
  RealColumn get taxPercent    => real().withDefault(const Constant(0))();
  RealColumn get servicePercent=> real().withDefault(const Constant(0))();
  TextColumn get currencySymbol=> text().withDefault(const Constant('Rp'))();
  TextColumn get logoPath      => text().nullable()();
  TextColumn get updatedAt     => text()();
}