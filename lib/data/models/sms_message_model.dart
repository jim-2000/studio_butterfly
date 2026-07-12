import 'package:equatable/equatable.dart';

import '../../core/money/money.dart';
import 'message_status.dart';

/// `recipient` arrives already masked by the server (`+4915*****78`) —
/// never unmask or log it (API-CONTRACT.md is explicit on this point).
class SmsMessageModel extends Equatable {
  const SmsMessageModel({
    required this.messageId,
    required this.recipient,
    required this.status,
    required this.segmentCount,
    required this.cost,
    required this.sentAt,
  });

  factory SmsMessageModel.fromJson(Map<String, dynamic> json) {
    // The message-history example in API-CONTRACT.md omits `currency` per
    // item (unlike /cost/breakdown, which has one) — every example in the
    // contract uses EUR, so that's the documented fallback assumption here.
    final currency = json['currency'] as String? ?? 'EUR';
    return SmsMessageModel(
      messageId: json['messageId'] as String,
      recipient: json['recipient'] as String,
      status: MessageStatusX.fromApi(json['status'] as String),
      segmentCount: json['segmentCount'] as int,
      cost: Money.parse(json['cost'] as String, currency),
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }

  final String messageId;
  final String recipient;
  final MessageStatus status;
  final int segmentCount;
  final Money cost;
  final DateTime sentAt;

  @override
  List<Object?> get props => [messageId, recipient, status, segmentCount, cost, sentAt];
}
