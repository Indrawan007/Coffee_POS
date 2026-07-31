import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../utils/hash_helper.dart';

import 'tables/users_table.dart';
import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/product_variants_table.dart';
import 'tables/addons_table.dart';
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
    TransactionsTable,
    TransactionItemsTable,
    SettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // ✅ Hanya seed data non-user
        await _seedDefaultData();
      },
      beforeOpen: (details) async {
        // Cek apakah settings sudah ada
        final settings =
          await select(settingsTable).getSingleOrNull();
        if (settings == null) {
          await _seedDefaultData();
        }
      },
    );
  }

  // ✅ Seed hanya data default (tanpa user)
  Future<void> _seedDefaultData() async {
    final now = DateTime.now().toIso8601String();

    // Default settings
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

    // Cek apakah kategori sudah ada
    final cats = await select(categoriesTable).get();
    if (cats.isNotEmpty) return;

    // Default categories
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

    // Default addons
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
          name: 'Less Sugar',
          price: const Value(0),
          createdAt: now,
        ),
        AddonsTableCompanion.insert(
          name: 'No Sugar',
          price: const Value(0),
          createdAt: now,
        ),
      ]);
    });

    // Default products
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
  }

  // ✅ Method untuk cek apakah sudah ada user
  Future<bool> hasUsers() async {
    final users = await select(usersTable).get();
    return users.isNotEmpty;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'coffee_pos.db'));
    return NativeDatabase.createInBackground(file);
  });
}