import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';

/// Shared empty state — "no messages yet", "no usage yet" etc. An empty
/// list says something instead of rendering nothing.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key, required this.message, this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
