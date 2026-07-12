import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/failure.dart';
import '../../data/models/sms_send_result_model.dart';
import 'sms_repository_provider.dart';

sealed class SmsSendState {
  const SmsSendState();
}

class SmsSendIdle extends SmsSendState {
  const SmsSendIdle();
}

class SmsSendLoading extends SmsSendState {
  const SmsSendLoading();
}

class SmsSendSuccess extends SmsSendState {
  const SmsSendSuccess(this.result);

  final SmsSendResultModel result;
}

class SmsSendFailed extends SmsSendState {
  const SmsSendFailed(this.failure);

  final Failure failure;
}

class SmsSendNotifier extends Notifier<SmsSendState> {
  @override
  SmsSendState build() => const SmsSendIdle();

  Future<void> send({required String to, required String body}) async {
    state = const SmsSendLoading();
    final result = await ref.read(smsRepositoryProvider).sendSms(to: to, body: body);
    state = result.fold(SmsSendFailed.new, SmsSendSuccess.new);
  }

  void reset() => state = const SmsSendIdle();
}

final smsSendProvider = NotifierProvider<SmsSendNotifier, SmsSendState>(SmsSendNotifier.new);
