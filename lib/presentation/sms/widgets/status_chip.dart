import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/message_status.dart';

/// Reusable status indicator — maps [MessageStatus] to a color + label.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = switch (status) {
      MessageStatus.delivered => isDark ? DarkColors.success : LightColors.success,
      MessageStatus.sent => theme.colorScheme.primary,
      MessageStatus.accepted => isDark ? DarkColors.textSecondary : LightColors.textSecondary,
      MessageStatus.failed => isDark ? DarkColors.error : LightColors.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
