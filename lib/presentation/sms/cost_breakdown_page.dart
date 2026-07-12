import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/failure.dart';
import '../../core/theme/app_dimens.dart';
import '../../provider/sms/sms_cost_provider.dart';
import '../common/error_state_view.dart';
import '../theme/theme_toggle_widget.dart';
import 'widgets/cost_breakdown_list.dart';

class CostBreakdownPage extends ConsumerWidget {
  const CostBreakdownPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final costAsync = ref.watch(smsCostProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Breakdown'),
        actions: const [ThemeToggleIcon()],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(smsCostProvider.future),
          child: costAsync.when(
            data: (breakdown) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: CostBreakdownList(breakdown: breakdown),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorStateView(
              message: error is Failure ? error.userMessage : 'Something went wrong.',
              onRetry: () => ref.invalidate(smsCostProvider),
            ),
          ),
        ),
      ),
    );
  }
}
