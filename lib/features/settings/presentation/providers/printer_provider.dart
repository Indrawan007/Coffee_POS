import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/printer_service.dart';

part 'printer_provider.g.dart';

// ─── PRINTER STATE ────────────────────────────────
class PrinterState {
  const PrinterState({
    this.devices = const [],
    this.isScanning = false,
    this.isConnecting = false,
    this.isPrinting = false,
    this.status = PrinterStatus.disconnected,
    this.errorMessage,
    this.successMessage,
  });

  final List<BluetoothDevice> devices;
  final bool isScanning;
  final bool isConnecting;
  final bool isPrinting;
  final PrinterStatus status;
  final String? errorMessage;
  final String? successMessage;

  bool get isConnected => status.isConnected;

  PrinterState copyWith({
    List<BluetoothDevice>? devices,
    bool? isScanning,
    bool? isConnecting,
    bool? isPrinting,
    PrinterStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return PrinterState(
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      isPrinting: isPrinting ?? this.isPrinting,
      status: status ?? this.status,
      errorMessage: clearError
        ? null
        : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
        ? null
        : successMessage ?? this.successMessage,
    );
  }
}

// ─── PRINTER NOTIFIER ─────────────────────────────
@riverpod
class PrinterNotifier extends _$PrinterNotifier {

  @override
  PrinterState build() {
    // Cek status awal
    Future.microtask(_checkStatus);
    return const PrinterState();
  }

  Future<void> _checkStatus() async {
    final connected = await PrinterService.instance.isConnected();
    state = state.copyWith(
      status: connected
        ? PrinterService.instance.status
        : PrinterStatus.disconnected,
    );
  }

  // ─── SCAN ───────────────────────────────────
  Future<void> scan() async {
    state = state.copyWith(
      isScanning: true,
      clearError: true,
    );

    try {
      final devices = await PrinterService.instance.scanDevices();
      state = state.copyWith(
        isScanning: false,
        devices: devices,
      );
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ─── CONNECT ────────────────────────────────
  Future<void> connect(BluetoothDevice device) async {
    state = state.copyWith(
      isConnecting: true,
      clearError: true,
    );

    try {
      final success = await PrinterService.instance
        .connect(device);

      if (success) {
        state = state.copyWith(
          isConnecting: false,
          status: PrinterService.instance.status,
          successMessage:
            'Terhubung ke ${device.name}',
        );
      } else {
        state = state.copyWith(
          isConnecting: false,
          errorMessage: 'Gagal terhubung ke ${device.name}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        errorMessage: 'Error: $e',
      );
    }
  }

  // ─── DISCONNECT ─────────────────────────────
  Future<void> disconnect() async {
    await PrinterService.instance.disconnect();
    state = state.copyWith(
      status: PrinterStatus.disconnected,
      successMessage: 'Printer diputus',
    );
  }

  // ─── TEST PRINT ─────────────────────────────
  Future<void> testPrint({
    required SettingsTableData? settings,
    String paperSize = '58',
  }) async {
    state = state.copyWith(
      isPrinting: true,
      clearError: true,
    );

    try {
      await PrinterService.instance.testPrint(
        settings: settings,
        paperSize: paperSize,
      );
      state = state.copyWith(
        isPrinting: false,
        successMessage: 'Test print berhasil!',
      );
    } catch (e) {
      state = state.copyWith(
        isPrinting: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ─── PRINT RECEIPT ──────────────────────────
  Future<void> printReceipt({
    required TransactionsTableData transaction,
    required List<TransactionItemsTableData> items,
    required SettingsTableData? settings,
    String paperSize = '58',
  }) async {
    state = state.copyWith(
      isPrinting: true,
      clearError: true,
    );

    try {
      await PrinterService.instance.printReceipt(
        transaction: transaction,
        items: items,
        settings: settings,
        paperSize: paperSize,
      );
      state = state.copyWith(
        isPrinting: false,
        successMessage: 'Struk berhasil dicetak',
      );
    } catch (e) {
      state = state.copyWith(
        isPrinting: false,
        errorMessage: e.toString(),
      );
    }
  }
}