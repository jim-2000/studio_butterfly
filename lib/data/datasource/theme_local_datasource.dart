import '../../service/local_storage_key.dart';
import '../../service/local_storage_service.dart';

/// Reads/writes the persisted theme preference through the global
/// [LocalStorageService] — no custom `TypeAdapter`/codegen needed for a
/// single string setting.
abstract class ThemeLocalDataSource {
  String? readThemeMode();
  Future<void> writeThemeMode(String value);
}

class HiveThemeLocalDataSource implements ThemeLocalDataSource {
  HiveThemeLocalDataSource(this._storage);

  final LocalStorageService _storage;

  @override
  String? readThemeMode() => _storage.getString(LocalStorageKey.themeModeKey);

  @override
  Future<void> writeThemeMode(String value) => _storage.setString(LocalStorageKey.themeModeKey, value);
}
