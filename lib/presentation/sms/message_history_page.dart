import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/failure.dart';
import '../../core/theme/app_dimens.dart';
import '../../provider/sms/message_history_provider.dart';
import '../common/error_state_view.dart';
import '../theme/theme_toggle_widget.dart';
import 'widgets/message_history_list.dart';

class MessageHistoryPage extends ConsumerStatefulWidget {
  const MessageHistoryPage({super.key});

  @override
  ConsumerState<MessageHistoryPage> createState() => _MessageHistoryPageState();
}

class _MessageHistoryPageState extends ConsumerState<MessageHistoryPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(messageHistoryProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(messageHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message History'),
        actions: const [ThemeToggleIcon()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: historyAsync.when(
            data: (state) => MessageHistoryList(
              messages: state.messages,
              isLoadingMore: state.isLoadingMore,
              controller: _scrollController,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorStateView(
              message: error is Failure ? error.userMessage : 'Something went wrong.',
              onRetry: () => ref.invalidate(messageHistoryProvider),
            ),
          ),
        ),
      ),
    );
  }
}
