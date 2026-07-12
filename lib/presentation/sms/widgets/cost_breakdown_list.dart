import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../data/models/sms_cost_breakdown_model.dart';
import '../../common/empty_state_view.dart';
import 'cost_breakdown_row.dart';

class CostBreakdownList extends StatelessWidget {
  const CostBreakdownList({super.key, required this.breakdown});

  final SmsCostBreakdownModel breakdown;

  @override
  Widget build(BuildContext context) {
    if (breakdown.rows.isEmpty) {
      return const EmptyStateView(message: 'No usage yet this period.', icon: Icons.receipt_long_outlined);
    }

    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: textTheme.titleLarge),
            Text(breakdown.totalCost.display, style: textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const Divider(),
        for (final row in breakdown.rows) CostBreakdownRow(provider: row.provider, messageCount: row.messageCount, totalCost: row.totalCost),
      ],
    );
  }
}
