/// API endpoint paths. Base URL lives in [Environment.kApiBase]
/// (`lib/env.dart`) — kept in one place rather than duplicated here.
class UrlContainer {
  UrlContainer._();

  static const String authRefresh = '/api/v1/auth/refresh';
  static const String smsSend = '/api/v1/sms/send';
  static const String smsBulk = '/api/v1/sms/bulk';
  static const String smsCostBreakdown = '/api/v1/sms/cost/breakdown';
  static const String smsMessages = '/api/v1/sms/messages';
}
