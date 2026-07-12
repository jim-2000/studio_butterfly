/// Typed exceptions thrown by [ApiClient] for non-2xx responses and
/// transport-level failures. Datasources throw these; repositories catch
/// them and map to [Failure] — `dynamic` never leaks past this layer.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// `400` — request failed contract validation (e.g. non-E.164 phone number).
class ValidationApiException extends ApiException {
  const ValidationApiException(this.errorCode, super.message);

  final String errorCode;
}

/// `401` — access token missing or expired.
class UnauthorizedApiException extends ApiException {
  const UnauthorizedApiException([super.message = 'Unauthorized']);
}

/// `403` — request is missing `X-Tenant-Id`, or the token does not grant it.
class ForbiddenApiException extends ApiException {
  const ForbiddenApiException([super.message = 'Forbidden']);
}

/// `429` — rate limited; [retryAfter] is parsed from the `Retry-After` header.
class RateLimitedApiException extends ApiException {
  const RateLimitedApiException(this.retryAfter, [super.message = 'Rate limited']);

  final Duration retryAfter;
}

/// `502` — upstream SMS provider failed.
class BadGatewayApiException extends ApiException {
  const BadGatewayApiException([super.message = 'Upstream provider failed']);
}

/// Timeout, DNS failure, connection refused, offline, etc. — never reached
/// the server at all.
class NetworkApiException extends ApiException {
  const NetworkApiException([super.message = 'Network error']);
}

/// Any other non-2xx status the contract doesn't define a specific case for.
class UnknownApiException extends ApiException {
  const UnknownApiException(this.statusCode, [super.message = 'Unexpected error']);

  final int statusCode;
}
