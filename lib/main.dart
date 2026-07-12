import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_butterfly/env.dart';
import 'package:studio_butterfly/presentation/sms/sms_console_page.dart';
import 'package:studio_butterfly/service/local_storage_service.dart';

import 'core/theme/app_theme.dart';
import 'data/models/theme_mode_model.dart';
import 'provider/theme/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService().init();

  runApp(const ProviderScope(child: StudioButterflyApp()));
}

class StudioButterflyApp extends ConsumerWidget {
  const StudioButterflyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: Environment.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode.materialThemeMode,
      home: const SmsScreen(),
    );
  }
}
