import 'package:equatable/equatable.dart';

import '../../core/money/money.dart';
import 'message_status.dart';

/// The send response's `cost`/`segmentCount` are authoritative — this is
/// what actually gets billed, never recomputed client-side (see REVIEW.md
/// finding #9, the starter's guessed local rate table).
class SmsSendResultModel extends Equatable {
  const SmsSendResultModel({
    required this.messageId,
    required this.provider,
    required this.status,
    required this.segmentCount,
    required this.cost,
  });

  factory SmsSendResultModel.fromJson(Map<String, dynamic> json) {
    return SmsSendResultModel(
      messageId: json['messageId'] as String,
      provider: json['provider'] as String,
      status: MessageStatusX.fromApi(json['status'] as String),
      segmentCount: json['segmentCount'] as int,
      cost: Money.parse(json['cost'] as String, json['currency'] as String),
    );
  }

  final String messageId;
  final String provider;
  final MessageStatus status;
  final int segmentCount;
  final Money cost;

  @override
  List<Object?> get props => [messageId, provider, status, segmentCount, cost];
}
