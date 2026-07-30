import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/settings_datasource.dart';

part 'settings_provider.g.dart';

@riverpod
SettingsDatasource settingsDatasource(Ref ref) {
  return SettingsDatasource(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<SettingsTableData?> settingsStream(Ref ref) {
  return ref.watch(settingsDatasourceProvider).watchSettings();
}