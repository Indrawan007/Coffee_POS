import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/printer_service.dart';
import '../providers/printer_provider.dart';
import '../providers/settings_provider.dart';

class PrinterSettingsScreen extends ConsumerWidget {
  const PrinterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerState  = ref.watch(printerNotifierProvider);
    final notifier      = ref.read(printerNotifierProvider.notifier);
    final settingsAsync = ref.watch(settingsStreamProvider);

    // Listen messages
    ref.listen(printerNotifierProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // ── STATUS CARD ──────────────────────
          _StatusCard(status: printerState.status),
          const SizedBox(height: AppSizes.md),

          // ── ACTION BUTTONS ───────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: printerState.isScanning
                    ? null
                    : notifier.scan,
                  icon: printerState.isScanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bluetooth_searching),
                  label: Text(
                    printerState.isScanning
                      ? 'Scanning...'
                      : 'Scan Perangkat',
                  ),
                ),
              ),
              if (printerState.isConnected) ...[
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: notifier.disconnect,
                    icon: const Icon(
                      Icons.bluetooth_disabled,
                      color: AppColors.error,
                    ),
                    label: const Text(
                      'Putuskan',
                      style: TextStyle(
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: AppSizes.md),

          // ── DEVICE LIST ──────────────────────
          if (printerState.devices.isNotEmpty) ...[
            const Text(
              'Perangkat Ditemukan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            ...printerState.devices.map((device) =>
              _DeviceCard(
                device: device,
                isConnected:
                  printerState.status.deviceAddress ==
                  device.address,
                isConnecting: printerState.isConnecting,
                onConnect: () => notifier.connect(device),
              ),
            ),

            const SizedBox(height: AppSizes.md),
          ],

          // ── TEST PRINT ───────────────────────
          if (printerState.isConnected) ...[
            const Divider(),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'Test Printer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            settingsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (settings) => Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: printerState.isPrinting
                        ? null
                        : () => notifier.testPrint(
                            settings: settings,
                            paperSize: '58',
                          ),
                      icon: const Icon(Icons.print),
                      label: Text(
                        printerState.isPrinting
                          ? 'Mencetak...'
                          : 'Test Print 58mm',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: printerState.isPrinting
                        ? null
                        : () => notifier.testPrint(
                            settings: settings,
                            paperSize: '80',
                          ),
                      icon: const Icon(Icons.print),
                      label: Text(
                        printerState.isPrinting
                          ? 'Mencetak...'
                          : 'Test Print 80mm',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── TIPS ─────────────────────────────
          const SizedBox(height: AppSizes.lg),
          const _PrinterTips(),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});
  final PrinterStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: status.isConnected
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: status.isConnected
            ? AppColors.success.withOpacity(0.3)
            : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            status.isConnected
              ? Icons.bluetooth_connected
              : Icons.bluetooth_disabled,
            color: status.isConnected
              ? AppColors.success
              : AppColors.error,
            size: 32,
          ),
          const SizedBox(width: AppSizes.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.isConnected
                  ? 'Terhubung'
                  : 'Tidak Terhubung',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: status.isConnected
                    ? AppColors.success
                    : AppColors.error,
                  fontSize: 16,
                ),
              ),
              if (status.deviceName != null)
                Text(
                  status.deviceName!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.isConnected,
    required this.isConnecting,
    required this.onConnect,
  });

  final BluetoothDevice device;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        leading: Icon(
          Icons.print,
          color: isConnected
            ? AppColors.success
            : AppColors.textSecondary,
        ),
        title: Text(device.name),
        subtitle: Text(
          device.address,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: isConnected
          ? const Chip(
              label: Text(
                'Terhubung',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            )
          : ElevatedButton(
              onPressed: isConnecting ? null : onConnect,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                ),
              ),
              child: isConnecting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Hubungkan'),
            ),
      ),
    );
  }
}

class _PrinterTips extends StatelessWidget {
  const _PrinterTips();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: AppColors.info),
              SizedBox(width: AppSizes.sm),
              Text(
                'Tips Penggunaan Printer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ...[
            '1. Pastikan printer sudah di-pair di pengaturan Bluetooth Android',
            '2. Nyalakan printer sebelum melakukan scan',
            '3. Jika gagal connect, coba restart Bluetooth',
            '4. Pastikan kertas thermal sudah terpasang',
            '5. Gunakan kertas ukuran 58mm atau 80mm sesuai printer',
          ].map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          )),
        ],
      ),
    );
  }
}