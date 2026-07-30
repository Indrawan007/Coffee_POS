import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/invoice_generator.dart';
import '../../domain/models/cart_item_model.dart';
import '../../domain/models/cart_state_model.dart';

class TransactionResult {
  const TransactionResult({
    required this.transaction,
    required this.items,
  });
  final TransactionsTableData transaction;
  final List<TransactionItemsTableData> items;
}

class TransactionDatasource {
  const TransactionDatasource(this._db);
  final AppDatabase _db;

  // ─── SAVE TRANSACTION ─────────────────────────
  Future<TransactionResult> saveTransaction({
    required CartStateModel cart,
    required int cashierId,
    required String cashierName,
    required String paymentMethod,
    required String? paymentLabel,
    required double amountPaid,
  }) async {
    return _db.transaction(() async {
      // Generate invoice number
      final invoiceNumber = await _generateInvoiceNumber();

      final now = DateTime.now().toIso8601String();

      // Insert transaction
      final trxId = await _db.into(_db.transactionsTable).insert(
        TransactionsTableCompanion.insert(
          invoiceNumber: invoiceNumber,
          cashierId: cashierId,
          cashierName: cashierName,
          subtotal: Value(cart.subtotal),
          discountType: Value(
            cart.discountType == DiscountType.percent
              ? 'percent'
              : 'nominal',
          ),
          discountValue: Value(cart.discountValue),
          discountAmount: Value(cart.discountAmount),
          taxPercent: Value(cart.taxPercent),
          taxAmount: Value(cart.taxAmount),
          servicePercent: Value(cart.servicePercent),
          serviceAmount: Value(cart.serviceAmount),
          total: Value(cart.total),
          paymentMethod: paymentMethod,
          paymentLabel: Value(paymentLabel),
          amountPaid: Value(amountPaid),
          changeAmount: Value(amountPaid - cart.total),
          createdAt: now,
        ),
      );

      // Insert transaction items
      final itemCompanions = cart.items.map((item) =>
        TransactionItemsTableCompanion.insert(
          transactionId: trxId,
          productId: Value(item.productId),
          productNameSnapshot: item.productName,
          variantNameSnapshot: Value(
            item.variantName.isNotEmpty ? item.variantName : null,
          ),
          addonNamesSnapshot: Value(
            item.addonNames.isNotEmpty
              ? item.addonNames.join(', ')
              : null,
          ),
          unitPrice: item.unitPrice + item.addonPrice,
          qty: Value(item.qty),
          note: Value(
            item.note.isNotEmpty ? item.note : null,
          ),
          total: item.totalPrice,
        ),
      ).toList();

      await _db.batch((b) {
        b.insertAll(_db.transactionItemsTable, itemCompanions);
      });

      // Fetch saved transaction
      final savedTrx = await (_db.select(_db.transactionsTable)
        ..where((t) => t.id.equals(trxId))
      ).getSingle();

      final savedItems = await (_db.select(_db.transactionItemsTable)
        ..where((i) => i.transactionId.equals(trxId))
      ).get();

      return TransactionResult(
        transaction: savedTrx,
        items: savedItems,
      );
    });
  }

  // ─── GET TRANSACTIONS ─────────────────────────
  Future<List<TransactionsTableData>> getByDate(DateTime date) {
    final dateStr = date.toIso8601String().substring(0, 10);
    return (_db.select(_db.transactionsTable)
      ..where((t) => t.createdAt.like('$dateStr%'))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
    ).get();
  }

  Future<List<TransactionsTableData>> getByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final startStr = start.toIso8601String().substring(0, 10);
    final endStr   = end.toIso8601String().substring(0, 10);
    return (_db.select(_db.transactionsTable)
      ..where((t) =>
        t.createdAt.isBiggerOrEqualValue('${startStr}T00:00:00') &
        t.createdAt.isSmallerOrEqualValue('${endStr}T23:59:59'),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
    ).get();
  }

  // ─── GET ITEMS ────────────────────────────────
  Future<List<TransactionItemsTableData>> getItemsByTransaction(
    int transactionId,
  ) {
    return (_db.select(_db.transactionItemsTable)
      ..where((i) => i.transactionId.equals(transactionId))
    ).get();
  }

  // ─── SUMMARY ──────────────────────────────────
  Future<Map<String, dynamic>> getSummary(DateTime date) async {
    final transactions = await getByDate(date);

    double totalRevenue = 0;
    double totalCash    = 0;
    double totalNonCash = 0;
    int    totalTrx     = transactions.length;

    for (final t in transactions) {
      totalRevenue += t.total;
      if (t.paymentMethod == 'cash') {
        totalCash += t.total;
      } else {
        totalNonCash += t.total;
      }
    }

    return {
      'total_revenue'  : totalRevenue,
      'total_cash'     : totalCash,
      'total_non_cash' : totalNonCash,
      'total_trx'      : totalTrx,
      'avg_trx'        : totalTrx > 0
        ? totalRevenue / totalTrx
        : 0,
    };
  }

  // ─── BEST SELLER ──────────────────────────────
  Future<List<Map<String, dynamic>>> getBestSeller(
    DateTime date, {
    int limit = 5,
  }) async {
    final transactions = await getByDate(date);
    if (transactions.isEmpty) return [];

    final trxIds = transactions.map((t) => t.id).toList();

    final items = await (_db.select(_db.transactionItemsTable)
      ..where((i) => i.transactionId.isIn(trxIds))
    ).get();

    // Group by product name
    final Map<String, Map<String, dynamic>> grouped = {};

    for (final item in items) {
      final name = item.productNameSnapshot;
      if (grouped.containsKey(name)) {
        grouped[name]!['qty']     += item.qty;
        grouped[name]!['revenue'] += item.total;
      } else {
        grouped[name] = {
          'name'   : name,
          'qty'    : item.qty,
          'revenue': item.total,
        };
      }
    }

    final sorted = grouped.values.toList()
      ..sort((a, b) =>
        (b['qty'] as int).compareTo(a['qty'] as int),
      );

    return sorted.take(limit).toList();
  }

  // ─── GENERATE INVOICE ─────────────────────────
  Future<String> _generateInvoiceNumber() async {
    final today   = DateTime.now().toIso8601String().substring(0, 10);
    final todayTrx = await (_db.select(_db.transactionsTable)
      ..where((t) => t.createdAt.like('$today%'))
    ).get();

    return InvoiceGenerator.generate(todayTrx.length + 1);
  }
}