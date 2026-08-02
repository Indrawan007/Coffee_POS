import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart' as xl;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/app_database.dart';
import 'currency_formatter.dart';

class ExportResult {
  const ExportResult({
    required this.filePath,
    required this.fileName,
    required this.success,
    this.error,
  });
  final String filePath;
  final String fileName;
  final bool success;
  final String? error;
}

class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  // ═══════════════════════════════════════════════
  // EXPORT PDF
  // ═══════════════════════════════════════════════
  Future<ExportResult> exportPdf({
    required DateTime date,
    required Map<String, dynamic> summary,
    required List<Map<String, dynamic>> bestSellers,
    required List<TransactionsTableData> transactions,
    required SettingsTableData? settings,
  }) async {
    try {
      final pdf = pw.Document();
      final dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(date);

      final totalRevenue = _toDouble(summary['total_revenue']);
      final totalTrx = _toInt(summary['total_trx']);
      final avgTrx = _toDouble(summary['avg_trx']);
      final totalCash = _toDouble(summary['total_cash']);
      final totalNonCash = _toDouble(summary['total_non_cash']);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            // ── HEADER ────────────────────────
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#4E342E'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    settings?.storeName ?? 'Coffee Shop',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (settings?.storeAddress != null)
                    pw.Text(
                      settings!.storeAddress!,
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // ── TITLE ─────────────────────────
            pw.Text(
              'Laporan Penjualan',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              dateStr,
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),

            pw.SizedBox(height: 20),

            // ── RINGKASAN ─────────────────────
            pw.Text(
              'Ringkasan',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            pw.Row(
              children: [
                _pdfSummaryBox(
                  'Total Omzet',
                  CurrencyFormatter.format(totalRevenue),
                ),
                pw.SizedBox(width: 8),
                _pdfSummaryBox(
                  'Transaksi',
                  '${totalTrx}x',
                ),
                pw.SizedBox(width: 8),
                _pdfSummaryBox(
                  'Rata-rata',
                  CurrencyFormatter.format(avgTrx),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ── METODE PEMBAYARAN ─────────────
            pw.Text(
              'Metode Pembayaran',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
              ),
              children: [
                _pdfTableHeader(['Metode', 'Jumlah']),
                _pdfTableRow([
                  'Cash',
                  CurrencyFormatter.format(totalCash),
                ]),
                _pdfTableRow([
                  'Non-Cash',
                  CurrencyFormatter.format(totalNonCash),
                ]),
                _pdfTableRow(
                  [
                    'TOTAL',
                    CurrencyFormatter.format(totalRevenue),
                  ],
                  bold: true,
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ── PRODUK TERLARIS ────────────────
            if (bestSellers.isNotEmpty) ...[
              pw.Text(
                'Produk Terlaris',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                ),
                children: [
                  _pdfTableHeader([
                    'No',
                    'Produk',
                    'Qty',
                    'Revenue',
                  ]),
                  ...bestSellers.asMap().entries.map((e) {
                    final i = e.key;
                    final item = e.value;
                    return _pdfTableRow([
                      '${i + 1}',
                      (item['name'] ?? '-').toString(),
                      '${_toInt(item['qty'])}',
                      CurrencyFormatter.format(
                        _toDouble(item['revenue']),
                      ),
                    ]);
                  }),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // ── DETAIL TRANSAKSI ──────────────
            pw.Text(
              'Detail Transaksi',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            if (transactions.isEmpty)
              pw.Text(
                'Tidak ada transaksi',
                style: const pw.TextStyle(
                  color: PdfColors.grey,
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  _pdfTableHeader([
                    'Invoice',
                    'Waktu',
                    'Metode',
                    'Total',
                  ]),
                  ...transactions.map((trx) {
                    final time = DateFormat('HH:mm')
                        .format(DateTime.parse(trx.createdAt));
                    return _pdfTableRow([
                      trx.invoiceNumber,
                      time,
                      trx.paymentLabel ?? trx.paymentMethod,
                      CurrencyFormatter.format(trx.total),
                    ]);
                  }),
                ],
              ),
          ],

          // ── FOOTER ──────────────────────────
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Text(
              'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())} '
              '| Halaman ${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey,
              ),
            ),
          ),
        ),
      );

      // Save file
      final dir = await _getExportDirectory();
      final fileName = 'Laporan_${DateFormat('yyyyMMdd').format(date)}.pdf';
      final filePath = p.join(dir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      debugPrint('PDF exported: $filePath');

      return ExportResult(
        filePath: filePath,
        fileName: fileName,
        success: true,
      );
    } catch (e) {
      return ExportResult(
        filePath: '',
        fileName: '',
        success: false,
        error: 'Gagal export PDF: $e',
      );
    }
  }

  // ═══════════════════════════════════════════════
  // EXPORT EXCEL
  // ═══════════════════════════════════════════════
  Future<ExportResult> exportExcel({
    required DateTime date,
    required Map<String, dynamic> summary,
    required List<Map<String, dynamic>> bestSellers,
    required List<TransactionsTableData> transactions,
    required SettingsTableData? settings,
  }) async {
    try {
      final excel = xl.Excel.createExcel();
      final dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(date);

      final totalRevenue = _toDouble(summary['total_revenue']);
      final totalTrx = _toInt(summary['total_trx']);
      final avgTrx = _toDouble(summary['avg_trx']);
      final totalCash = _toDouble(summary['total_cash']);
      final totalNonCash = _toDouble(summary['total_non_cash']);

      // ── SHEET: RINGKASAN ────────────────────
      final summarySheet = excel['Ringkasan'];

      // Header
      summarySheet.appendRow([
        xl.TextCellValue(
          settings?.storeName ?? 'Coffee Shop',
        ),
      ]);
      summarySheet.appendRow([
        xl.TextCellValue('Laporan Penjualan - $dateStr'),
      ]);
      summarySheet.appendRow([xl.TextCellValue('')]);

      // Summary
      summarySheet.appendRow([
        xl.TextCellValue('Keterangan'),
        xl.TextCellValue('Nilai'),
      ]);
      summarySheet.appendRow([
        xl.TextCellValue('Total Omzet'),
        xl.DoubleCellValue(totalRevenue),
      ]);
      summarySheet.appendRow([
        xl.TextCellValue('Jumlah Transaksi'),
        xl.IntCellValue(totalTrx),
      ]);
      summarySheet.appendRow([
        xl.TextCellValue('Rata-rata Transaksi'),
        xl.DoubleCellValue(avgTrx),
      ]);
      summarySheet.appendRow([xl.TextCellValue('')]);

      // Payment
      summarySheet.appendRow([
        xl.TextCellValue('Metode Pembayaran'),
        xl.TextCellValue('Jumlah'),
      ]);
      summarySheet.appendRow([
        xl.TextCellValue('Cash'),
        xl.DoubleCellValue(totalCash),
      ]);
      summarySheet.appendRow([
        xl.TextCellValue('Non-Cash'),
        xl.DoubleCellValue(totalNonCash),
      ]);

      // ── SHEET: PRODUK TERLARIS ──────────────
      final bestSheet = excel['Produk Terlaris'];

      bestSheet.appendRow([
        xl.TextCellValue('No'),
        xl.TextCellValue('Produk'),
        xl.TextCellValue('Qty'),
        xl.TextCellValue('Revenue'),
      ]);

      for (var i = 0; i < bestSellers.length; i++) {
        final item = bestSellers[i];
        bestSheet.appendRow([
          xl.IntCellValue(i + 1),
          xl.TextCellValue(
            (item['name'] ?? '-').toString(),
          ),
          xl.IntCellValue(_toInt(item['qty'])),
          xl.DoubleCellValue(_toDouble(item['revenue'])),
        ]);
      }

      // ── SHEET: TRANSAKSI ────────────────────
      final trxSheet = excel['Transaksi'];

      trxSheet.appendRow([
        xl.TextCellValue('Invoice'),
        xl.TextCellValue('Waktu'),
        xl.TextCellValue('Kasir'),
        xl.TextCellValue('Metode'),
        xl.TextCellValue('Subtotal'),
        xl.TextCellValue('Diskon'),
        xl.TextCellValue('Pajak'),
        xl.TextCellValue('Service'),
        xl.TextCellValue('Total'),
      ]);

      for (final trx in transactions) {
        final time = DateFormat('HH:mm').format(DateTime.parse(trx.createdAt));

        trxSheet.appendRow([
          xl.TextCellValue(trx.invoiceNumber),
          xl.TextCellValue(time),
          xl.TextCellValue(trx.cashierName),
          xl.TextCellValue(
            trx.paymentLabel ?? trx.paymentMethod,
          ),
          xl.DoubleCellValue(trx.subtotal),
          xl.DoubleCellValue(trx.discountAmount),
          xl.DoubleCellValue(trx.taxAmount),
          xl.DoubleCellValue(trx.serviceAmount),
          xl.DoubleCellValue(trx.total),
        ]);
      }

      // Hapus sheet default
      excel.delete('Sheet1');

      // Save
      final dir = await _getExportDirectory();
      final fileName = 'Laporan_${DateFormat('yyyyMMdd').format(date)}.xlsx';
      final filePath = p.join(dir.path, fileName);
      final bytes = excel.encode();

      if (bytes == null) {
        throw Exception('Gagal encode Excel');
      }

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      debugPrint('Excel exported: $filePath');

      return ExportResult(
        filePath: filePath,
        fileName: fileName,
        success: true,
      );
    } catch (e) {
      return ExportResult(
        filePath: '',
        fileName: '',
        success: false,
        error: 'Gagal export Excel: $e',
      );
    }
  }

  // ═══════════════════════════════════════════════
  // OPEN FILE
  // ═══════════════════════════════════════════════
  Future<void> openFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint('Open file error: $e');
    }
  }

  // ═══════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════
  Future<Directory> _getExportDirectory() async {
    Directory? dir;
    try {
      dir = await getExternalStorageDirectory();
    } catch (_) {}

    dir ??= await getApplicationDocumentsDirectory();

    final exportDir = Directory(
      p.join(dir.path, 'CoffeePOS_Reports'),
    );
    await exportDir.create(recursive: true);
    return exportDir;
  }

  // PDF helpers
  pw.Expanded _pdfSummaryBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.TableRow _pdfTableHeader(List<String> cells) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF4E342E),
      ),
      children: cells
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  c,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ))
          .toList(),
    );
  }

  pw.TableRow _pdfTableRow(
    List<String> cells, {
    bool bold = false,
  }) {
    return pw.TableRow(
      children: cells
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  c,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight:
                        bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  ),
                ),
              ))
          .toList(),
    );
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return 0.0;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return 0;
  }
}
