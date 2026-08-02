# coffee_pos

Aplikasi kasir coffee shop offline untuk Android, dibangun dengan Flutter.
---
## Fitur

- Kasir dengan varian & add-on produk
- Manajemen menu, kategori & user
- Laporan penjualan harian
- Export laporan PDF & Excel
- Cetak struk Bluetooth thermal printer
- Backup & restore data lokal
- Auto sync Google Drive
- PIN lock & keamanan akun
- Responsive (HP & tablet)
- 100% offline
---
## Tech Stack

**Framework**	    Flutter + Dart
**Database**	    SQLite (Drift)
**State**	        Riverpod
**Navigation**	  GoRouter
**Cloud	Google**  Drive API
---
## Cara Jalankan
```bash
git clone https://github.com/username/coffee_pos.git
cd coffee_pos

flutter pub get
dart run build_runner build --delete-conflicting-outputs

flutter run
```
---
## Pertama Kali Buka
- Buat akun Admin (nama toko, username, - password)
- Login
- Mulai tambah kategori & produk
- Siap transaksi
---
## Lupa PIN

Tap ikon 🔒 di layar PIN sebanyak 7x → masukkan akun admin → PIN direset.
---
## Minimum

- Android 5.0+
- RAM 2GB
- Bluetooth (untuk printer)
