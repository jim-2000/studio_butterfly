import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/theme_mode_model.dart';
import 'theme_repository_provider.dart';

class ThemeModeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => ref.read(themeRepositoryProvider).getThemeMode();

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    await ref.read(themeRepositoryProvider).setThemeMode(mode);
  }

  void toggle() {
    final next = state == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark;
    unawaited(setThemeMode(next));
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, AppThemeMode>(ThemeModeNotifier.new);
