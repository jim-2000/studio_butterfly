import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/theme_mode_model.dart';
import '../../provider/theme/theme_mode_provider.dart';

class ThemeToggleIcon extends ConsumerWidget {
  const ThemeToggleIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = switch (mode) {
      AppThemeMode.dark => true,
      AppThemeMode.light => false,
      AppThemeMode.system => MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
    final label = isDark ? 'Switch to light theme' : 'Switch to dark theme';

    return Semantics(
      button: true,
      label: label,
      child: IconButton(tooltip: label, onPressed: () => ref.read(themeModeProvider.notifier).toggle(), icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined)),
    );
  }
}
