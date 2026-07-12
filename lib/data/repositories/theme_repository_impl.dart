import '../datasource/theme_local_datasource.dart';
import '../models/theme_mode_model.dart';
import 'theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this._local);

  final ThemeLocalDataSource _local;

  @override
  AppThemeMode getThemeMode() => AppThemeModeX.fromStorageValue(_local.readThemeMode());

  @override
  Future<void> setThemeMode(AppThemeMode mode) => _local.writeThemeMode(mode.storageValue);
}
