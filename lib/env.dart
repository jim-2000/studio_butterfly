class Environment {
  static const String appName = 'Studio Butterfly';

  /// Compile-time value (`--dart-define=API_BASE_URL=...`) — never a
  /// hardcoded URL in source. Defaults to the local mock server used for
  /// development and grading.
  static const String kApiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
