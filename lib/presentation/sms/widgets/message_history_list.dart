import 'package:flutter/material.dart';

import '../../../data/models/sms_message_model.dart';
import '../../common/empty_state_view.dart';
import 'message_history_tile.dart';

/// Pure widget: messages/loading-more flag in as props, an optional
/// [ScrollController] for the page above to drive pagination — no
/// provider access here.
class MessageHistoryList extends StatelessWidget {
  const MessageHistoryList({
    super.key,
    required this.messages,
    required this.isLoadingMore,
    this.controller,
  });

  final List<SmsMessageModel> messages;
  final bool isLoadingMore;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const EmptyStateView(message: 'No messages yet.', icon: Icons.forum_outlined);
    }

    return ListView.separated(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: messages.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return MessageHistoryTile(message: messages[index]);
      },
    );
  }
}
