import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/failure.dart';
import '../../core/theme/app_dimens.dart';
import '../../provider/sms/sms_send_provider.dart';
import '../theme/theme_toggle_widget.dart';
import 'cost_breakdown_page.dart';
import 'message_history_page.dart';
import 'widgets/sms_form.dart';

class SmsScreen extends ConsumerWidget {
  const SmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sendState = ref.watch(smsSendProvider);

    ref.listen<SmsSendState>(smsSendProvider, (previous, next) => _handleSendResult(context, next));

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Console'),
        actions: [
          IconButton(
            tooltip: 'Message history',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MessageHistoryPage()),
            ),
          ),
          IconButton(
            tooltip: 'Cost breakdown',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CostBreakdownPage()),
            ),
          ),
          const ThemeToggleIcon(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SmsForm(
            isSending: sendState is SmsSendLoading,
            errorMessage: sendState is SmsSendFailed ? sendState.failure.userMessage : null,
            onSubmit: (to, body) => ref.read(smsSendProvider.notifier).send(to: to, body: body),
          ),
        ),
      ),
    );
  }

  void _handleSendResult(BuildContext context, SmsSendState state) {
    if (state is! SmsSendSuccess) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sent via ${state.result.provider} — ${state.result.cost.display}')));
  }
}
