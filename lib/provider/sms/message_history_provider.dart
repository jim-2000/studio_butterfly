import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/sms_message_model.dart';
import 'sms_repository_provider.dart';

class MessageHistoryState {
  const MessageHistoryState({
    required this.messages,
    required this.nextCursor,
    required this.isLoadingMore,
  });

  final List<SmsMessageModel> messages;
  final String? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;
}

/// Pagination state built by hand rather than a generic `copyWith` — a
/// page boundary means `nextCursor` must be able to become `null`
/// (exhausted), which a `field ?? current.field` copyWith would silently
/// refuse to do.
class MessageHistoryNotifier extends AsyncNotifier<MessageHistoryState> {
  static const _pageSize = 50;

  @override
  Future<MessageHistoryState> build() async {
    final result = await ref.read(smsRepositoryProvider).getMessages(limit: _pageSize);
    return result.fold(
      (failure) => throw failure,
      (page) => MessageHistoryState(messages: page.items, nextCursor: page.nextCursor, isLoadingMore: false),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(
      MessageHistoryState(messages: current.messages, nextCursor: current.nextCursor, isLoadingMore: true),
    );

    final result = await ref.read(smsRepositoryProvider).getMessages(cursor: current.nextCursor, limit: _pageSize);
    state = AsyncData(
      result.fold(
        // Keep the page the user already has; just drop the spinner. A
        // failed "load more" shouldn't blow away a working list.
        (failure) => MessageHistoryState(
          messages: current.messages,
          nextCursor: current.nextCursor,
          isLoadingMore: false,
        ),
        (page) => MessageHistoryState(
          messages: [...current.messages, ...page.items],
          nextCursor: page.nextCursor,
          isLoadingMore: false,
        ),
      ),
    );
  }
}

final messageHistoryProvider = AsyncNotifierProvider<MessageHistoryNotifier, MessageHistoryState>(
  MessageHistoryNotifier.new,
);
