import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/sms_cost_breakdown_model.dart';
import 'sms_repository_provider.dart';

/// `AsyncNotifier` fits this screen better than the hand-rolled state used
/// for send: this is a plain "load once, retry on error" fetch, and
/// `AsyncValue.when(data:, error:, loading:)` already gives distinct
/// loading/error/data states for free. The repository still returns
/// `Either<Failure, T>`; `build()` unwraps it into `AsyncValue`'s own error
/// channel by throwing the `Failure` on the left, so the UI can pattern
/// match on the real `Failure` subtype in the `error` callback.
class SmsCostNotifier extends AsyncNotifier<SmsCostBreakdownModel> {
  @override
  Future<SmsCostBreakdownModel> build() async {
    final result = await ref.read(smsRepositoryProvider).getCostBreakdown();
    return result.fold((failure) => throw failure, (data) => data);
  }
}

final smsCostProvider = AsyncNotifierProvider<SmsCostNotifier, SmsCostBreakdownModel>(SmsCostNotifier.new);
