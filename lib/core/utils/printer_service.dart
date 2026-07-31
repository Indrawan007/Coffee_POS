import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../database/app_database.dart';
import 'currency_formatter.dart';
import 'date_formatter.dart';

// ─── MODELS ───────────────────────────────────────
class BluetoothDeviceModel {
  const BluetoothDeviceModel({
    required this.name,
    required this.address,
    this.device,
  });

  final String name;
  final String address;
  final BluetoothDevice? device;
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
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;

  PrinterStatus get status => _status;

  // ─── SCAN PAIRED DEVICES ──────────────────────
  Future<List<BluetoothDeviceModel>> scanDevices() async {
    try {
      // Cek bluetooth state
      final adapterState = await FlutterBluePlus
        .adapterState
        .first;

      if (adapterState != BluetoothAdapterState.on) {
        throw Exception(
          'Bluetooth tidak aktif. '
          'Aktifkan Bluetooth terlebih dahulu.',
        );
      }

      // Ambil paired/bonded devices
      final bonded = await FlutterBluePlus.bondedDevices;

      return bonded
        .map((d) => BluetoothDeviceModel(
          name: d.platformName.isNotEmpty
            ? d.platformName
            : 'Unknown Device',
          address: d.remoteId.toString(),
          device: d,
        ))
        .toList();
    } catch (e) {
      throw Exception('Gagal scan: $e');
    }
  }

  // ─── CONNECT ──────────────────────────────────
  Future<bool> connect(BluetoothDeviceModel deviceModel) async {
    try {
      await disconnect();

      final device = deviceModel.device ??
        BluetoothDevice(
          remoteId: DeviceIdentifier(deviceModel.address),
        );

      // Connect
      await device.connect(
        timeout: const Duration(seconds: 10),
        autoConnect: false,
      );

      // Discover services
      final services = await device.discoverServices();

      // Cari characteristic yang bisa write
      // Printer thermal biasanya pakai service tertentu
      BluetoothCharacteristic? writeChar;

      for (final service in services) {
        for (final char in service.characteristics) {
          if (char.properties.write ||
              char.properties.writeWithoutResponse) {
            writeChar = char;
            break;
          }
        }
        if (writeChar != null) break;
      }

      if (writeChar == null) {
        await device.disconnect();
        throw Exception(
          'Characteristic printer tidak ditemukan. '
          'Pastikan device adalah printer thermal.',
        );
      }

      _connectedDevice = device;
      _characteristic  = writeChar;
      _status = PrinterStatus(
        isConnected: true,
        deviceName: deviceModel.name,
        deviceAddress: deviceModel.address,
      );

      // Listen disconnect
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _status = PrinterStatus.disconnected;
          _connectedDevice = null;
          _characteristic  = null;
        }
      });

      return true;
    } catch (e) {
      _status = PrinterStatus.disconnected;
      _connectedDevice = null;
      _characteristic  = null;
      throw Exception('Gagal connect: $e');
    }
  }

  // ─── DISCONNECT ───────────────────────────────
  Future<void> disconnect() async {
    try {
      await _connectedDevice?.disconnect();
    } catch (_) {}
    _connectedDevice = null;
    _characteristic  = null;
    _status = PrinterStatus.disconnected;
  }

  // ─── CHECK CONNECTION ─────────────────────────
  Future<bool> isConnected() async {
    if (_connectedDevice == null) return false;
    final state = await _connectedDevice!
      .connectionState
      .first;
    return state == BluetoothConnectionState.connected;
  }

  // ─── WRITE BYTES ──────────────────────────────
  Future<void> _writeBytes(List<int> bytes) async {
    if (_characteristic == null) {
      throw Exception('Printer tidak terhubung.');
    }

    // Kirim dalam chunks karena BLE punya limit MTU
    const chunkSize = 512;
    for (var i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length)
        ? i + chunkSize
        : bytes.length;
      final chunk = bytes.sublist(i, end);

      await _characteristic!.write(
        chunk,
        withoutResponse:
          _characteristic!.properties.writeWithoutResponse,
      );

      // Delay kecil antar chunk
      await Future.delayed(
        const Duration(milliseconds: 20),
      );
    }
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

    await _writeBytes(bytes);
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
      'Printer OK! Siap digunakan.',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(3);
    bytes += generator.cut();

    await _writeBytes(bytes);
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

    bytes += generator.setGlobalCodeTable('CP1252');

    // ── HEADER ──────────────────────────────────
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

    // ── INFO ────────────────────────────────────
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
      final name =
        '${item.productNameSnapshot}'
        '${item.variantNameSnapshot != null
          ? ' (${item.variantNameSnapshot})'
          : ''
        }';

      bytes += generator.text(name);

      if (item.addonNamesSnapshot != null) {
        bytes += generator.text(
          '+ ${item.addonNamesSnapshot}',
          styles: const PosStyles(
            fontType: PosFontType.fontB,
          ),
        );
      }

      if (item.note != null) {
        bytes += generator.text(
          'Catatan: ${item.note}',
          styles: const PosStyles(
            fontType: PosFontType.fontB,
          ),
        );
      }

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
        PosColumn(text: 'Diskon', width: 7),
        PosColumn(
          text: '-${CurrencyFormatter.format(
            trx.discountAmount,
          )}',
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
          text: CurrencyFormatter.format(
            trx.serviceAmount,
          ),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

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
          text: CurrencyFormatter.format(
            trx.changeAmount,
          ),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

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