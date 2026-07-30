import 'package:drift/drift.dart';
import 'transactions_table.dart';

class TransactionItemsTable extends Table {
  @override
  String get tableName => 'transaction_items';

  IntColumn get id                   => integer().autoIncrement()();
  IntColumn get transactionId        => integer().references(
    TransactionsTable, #id,
  )();
  IntColumn get productId            => integer().nullable()();
  TextColumn get productNameSnapshot => text()();
  TextColumn get variantNameSnapshot => text().nullable()();
  TextColumn get addonNamesSnapshot  => text().nullable()();
  RealColumn get unitPrice           => real()();
  IntColumn get qty                  => integer().withDefault(
    const Constant(1),
  )();
  TextColumn get note                => text().nullable()();
  RealColumn get total               => real()();
}