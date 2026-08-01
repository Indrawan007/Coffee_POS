import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/user_datasource.dart';

// ─── DATASOURCE PROVIDER ──────────────────────────
final userDatasourceProvider = Provider<UserDatasource>((ref) {
  return UserDatasource(AppDatabase.instance);
});

// ─── USERS STREAM ─────────────────────────────────
final usersStreamProvider =
    StreamProvider<List<UsersTableData>>((ref) {
  return ref.watch(userDatasourceProvider).watchAll();
});