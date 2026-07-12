import 'package:flutter/material.dart';

import '../../../core/money/money.dart';
import '../../../core/theme/app_dimens.dart';

/// Reusable cost row — one of the two deliberate-API components called out
/// by the assignment. Pure props in (provider name, message count, total),
/// no repository/provider access, so it's just as usable in a list, a
/// summary card, or a golden test in isolation.
class CostBreakdownRow extends StatelessWidget {
  const CostBreakdownRow({
    super.key,
    required this.provider,
    required this.messageCount,
    required this.totalCost,
  });

  final String provider;
  final int messageCount;
  final Money totalCost;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = messageCount == 1 ? '1 message' : '$messageCount messages';

    return Semantics(
      label: '$provider, $label, ${totalCost.display}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider, style: textTheme.titleMedium),
                  Text(label, style: textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(totalCost.display, style: textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
