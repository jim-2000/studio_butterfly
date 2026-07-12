import 'package:flutter/material.dart';

/// App-level theme preference. An enum already has correct value equality,
/// so no `Equatable` wrapper is needed here (unlike the SMS models, which
/// carry fields and do use it).
enum AppThemeMode { light, dark, system }

extension AppThemeModeX on AppThemeMode {
  ThemeMode get materialThemeMode => switch (this) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      };

  String get storageValue => name;

  static AppThemeMode fromStorageValue(String? value) => switch (value) {
        'light' => AppThemeMode.light,
        'dark' => AppThemeMode.dark,
        _ => AppThemeMode.system,
      };
}
