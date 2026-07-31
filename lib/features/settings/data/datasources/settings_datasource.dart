import '../../../../core/database/app_database.dart';

class SettingsDatasource {
  const SettingsDatasource(this._db);
  final AppDatabase _db;

  Future<SettingsTableData?> getSettings() {
    return (_db.select(_db.settingsTable)).getSingleOrNull();
  }

  Stream<SettingsTableData?> watchSettings() {
    return (_db.select(_db.settingsTable)).watchSingleOrNull();
  }

  Future<void> updateSettings(SettingsTableCompanion data) async {
    final existing = await getSettings();
    if (existing == null) {
      await _db.into(_db.settingsTable).insert(data);
    } else {
      await (_db.update(_db.settingsTable)).write(data);
    }
  }
}