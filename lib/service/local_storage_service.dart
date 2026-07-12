import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studio_butterfly/service/local_storage_key.dart';

/// Global local-storage singleton (Hive-backed). `LocalStorageService()`
/// always returns the same instance, so `init()` in `main.dart` and every
/// later `LocalStorageService()` call share the same opened box.
class LocalStorageService {
  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  static final LocalStorageService _instance = LocalStorageService._internal();

  static const String _settingsBoxName = 'settings';
  late final Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_settingsBoxName);
  }

  Box get box => _box;

  ThemeMode getThemeMode() {
    final stored = _box.get(LocalStorageKey.themeModeKey);
    if (stored == ThemeMode.dark.index) return ThemeMode.dark;
    return ThemeMode.light;
  }

  Future<void> saveThemeMode(ThemeMode mode) => _box.put(LocalStorageKey.themeModeKey, mode.index);

  //
  Future<void> setString(String key, String value) => _box.put(key, value);

  String? getString(String key) => _box.get(key) as String?;

  Future<void> remove(String key) => _box.delete(key);
}
