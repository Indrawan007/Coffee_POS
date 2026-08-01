import 'dart:io';
import 'package:coffee_pos/core/database/tables/activity_logs_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


import 'tables/users_table.dart';
import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/product_variants_table.dart';
import 'tables/addons_table.dart';
// ✅ Tambah import
import 'tables/category_addons_table.dart';
import 'tables/transactions_table.dart';
import 'tables/transaction_items_table.dart';
import 'tables/settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UsersTable,
    CategoriesTable,
    ProductsTable,
    ProductVariantsTable,
    AddonsTable,
    // ✅ Tambah tabel baru
    CategoryAddonsTable,
    TransactionsTable,
    TransactionItemsTable,
    SettingsTable, 
    ActivityLogsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  
  static AppDatabase? _instance;

  static AppDatabase get instance {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  AppDatabase._internal() : super(_openConnection());

  // ✅ Update schema version
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // ✅ Buat tabel baru saat upgrade
          await m.createTable(categoryAddonsTable);
          // Seed relasi addon-kategori
          await _seedCategoryAddons();
        }
        // ✅ Tambah migrasi v3
        if (from < 3) {
          await m.createTable(activityLogsTable);
        }
      },
      beforeOpen: (details) async {
        final settings =
          await select(settingsTable).getSingleOrNull();
        if (settings == null) {
          await _seedDefaultData();
        }

        // Cek apakah category_addons sudah ada datanya
        final catAddons =
          await select(categoryAddonsTable).get();
        if (catAddons.isEmpty) {
          await _seedCategoryAddons();
        }
      },
    );
  }

  // ✅ Seed relasi kategori-addon
  Future<void> _seedCategoryAddons() async {
    // Ambil semua kategori dan addon
    final cats   = await select(categoriesTable).get();
    final addons = await select(addonsTable).get();

    if (cats.isEmpty || addons.isEmpty) return;

    // Cari ID kategori
    int? coffeeId;
    int? nonCoffeeId;

    for (final cat in cats) {
      final nameLower = cat.name.toLowerCase();
      if (nameLower == 'coffee') coffeeId = cat.id;
      if (nameLower == 'non coffee') nonCoffeeId = cat.id;
    }

    // Cari ID addon
    final Map<String, int> addonMap = {};
    for (final addon in addons) {
      addonMap[addon.name.toLowerCase()] = addon.id;
    }

    final extraShotId =
      addonMap['extra shot'];
    final extraMilkId =
      addonMap['extra milk'];
    final lessSugarId =
      addonMap['less sugar'];
    final noSugarId =
      addonMap['no sugar'];

    final companions = <CategoryAddonsTableCompanion>[];
    
    if (coffeeId != null) {
      final coffeeAddons = [
        'extra shot',
        'extra milk',
        'extra whip cream',
        'gula aren',
        'less sugar',
        'less ice',
        'extra syrup',
      ];

      for (final name in coffeeAddons) {
        final id = addonMap[name];
        if (id != null) {
          companions.add(
            CategoryAddonsTableCompanion.insert(
              categoryId: coffeeId,
              addonId: id,
            ),
          );
        }
      }
    }

    // ✅ Non Coffee → addon tanpa extra shot
    if (nonCoffeeId != null) {
      final nonCoffeeAddons = [
        'extra milk',
        'extra whip cream',
        'gula aren',
        'less sugar',
        'less ice',
        'extra syrup',
      ];

      for (final name in nonCoffeeAddons) {
        final id = addonMap[name];
        if (id != null) {
          companions.add(
            CategoryAddonsTableCompanion.insert(
              categoryId: nonCoffeeId,
              addonId: id,
            ),
          );
        }
      }
    }

    // Food → TIDAK ADA addon

    if (companions.isNotEmpty) {
      await batch((b) {
        b.insertAll(categoryAddonsTable, companions);
      });
    }

    debugPrint(
      'Seeded ${companions.length} category-addon relations',
    );
  }

  // ✅ Method ambil addon berdasarkan kategori
  Future<List<AddonsTableData>> getAddonsByCategory(
    int categoryId,
  ) async {
    final query = select(addonsTable).join([
      innerJoin(
        categoryAddonsTable,
        categoryAddonsTable.addonId
          .equalsExp(addonsTable.id),
      ),
    ])
      ..where(
        categoryAddonsTable.categoryId.equals(categoryId) &
        addonsTable.isActive.equals(true),
      );

    final rows = await query.get();
    return rows.map((row) =>
      row.readTable(addonsTable),
    ).toList();
  }

  // ✅ Method cek apakah ada user
  Future<bool> hasUsers() async {
    final users = await select(usersTable).get();
    return users.isNotEmpty;
  }

  // Seed default data (sama seperti sebelumnya)
  Future<void> _seedDefaultData() async {
    final now = DateTime.now().toIso8601String();

    final existingSettings =
      await select(settingsTable).getSingleOrNull();
    if (existingSettings == null) {
      await into(settingsTable).insert(
        SettingsTableCompanion.insert(
          storeName: const Value('Coffee Shop'),
          storeAddress: const Value('Jl. Contoh No.1'),
          storePhone: const Value('0812-3456-7890'),
          taxPercent: const Value(10.0),
          servicePercent: const Value(5.0),
          updatedAt: now,
        ),
      );
    }

    final cats = await select(categoriesTable).get();
    if (cats.isNotEmpty) return;

    final coffeeId = await into(categoriesTable).insert(
      CategoriesTableCompanion.insert(
        name: 'Coffee',
        sortOrder: const Value(1),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final nonCoffeeId = await into(categoriesTable).insert(
      CategoriesTableCompanion.insert(
        name: 'Non Coffee',
        sortOrder: const Value(2),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final foodId = await into(categoriesTable).insert(
      CategoriesTableCompanion.insert(
        name: 'Food',
        sortOrder: const Value(3),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await batch((b) {
      b.insertAll(addonsTable, [
        AddonsTableCompanion.insert(
          name: 'Extra Shot',
          price: const Value(5000),
          createdAt: now,
        ),
        AddonsTableCompanion.insert(
          name: 'Extra Milk',
          price: const Value(3000),
          createdAt: now,
        ),
        AddonsTableCompanion.insert(
          name: 'Extra Whip Cream',
          price: const Value(4000),
          createdAt: now,
        ),
        AddonsTableCompanion.insert(
          name: 'Gula Aren',
          price: const Value(3000),
          createdAt: now,
        ),
        // ✅ Sugar level jadi 1 opsi saja
        AddonsTableCompanion.insert(
          name: 'Less Sugar',
          price: const Value(0),
          createdAt: now,
        ),
        AddonsTableCompanion.insert(
          name: 'Less Ice',
          price: const Value(0),
          createdAt: now,
        ),
        AddonsTableCompanion.insert(
          name: 'Extra Syrup',
          price: const Value(3000),
          createdAt: now,
        ),
      ]);
    });

    final latteId = await into(productsTable).insert(
      ProductsTableCompanion.insert(
        categoryId: coffeeId,
        name: 'Latte',
        basePrice: const Value(25000),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await batch((b) {
      b.insertAll(productVariantsTable, [
        ProductVariantsTableCompanion.insert(
          productId: latteId,
          name: 'Small',
          priceAdjustment: const Value(0),
        ),
        ProductVariantsTableCompanion.insert(
          productId: latteId,
          name: 'Medium',
          priceAdjustment: const Value(3000),
        ),
        ProductVariantsTableCompanion.insert(
          productId: latteId,
          name: 'Large',
          priceAdjustment: const Value(5000),
        ),
      ]);
    });

    final capId = await into(productsTable).insert(
      ProductsTableCompanion.insert(
        categoryId: coffeeId,
        name: 'Cappuccino',
        basePrice: const Value(28000),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await batch((b) {
      b.insertAll(productVariantsTable, [
        ProductVariantsTableCompanion.insert(
          productId: capId,
          name: 'Regular',
          priceAdjustment: const Value(0),
        ),
        ProductVariantsTableCompanion.insert(
          productId: capId,
          name: 'Large',
          priceAdjustment: const Value(5000),
        ),
      ]);
    });

    await into(productsTable).insert(
      ProductsTableCompanion.insert(
        categoryId: nonCoffeeId,
        name: 'Matcha Latte',
        basePrice: const Value(30000),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await into(productsTable).insert(
      ProductsTableCompanion.insert(
        categoryId: foodId,
        name: 'Croissant',
        basePrice: const Value(18000),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Seed category addons setelah data ada
    await _seedCategoryAddons();
  }



  // ✅ Method log activity
  Future<void> logActivity({
    required String action,
    String? detail,
    int? userId,
    String? userName,
  }) async {
      await into(activityLogsTable).insert(
        ActivityLogsTableCompanion.insert(
          action: action,
          detail: Value(detail),
          userId: Value(userId),
          userName: Value(userName),
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    }

    // ✅ Get activity logs
    Future<List<ActivityLogsTableData>> getActivityLogs({
      int limit = 50,
    }) async {
      return (select(activityLogsTable)
        ..orderBy([(l) => OrderingTerm.desc(l.createdAt)])
        ..limit(limit)
      ).get();
    }
  }


LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'coffee_pos.db'));
    return NativeDatabase.createInBackground(file);
  });
}