import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/theme_local_datasource.dart';
import '../../data/repositories/theme_repository.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../core_providers.dart';

final themeLocalDataSourceProvider = Provider<ThemeLocalDataSource>((ref) {
  return HiveThemeLocalDataSource(ref.watch(localStorageServiceProvider));
});

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepositoryImpl(ref.watch(themeLocalDataSourceProvider));
});
