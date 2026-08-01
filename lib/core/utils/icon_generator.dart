import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Panggil dari halaman sementara untuk generate icon
/// Setelah icon dibuat, hapus file ini
class IconGeneratorScreen extends StatelessWidget {
  const IconGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Icon')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Preview icon
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF4E342E),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '☕',
                  style: TextStyle(fontSize: 100),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Buat icon 512x512 px di:\n'
              'https://iconkitchen.com\n'
              'atau Canva\n\n'
              'Simpan ke:\n'
              'assets/icons/app_icon.png',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}