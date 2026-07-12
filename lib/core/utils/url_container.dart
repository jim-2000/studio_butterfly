/// API base URL and endpoint paths.
///
/// The base URL is a compile-time value (`--dart-define=API_BASE_URL=...`),
/// never a hardcoded secret in source — defaults to the local mock server
/// used for development and grading.
class UrlContainer {
  UrlContainer._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String authRefresh = '/api/v1/auth/refresh';
  static const String smsSend = '/api/v1/sms/send';
  static const String smsBulk = '/api/v1/sms/bulk';
  static const String smsCostBreakdown = '/api/v1/sms/cost/breakdown';
  static const String smsMessages = '/api/v1/sms/messages';
}
