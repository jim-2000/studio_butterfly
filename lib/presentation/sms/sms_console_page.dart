import 'package:flutter/material.dart';
import 'package:studio_butterfly/presentation/theme/theme_toggle_widget.dart';

class SmsScreen extends StatelessWidget {
  const SmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Console'), actions: [ThemeToggleIcon()]),
      body: Column(children: [Center(child: const Text('SMS Console'))]),
    );
  }
}
