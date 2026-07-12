/// Delivery status is not final at send time — the contract says a message
/// moves `ACCEPTED -> SENT -> DELIVERED` or `-> FAILED` asynchronously.
enum MessageStatus { accepted, sent, delivered, failed }

extension MessageStatusX on MessageStatus {
  static MessageStatus fromApi(String value) => switch (value) {
        'ACCEPTED' => MessageStatus.accepted,
        'SENT' => MessageStatus.sent,
        'DELIVERED' => MessageStatus.delivered,
        'FAILED' => MessageStatus.failed,
        _ => MessageStatus.accepted,
      };

  String get label => switch (this) {
        MessageStatus.accepted => 'Accepted',
        MessageStatus.sent => 'Sent',
        MessageStatus.delivered => 'Delivered',
        MessageStatus.failed => 'Failed',
      };
}
