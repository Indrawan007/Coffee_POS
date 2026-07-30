import 'package:drift/drift.dart';
import 'users_table.dart';

class TransactionsTable extends Table {
  @override
  String get tableName => 'transactions';

  IntColumn get id            => integer().autoIncrement()();
  TextColumn get invoiceNumber=> text().unique()();
  IntColumn get cashierId     => integer().references(UsersTable, #id)();
  TextColumn get cashierName  => text()();
  RealColumn get subtotal     => real().withDefault(const Constant(0))();
  TextColumn get discountType => text().withDefault(
    const Constant('nominal'),
  )();
  RealColumn get discountValue => real().withDefault(const Constant(0))();
  RealColumn get discountAmount=> real().withDefault(const Constant(0))();
  RealColumn get taxPercent   => real().withDefault(const Constant(0))();
  RealColumn get taxAmount    => real().withDefault(const Constant(0))();
  RealColumn get servicePercent=>real().withDefault(const Constant(0))();
  RealColumn get serviceAmount => real().withDefault(const Constant(0))();
  RealColumn get total        => real().withDefault(const Constant(0))();
  TextColumn get paymentMethod=> text()();
  TextColumn get paymentLabel => text().nullable()();
  RealColumn get amountPaid   => real().withDefault(const Constant(0))();
  RealColumn get changeAmount => real().withDefault(const Constant(0))();
  TextColumn get note         => text().nullable()();
  TextColumn get createdAt    => text()();
}
