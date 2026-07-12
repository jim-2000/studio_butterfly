import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../data/models/message_status.dart';
import '../../../data/models/sms_message_model.dart';
import 'status_chip.dart';

/// Reusable message-history row. `message.recipient` is rendered exactly
/// as received — already masked server-side, never touched further.
class MessageHistoryTile extends StatelessWidget {
  const MessageHistoryTile({super.key, required this.message});

  final SmsMessageModel message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final segmentsLabel = message.segmentCount == 1 ? '1 segment' : '${message.segmentCount} segments';

    return Semantics(
      label: '${message.recipient}, ${message.status.label}, ${message.cost.display}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.recipient, style: textTheme.titleMedium),
                  Text(
                    '$segmentsLabel · ${_formatDate(message.sentAt)}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(status: message.status),
                const SizedBox(height: AppSpacing.xs),
                Text(message.cost.display, style: textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day ${_months[local.month - 1]}, $hour:$minute';
  }
}
