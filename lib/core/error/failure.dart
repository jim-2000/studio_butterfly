import '../network/api_exception.dart';

/// UI-facing failure hierarchy, mirroring [ApiException] one-to-one. The
/// presentation layer renders a distinct widget per subtype instead of one
/// generic "something went wrong" — never an infinite spinner.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

class ValidationFailure extends Failure {
  const ValidationFailure(this.errorCode, super.message);

  final String errorCode;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class TenantMismatchFailure extends Failure {
  const TenantMismatchFailure(super.message);
}

class RateLimitedFailure extends Failure {
  const RateLimitedFailure(this.retryAfter, super.message);

  final Duration retryAfter;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

/// User-facing text for a [Failure] — shared by every screen so a `429`
/// always reads "try again in Ns" instead of each screen inventing its own
/// wording (or forgetting the parsed `Retry-After` entirely).
extension FailureMessage on Failure {
  String get userMessage {
    final self = this;
    if (self is RateLimitedFailure) {
      return 'Too many requests — try again in ${self.retryAfter.inSeconds}s.';
    }
    return message;
  }
}

/// Maps a thrown [ApiException] to its [Failure] counterpart. Kept in one
/// place so every repository handles errors identically.
Failure failureFromException(Object error) {
  return switch (error) {
    ValidationApiException(:final errorCode, :final message) => ValidationFailure(errorCode, message),
    UnauthorizedApiException(:final message) => AuthFailure(message),
    ForbiddenApiException(:final message) => TenantMismatchFailure(message),
    RateLimitedApiException(:final retryAfter, :final message) => RateLimitedFailure(retryAfter, message),
    BadGatewayApiException(:final message) => ServerFailure(message),
    NetworkApiException(:final message) => NetworkFailure(message),
    UnknownApiException(:final message) => UnknownFailure(message),
    _ => UnknownFailure(error.toString()),
  };
}
