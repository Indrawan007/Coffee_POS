import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../database/app_database.dart';
import 'currency_formatter.dart';
import 'date_formatter.dart';

// ─── MODEL ────────────────────────────────────────
class BluetoothDevice {
  const BluetoothDevice({
    required this.name,
    required this.address,
  });
  final String name;
  final String address;
}

class PrinterStatus {
  const PrinterStatus({
    required this.isConnected,
    this.deviceName,
    this.deviceAddress,
  });
  final bool isConnected;
  final String? deviceName;
  final String? deviceAddress;

  static const disconnected = PrinterStatus(
    isConnected: false,
  );
}

// ─── PRINTER SERVICE ──────────────────────────────
class PrinterService {
  PrinterService._();
  static final PrinterService instance = PrinterService._();

  PrinterStatus _status = PrinterStatus.disconnected;
  PrinterStatus get status => _status;

  // ─── SCAN DEVICES ─────────────────────────────
  Future<List<BluetoothDevice>> scanDevices() async {
    try {
      final bool btEnabled =
        await PrintBluetoothThermal.bluetoothEnabled;

      if (!btEnabled) {
        throw Exception(
          'Bluetooth tidak aktif. '
          'Aktifkan Bluetooth terlebih dahulu.',
        );
      }

      final List<BluetoothInfo> devices =
        await PrintBluetoothThermal.pairedBluetooths;

      return devices
        .map((d) => BluetoothDevice(
          name: d.name,
          address: d.macAdress,
        ))
        .toList();
    } catch (e) {
      throw Exception('Gagal scan: $e');
    }
  }

  // ─── CONNECT ──────────────────────────────────
  Future<bool> connect(BluetoothDevice device) async {
    try {
      final bool connected =
        await PrintBluetoothThermal.connect(
          macPrinterAddress: device.address,
        );

      if (connected) {
        _status = PrinterStatus(
          isConnected: true,
          deviceName: device.name,
          deviceAddress: device.address,
        );
      }

      return connected;
    } catch (e) {
      _status = PrinterStatus.disconnected;
      return false;
    }
  }

  // ─── DISCONNECT ───────────────────────────────
  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
    _status = PrinterStatus.disconnected;
  }

  // ─── CHECK CONNECTION ─────────────────────────
  Future<bool> isConnected() async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  // ─── PRINT RECEIPT ────────────────────────────
  Future<void> printReceipt({
    required TransactionsTableData transaction,
    required List<TransactionItemsTableData> items,
    required SettingsTableData? settings,
    String paperSize = '58',
  }) async {
    final connected = await isConnected();
    if (!connected) {
      throw Exception(
        'Printer tidak terhubung. '
        'Hubungkan printer terlebih dahulu.',
      );
    }

    final bytes = await _generateReceiptBytes(
      transaction: transaction,
      items: items,
      settings: settings,
      paperSize: paperSize,
    );

    await PrintBluetoothThermal.writeBytes(bytes);
  }

  // ─── TEST PRINT ───────────────────────────────
  Future<void> testPrint({
    required SettingsTableData? settings,
    String paperSize = '58',
  }) async {
    final connected = await isConnected();
    if (!connected) {
      throw Exception('Printer tidak terhubung.');
    }

    final profile   = await CapabilityProfile.load();
    final paper     = paperSize == '80'
      ? PaperSize.mm80
      : PaperSize.mm58;
    final generator = Generator(paper, profile);

    List<int> bytes = [];

    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text(
      '=== TEST PRINT ===',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      settings?.storeName ?? 'Coffee POS',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      DateFormatter.toDisplayWithTime(DateTime.now()),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();
    bytes += generator.text(
      'Printer berfungsi dengan baik!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    await PrintBluetoothThermal.writeBytes(bytes);
  }

  // ─── GENERATE RECEIPT BYTES ───────────────────
  Future<List<int>> _generateReceiptBytes({
    required TransactionsTableData transaction,
    required List<TransactionItemsTableData> items,
    required SettingsTableData? settings,
    required String paperSize,
  }) async {
    final profile   = await CapabilityProfile.load();
    final paper     = paperSize == '80'
      ? PaperSize.mm80
      : PaperSize.mm58;
    final generator = Generator(paper, profile);
    final trx       = transaction;

    List<int> bytes = [];

    // ── HEADER ──────────────────────────────────
    bytes += generator.setGlobalCodeTable('CP1252');

    bytes += generator.text(
      settings?.storeName ?? 'Coffee Shop',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );

    if (settings?.storeAddress != null) {
      bytes += generator.text(
        settings!.storeAddress!,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (settings?.storePhone != null) {
      bytes += generator.text(
        'Telp: ${settings!.storePhone}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.hr();

    // ── INVOICE INFO ────────────────────────────
    bytes += generator.row([
      PosColumn(
        text: 'No',
        width: 3,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: ': ${trx.invoiceNumber}',
        width: 9,
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Kasir',
        width: 3,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: ': ${trx.cashierName}',
        width: 9,
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Tgl',
        width: 3,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: ': ${DateFormatter.toDisplayWithTime(
          DateTime.parse(trx.createdAt),
        )}',
        width: 9,
      ),
    ]);

    bytes += generator.hr();

    // ── ITEMS ───────────────────────────────────
    for (final item in items) {
      // Product name + variant
      final name =
        '${item.productNameSnapshot}'
        '${item.variantNameSnapshot != null
          ? ' (${item.variantNameSnapshot})'
          : ''
        }';

      bytes += generator.text(name);

      // Addon
      if (item.addonNamesSnapshot != null) {
        bytes += generator.text(
          '+ ${item.addonNamesSnapshot}',
          styles: const PosStyles(
            fontType: PosFontType.fontB,
          ),
        );
      }

      // Note
      if (item.note != null) {
        bytes += generator.text(
          'Catatan: ${item.note}',
          styles: const PosStyles(
            fontType: PosFontType.fontB,
          ),
        );
      }

      // Qty x Price = Total
      bytes += generator.row([
        PosColumn(
          text: '  ${item.qty}x '
            '${CurrencyFormatter.format(item.unitPrice)}',
          width: 8,
        ),
        PosColumn(
          text: CurrencyFormatter.format(item.total),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
          ),
        ),
      ]);
    }

    bytes += generator.hr();

    // ── SUMMARY ─────────────────────────────────
    bytes += generator.row([
      PosColumn(text: 'Subtotal', width: 7),
      PosColumn(
        text: CurrencyFormatter.format(trx.subtotal),
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (trx.discountAmount > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Diskon',
          width: 7,
        ),
        PosColumn(
          text: '-${CurrencyFormatter.format(trx.discountAmount)}',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if (trx.taxAmount > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Pajak (${trx.taxPercent.toInt()}%)',
          width: 7,
        ),
        PosColumn(
          text: CurrencyFormatter.format(trx.taxAmount),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if (trx.serviceAmount > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Service (${trx.servicePercent.toInt()}%)',
          width: 7,
        ),
        PosColumn(
          text: CurrencyFormatter.format(trx.serviceAmount),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // TOTAL
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: CurrencyFormatter.format(trx.total),
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
        ),
      ),
    ]);

    bytes += generator.hr();

    // Payment
    bytes += generator.row([
      PosColumn(
        text: trx.paymentLabel ?? trx.paymentMethod,
        width: 7,
      ),
      PosColumn(
        text: CurrencyFormatter.format(trx.amountPaid),
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (trx.changeAmount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Kembali', width: 7),
        PosColumn(
          text: CurrencyFormatter.format(trx.changeAmount),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // ── FOOTER ──────────────────────────────────
    bytes += generator.text(
      settings?.storeFooter ??
        'Terima kasih atas kunjungan Anda!',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }
}